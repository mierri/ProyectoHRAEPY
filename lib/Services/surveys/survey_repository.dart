import 'dart:async';

import 'package:hive/hive.dart';
import 'package:ssapp/config/supabase_config.dart';
import 'package:ssapp/models/patient_model.dart';
import 'package:ssapp/models/survey_model.dart';

abstract class SurveyRepositoryContract {
  Future<List<Map<String, dynamic>>> loadSurveys();
  Future<SurveyModel> saveSurveyLocally(SurveyModel survey);
  Future<bool> syncSurveyToSupabase(SurveyModel survey);
  Future<List<Map<String, dynamic>>> getAllSurveysFromSupabase();
  Future<int> syncPendingSurveys();
}

class SurveyRepository implements SurveyRepositoryContract {
  static const Duration _defaultNetworkTimeout = Duration(seconds: 12);
  static const int _maxNetworkRetries = 2;

  bool _isForeignKeyPatientError(Object error) {
    final message = error.toString();
    return message.contains('surveys_patient_id_fkey') ||
        message.contains('code: 23503') ||
        message.contains('foreign key constraint');
  }

  bool _isTransientNetworkError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('connection timed out') ||
        message.contains('timed out') ||
        message.contains('network is unreachable') ||
        message.contains('failed host lookup') ||
        message.contains('connection reset');
  }

  Future<T> _runWithRetry<T>(
    Future<T> Function() action, {
    Duration timeout = _defaultNetworkTimeout,
    int retries = _maxNetworkRetries,
    String operationName = 'network operation',
  }) async {
    Object? lastError;

    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        return await action().timeout(timeout);
      } catch (e) {
        lastError = e;
        final isLastAttempt = attempt == retries;
        final isRetriable = _isTransientNetworkError(e) || e is TimeoutException;

        if (isLastAttempt || !isRetriable) {
          rethrow;
        }

        final backoff = Duration(milliseconds: 400 * (attempt + 1));
        print(
          'Reintentando $operationName (${attempt + 1}/$retries) por error de red: $e',
        );
        await Future.delayed(backoff);
      }
    }

    throw lastError ?? Exception('Error desconocido en $operationName');
  }

  Future<bool> _syncPatientFromLocalIfNeeded(int? patientId) async {
    if (patientId == null || patientId == 0) return false;

    try {
      final box = await Hive.openBox<PatientModel>('patients');
      final patients = box.values.where((p) => p.patientId == patientId).toList();
      if (patients.isEmpty) return false;

      final patient = patients.first;
      final supabase = SupabaseConfig.client;
      await supabase.from('patients').upsert(patient.toJson()).select().single();

      patient.synced = true;
      await patient.save();
      return true;
    } catch (e) {
      print('No se pudo sincronizar paciente relacionado ($patientId): $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> loadSurveys() async {
    try {
      final supabaseSurveys = await getAllSurveysFromSupabase();
      final hiveSurveys = await _getLocalSurveys();
      final Map<int, Map<String, dynamic>> surveysMap = {};

      for (final survey in hiveSurveys) {
        surveysMap[survey['survey_id']] = survey;
      }

      for (final survey in supabaseSurveys) {
        final surveyId = survey['survey_id'] as int;
        if (!surveysMap.containsKey(surveyId)) {
          survey['survey_type'] = survey['survey_type'] ?? 1;
          surveysMap[surveyId] = survey;
        }
      }

      final surveys = surveysMap.values.toList();
      surveys.sort((a, b) {
        final aTime = DateTime.parse(a['created_at']);
        final bTime = DateTime.parse(b['created_at']);
        return bTime.compareTo(aTime);
      });
      return surveys;
    } catch (e) {
      print('Error al cargar encuestas: $e');
      return _getLocalSurveys();
    }
  }

  @override
  Future<SurveyModel> saveSurveyLocally(SurveyModel survey) async {
    Box<SurveyModel> box;
    try {
      box = await Hive.openBox<SurveyModel>('surveys');
    } catch (e) {
      await Hive.deleteBoxFromDisk('surveys');
      box = await Hive.openBox<SurveyModel>('surveys');
    }

    await box.add(survey);
    return survey;
  }

  Future<List<Map<String, dynamic>>> _getLocalSurveys() async {
    try {
      Box<SurveyModel> box;
      try {
        box = await Hive.openBox<SurveyModel>('surveys');
      } catch (e) {
        print('Error al abrir Hive box, limpiando datos antiguos: $e');
        await Hive.deleteBoxFromDisk('surveys');
        box = await Hive.openBox<SurveyModel>('surveys');
      }

      return box.values.map((survey) {
        return {
          'survey_id': survey.surveyId,
          'patient_id': survey.patientId,
          'survey_type': survey.surveyType,
          'synced': survey.synced,
          'created_at': DateTime.fromMillisecondsSinceEpoch(survey.surveyId).toIso8601String(),
          'responses': survey.responses
              .map((r) => {
                    'question_id': r.questionId,
                    'answer_value': r.answerValue,
                  })
              .toList(),
        };
      }).toList();
    } catch (e) {
      print('Error al cargar encuestas locales: $e');
      return [];
    }
  }

  @override
  Future<bool> syncSurveyToSupabase(SurveyModel survey) async {
    try {
      final supabase = SupabaseConfig.client;

      if (survey.surveyId == 0) {
        print('Error: survey_id inválido');
        return false;
      }

      if (survey.patientId == null || survey.patientId == 0) {
        print('Error: patient_id inválido');
        return false;
      }

      final surveyData = {
        'survey_id': survey.surveyId,
        'patient_id': survey.patientId,
        'survey_type': survey.surveyType,
        'synced': true,
      };

      try {
        await _runWithRetry(
          () => supabase.from('surveys').insert(surveyData),
          operationName: 'insert survey',
        );
      } catch (e) {
        if (_isForeignKeyPatientError(e)) {
          final patientSynced = await _syncPatientFromLocalIfNeeded(survey.patientId);
          if (patientSynced) {
            await _runWithRetry(
              () => supabase.from('surveys').insert(surveyData),
              operationName: 'insert survey after patient sync',
            );
          } else {
            rethrow;
          }
        } else {
          rethrow;
        }
      }

      final responsesData = survey.responses
          .map((r) => {
                'survey_id': survey.surveyId,
                'question_id': r.questionId,
                'answer_value': r.answerValue,
              })
          .toList();

      if (responsesData.isNotEmpty) {
        await _runWithRetry(
          () => supabase.from('responses').insert(responsesData),
          operationName: 'insert survey responses',
        );
      }

      print('Encuesta sincronizada exitosamente: ${survey.surveyId}');
      return true;
    } catch (e, stackTrace) {
      print('Error al sincronizar con Supabase: $e');
      print('Stack trace: $stackTrace');
      print('Survey ID: ${survey.surveyId}');
      print('Patient ID: ${survey.patientId}');
      print('Survey Type: ${survey.surveyType}');
      print('Responses count: ${survey.responses.length}');
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllSurveysFromSupabase() async {
    try {
      final supabase = SupabaseConfig.client;
      final data = await _runWithRetry(
        () => supabase
            .from('surveys')
            .select('*, responses(*)')
            .order('created_at', ascending: false),
        operationName: 'fetch surveys from supabase',
      );
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error al obtener encuestas de Supabase: $e');
      return [];
    }
  }

  @override
  Future<int> syncPendingSurveys() async {
    int syncedCount = 0;

    try {
      final box = await Hive.openBox<SurveyModel>('surveys');
      final pendingSurveys = box.values.where((s) => !s.synced).toList();

      if (pendingSurveys.isEmpty) {
        print('No hay encuestas pendientes de sincronización');
        return 0;
      }

      print('📤 Sincronizando ${pendingSurveys.length} encuestas pendientes...');

      for (final survey in pendingSurveys) {
        final success = await syncSurveyToSupabase(survey);
        if (success) {
          survey.synced = true;
          await survey.save();
          syncedCount++;
          print('Encuesta ${survey.surveyId} sincronizada');
        } else {
          print('No se pudo sincronizar encuesta ${survey.surveyId}');
        }
      }

      print('Sincronización completada: $syncedCount/${pendingSurveys.length} encuestas');
    } catch (e) {
      print('Error al sincronizar encuestas pendientes: $e');
    }

    return syncedCount;
  }
}