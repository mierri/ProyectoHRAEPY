import 'dart:async';

import 'package:hive/hive.dart';
import 'package:ssapp/core/network/network_executor.dart';
import 'package:ssapp/shared/services/syncable.dart';
import 'package:ssapp/core/supabase/supabase_config.dart';
import 'package:ssapp/core/logger/app_logger.dart';
import 'package:ssapp/shared/models/patient_model.dart';
import 'package:ssapp/shared/models/response_model.dart';
import 'package:ssapp/shared/models/survey_model.dart';

abstract class SurveyRepositoryContract implements ISyncable {
  Future<List<Map<String, dynamic>>> loadSurveys();
  Future<SurveyModel> saveSurveyLocally(SurveyModel survey);
  Future<bool> syncSurveyToSupabase(SurveyModel survey);
  Future<List<Map<String, dynamic>>> getAllSurveysFromSupabase();
  Future<int> syncPendingSurveys();
  Future<bool> syncPatientToSupabase(PatientModel patient);
}

// Responsabilidad: persistir y sincronizar encuestas entre Hive y Supabase.
class SurveyRepository implements SurveyRepositoryContract {
  bool _isForeignKeyPatientError(Object error) {
    final message = error.toString();
    return message.contains('surveys_patient_id_fkey') ||
        message.contains('code: 23503') ||
        message.contains('foreign key constraint');
  }

  Future<bool> _syncPatientFromLocalIfNeeded(int? patientId) async {
    if (patientId == null || patientId == 0) return false;

    try {
      final box = await Hive.openBox<PatientModel>('patients');
      final patients = box.values.where((p) => p.patientId == patientId).toList();
      if (patients.isEmpty) {
        AppLogger.warning(
            'Paciente $patientId no encontrado en Hive local (box tiene ${box.values.length} pacientes: ${box.values.map((p) => p.patientId).toList()})');
        return false;
      }

      final patient = patients.first;
      final supabase = SupabaseConfig.client;
      await supabase.from('patients').upsert(patient.toJson()).select().single();

      patient.synced = true;
      await patient.save();
      return true;
    } catch (e) {
      AppLogger.error('No se pudo sincronizar paciente relacionado ($patientId)', e);
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
      AppLogger.error('Error al cargar encuestas', e);
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
        AppLogger.error('Error al abrir Hive box, limpiando datos antiguos', e);
        await Hive.deleteBoxFromDisk('surveys');
        box = await Hive.openBox<SurveyModel>('surveys');
      }

      return box.values.map((survey) {
        return {
          'survey_id': survey.surveyId,
          'patient_id': survey.patientId,
          'investigation_id': survey.investigationId,
          'survey_type': survey.surveyType,
          'risk_level': survey.risk_level,
          'score': survey.score,
          'custom_survey_id': survey.customSurveyId,
          'synced': survey.synced,
          'created_at': _createdAtFromSurveyId(survey.surveyId).toIso8601String(),
          'responses': survey.responses
              .map((r) => {
                    'question_id': r.questionId,
                    'answer_value': r.answerValue,
                    if (r.answerText != null && r.answerText!.isNotEmpty) 'answer_text': r.answerText,
                  })
              .toList(),
        };
      }).toList();
    } catch (e) {
      AppLogger.error('Error al cargar encuestas locales', e);
      return [];
    }
  }

  /// `generateId()` produce IDs como `timestampMs * 10000 + rand`, demasiado
  /// grandes para `DateTime.fromMillisecondsSinceEpoch`. Recupera el
  /// timestamp original dividiendo por 10000.
  DateTime _createdAtFromSurveyId(int surveyId) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(surveyId ~/ 10000);
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  Future<bool> syncSurveyToSupabase(SurveyModel survey) async {
    try {
      final supabase = SupabaseConfig.client;

      if (survey.surveyId == 0) {
        AppLogger.error('Error: survey_id inválido');
        return false;
      }

      if (survey.patientId == null || survey.patientId == 0) {
        AppLogger.error('Error: patient_id inválido');
        return false;
      }

      final surveyData = {
        'survey_id': survey.surveyId,
        'patient_id': survey.patientId,
        'investigation_id': survey.investigationId,
        'survey_type': survey.surveyType,
        'risk_level': survey.risk_level,
        'score': survey.score,
        'custom_survey_id': survey.customSurveyId,
        'synced': true,
      };

      try {
        await NetworkExecutor.runWithRetry(
          () => supabase.from('surveys').upsert(surveyData, onConflict: 'survey_id'),
          operationName: 'upsert survey',
        );
      } catch (e) {
        if (_isForeignKeyPatientError(e)) {
          final patientSynced = await _syncPatientFromLocalIfNeeded(survey.patientId);
          if (patientSynced) {
            await NetworkExecutor.runWithRetry(
              () => supabase.from('surveys').upsert(surveyData, onConflict: 'survey_id'),
              operationName: 'upsert survey after patient sync',
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
                if (r.answerText != null && r.answerText!.isNotEmpty) 'answer_text': r.answerText,
              })
          .toList();

      if (responsesData.isNotEmpty) {
        await NetworkExecutor.runWithRetry(
          () => supabase.from('responses').delete().eq('survey_id', survey.surveyId),
          operationName: 'delete previous survey responses',
        );
        await NetworkExecutor.runWithRetry(
          () => supabase.from('responses').insert(responsesData),
          operationName: 'insert survey responses',
        );
      }

      AppLogger.info('Encuesta sincronizada exitosamente: ${survey.surveyId}');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Error al sincronizar con Supabase', e, stackTrace);
      AppLogger.debug('Survey ID: ${survey.surveyId}');
      AppLogger.debug('Patient ID: ${survey.patientId}');
      AppLogger.debug('Survey Type: ${survey.surveyType}');
      AppLogger.debug('Responses count: ${survey.responses.length}');
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllSurveysFromSupabase() async {
    try {
      final supabase = SupabaseConfig.client;
      final data = await NetworkExecutor.runWithRetry(
        () => supabase
            .from('surveys')
            .select('*, responses(*)')
            .order('created_at', ascending: false),
        operationName: 'fetch surveys from supabase',
      );
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      AppLogger.error('Error al obtener encuestas de Supabase', e);
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
        AppLogger.info('No hay encuestas pendientes de sincronización');
        return 0;
      }

      AppLogger.info('Sincronizando ${pendingSurveys.length} encuestas pendientes...');

      for (final survey in pendingSurveys) {
        final success = await syncSurveyToSupabase(survey);
        if (success) {
          survey.synced = true;
          await survey.save();
          syncedCount++;
          AppLogger.info('Encuesta ${survey.surveyId} sincronizada');
        } else {
          AppLogger.warning('No se pudo sincronizar encuesta ${survey.surveyId}');
        }
      }

      AppLogger.info('Sincronización completada: $syncedCount/${pendingSurveys.length} encuestas');
    } catch (e) {
      AppLogger.error('Error al sincronizar encuestas pendientes', e);
    }

    return syncedCount;
  }

  @override
  Future<int> syncPendingToServer() {
    return syncPendingSurveys();
  }

  @override
  Future<void> downloadFromServer() async {
    try {
      final remoteSurveys = await getAllSurveysFromSupabase();
      final box = await Hive.openBox<SurveyModel>('surveys');

      for (final surveyData in remoteSurveys) {
        final surveyId = surveyData['survey_id'] as int?;
        if (surveyId == null) continue;

        final exists = box.values.any((s) => s.surveyId == surveyId);
        if (exists) continue;

        final responses = (surveyData['responses'] as List? ?? [])
            .map(
              (r) => ResponseModel(
                questionId: r['question_id'] as int,
                answerValue: r['answer_value'] as int,
                answerText: r['answer_text'] as String?,
              ),
            )
            .toList();

        final newSurvey = SurveyModel(
          surveyId: surveyId,
          surveyType: surveyData['survey_type'] as int? ?? 1,
          patientId: surveyData['patient_id'] as int?,
          investigationId: surveyData['investigation_id'] as int?,
          responses: responses,
          synced: true,
          risk_level: surveyData['risk_level'] as String?,
          score: surveyData['score'] as int?,
          customSurveyId: surveyData['custom_survey_id'] as int?,
        );

        await box.add(newSurvey);
      }
    } catch (e) {
      AppLogger.error('Error al descargar encuestas desde servidor', e);
    }
  }

  @override
  Future<bool> syncPatientToSupabase(PatientModel patient) async {
    try {
      final supabase = SupabaseConfig.client;
      await supabase
          .from('patients')
          .upsert(patient.toJson())
          .select()
          .single();

      patient.synced = true;
      await patient.save();
      AppLogger.info('Paciente ${patient.patientId} sincronizado exitosamente');
      return true;
    } catch (e) {
      AppLogger.error('Error al sincronizar paciente con Supabase', e);
      return false;
    }
  }
}