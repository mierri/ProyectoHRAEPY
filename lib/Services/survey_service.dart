import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:ssapp/config/supabase_config.dart';
import 'package:ssapp/models/survey_model.dart';

class SurveyService extends ChangeNotifier {
  List<Map<String, dynamic>> _surveys = [];
  
  List<Map<String, dynamic>> get surveys => List.unmodifiable(_surveys);

  /// Obtiene encuestas completadas (con respuestas)
  List<Map<String, dynamic>> getCompletedSurveys() {
    return _surveys.where((survey) {
      final responses = survey['responses'] as List?;
      return responses != null && responses.isNotEmpty;
    }).toList();
  }

  /// Calcula el score total de una encuesta
  int calculateSurveyScore(Map<String, dynamic> survey) {
    final responses = survey['responses'] as List?;
    if (responses == null || responses.isEmpty) return 0;

    return responses.fold<int>(0, (sum, response) {
      final answerValue = response['answer_value'] as int? ?? 0;
      return sum + answerValue;
    });
  }

  /// Calcula el score promedio de todas las encuestas completadas
  double getAverageScore() {
    final completed = getCompletedSurveys();
    if (completed.isEmpty) return 0.0;

    final totalScore = completed.fold<int>(0, (sum, survey) {
      return sum + calculateSurveyScore(survey);
    });

    return totalScore / completed.length;
  }

  /// Obtiene estadísticas completas de las encuestas
  Map<String, dynamic> getStatistics() {
    final completed = getCompletedSurveys();
    final scores = completed.map((s) => calculateSurveyScore(s)).toList()..sort();

    // Contar encuestas sincronizadas y pendientes
    final synced = _surveys.where((s) => s['synced'] == true).length;
    final pending = _surveys.where((s) => s['synced'] != true).length;

    return {
      'total': _surveys.length,
      'synced': synced,
      'pending': pending,
      'completed': completed.length,
      'incomplete': _surveys.length - completed.length,
      'averageScore': getAverageScore().toStringAsFixed(1),
      'minScore': scores.isEmpty ? 0 : scores.first,
      'maxScore': scores.isEmpty ? 0 : scores.last,
      'medianScore': scores.isEmpty ? 0 : scores[scores.length ~/ 2],
    };
  }
  
  /// Obtiene encuestas por tipo (BDI=1, BAI=2)
  List<Map<String, dynamic>> getSurveysByType(int surveyId) {
    return _surveys.where((survey) => survey['survey_id'] == surveyId).toList();
  }

  /// Obtiene el nombre del tipo de encuesta
  String getSurveyTypeName(int surveyId) {
    switch (surveyId) {
      case 1:
        return 'BDI-II';
      case 2:
        return 'BAI';
      default:
        return 'Encuesta #$surveyId';
    }
  }

  /// Obtiene el color del tipo de encuesta
  String getSurveyTypeColor(int surveyId) {
    switch (surveyId) {
      case 1:
        return 'primary'; // BDI - Azul
      case 2:
        return 'tertiary'; // BAI - Verde-azul
      default:
        return 'secondary';
    }
  }

  /// Carga todas las encuestas
  Future<void> loadSurveys() async {
    try {
      // Cargar desde Supabase
      final supabaseSurveys = await getAllSurveysFromSupabase();

      // Cargar desde Hive (encuestas locales)
      final hiveSurveys = await _getLocalSurveys();

      // Combinar: priorizar Hive para survey_type, agregar las de Supabase
      final Map<int, Map<String, dynamic>> surveysMap = {};

      // Primero agregar encuestas de Hive (tienen survey_type correcto)
      for (var survey in hiveSurveys) {
        surveysMap[survey['survey_id']] = survey;
      }

      // Luego agregar encuestas de Supabase que no estén en Hive
      // Ahora Supabase ya tiene el campo survey_type
      for (var survey in supabaseSurveys) {
        final surveyId = survey['survey_id'] as int;
        if (!surveysMap.containsKey(surveyId)) {
          // Leer survey_type desde Supabase, si no existe usar BDI como default
          survey['survey_type'] = survey['survey_type'] ?? 1;
          surveysMap[surveyId] = survey;
        }
      }

      _surveys = surveysMap.values.toList()
        ..sort((a, b) {
          final aTime = DateTime.parse(a['created_at']);
          final bTime = DateTime.parse(b['created_at']);
          return bTime.compareTo(aTime); // Más reciente primero
        });

      notifyListeners();
    } catch (e) {
      print('Error al cargar encuestas: $e');
      // Si falla Supabase, al menos cargar las locales
      _surveys = await _getLocalSurveys();
      notifyListeners();
    }
  }

  /// Obtiene encuestas desde Hive (almacenamiento local)
  Future<List<Map<String, dynamic>>> _getLocalSurveys() async {
    try {
      Box<SurveyModel> box;
      try {
        box = await Hive.openBox<SurveyModel>('surveys');
      } catch (e) {
        // Si hay error al abrir (probablemente datos viejos incompatibles),
        // eliminar y recrear la box
        print('Error al abrir Hive box, limpiando datos antiguos: $e');
        await Hive.deleteBoxFromDisk('surveys');
        box = await Hive.openBox<SurveyModel>('surveys');
      }

      final surveys = box.values.toList();

      return surveys.map((survey) {
        return {
          'survey_id': survey.surveyId,
          'patient_id': survey.patientId,
          'survey_type': survey.surveyType, // 1=BDI, 2=BAI
          'synced': survey.synced,
          'created_at': DateTime.fromMillisecondsSinceEpoch(survey.surveyId).toIso8601String(),
          'responses': survey.responses.map((r) => {
            'question_id': r.questionId,
            'answer_value': r.answerValue,
          }).toList(),
        };
      }).toList();
    } catch (e) {
      print('Error al cargar encuestas locales: $e');
      return [];
    }
  }
  // Para usar con Render también si lo necesitas
  static const String renderUrl = 'https://tu-app.onrender.com/api/surveys';

  /// Sincroniza una encuesta con Supabase
  Future<bool> syncSurveyToSupabase(SurveyModel survey) async {
    try {
      final supabase = SupabaseConfig.client;
      
      // Validar datos antes de insertar
      if (survey.surveyId == 0) {
        print('Error: survey_id inválido');
        return false;
      }

      if (survey.patientId == null || survey.patientId == 0) {
        print('Error: patient_id inválido');
        return false;
      }

      // Insertar encuesta en la tabla 'surveys'
      final surveyData = {
        'survey_id': survey.surveyId,
        'patient_id': survey.patientId,
        'survey_type': survey.surveyType, // ¡IMPORTANTE! Guardar el tipo de encuesta
        'synced': true,
      };

      await supabase
          .from('surveys')
          .insert(surveyData);

      // Insertar respuestas en la tabla 'responses'
      // Según fix_responses_table.sql: id (BIGSERIAL PRIMARY KEY), survey_id, question_id, answer_value
      final responsesData = survey.responses.map((r) => {
        'survey_id': survey.surveyId,
        'question_id': r.questionId,
        'answer_value': r.answerValue,
      }).toList();

      if (responsesData.isNotEmpty) {
        await supabase
            .from('responses')
            .insert(responsesData);
      }

      print('✅ Encuesta sincronizada exitosamente: ${survey.surveyId}');
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

  /// Obtiene todas las encuestas desde Supabase
  Future<List<Map<String, dynamic>>> getAllSurveysFromSupabase() async {
    try {
      final supabase = SupabaseConfig.client;
      
      final data = await supabase
          .from('surveys')
          .select('*, responses(*)')
          .order('created_at', ascending: false);

      // El survey_type ahora se incluye en los datos desde Supabase
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error al obtener encuestas de Supabase: $e');
      return [];
    }
  }

  /// Sincroniza una encuesta con el backend de Render (alternativo)
  Future<bool> syncSurveyToRender(SurveyModel survey) async {
    try {
      // Puedes usar este método si también quieres un backend en Render
      // que haga procesamiento adicional o actúe como intermediario
      
      // El código HTTP ya existente funcionaría aquí
      // por ahora retornamos true
      return true;
    } catch (e) {
      print('Error al sincronizar con Render: $e');
      return false;
    }
  }

  /// Sincroniza encuestas pendientes con Supabase
  Future<int> syncPendingSurveys() async {
    int syncedCount = 0;

    try {
      // Obtener encuestas pendientes desde Hive
      final box = await Hive.openBox<SurveyModel>('surveys');
      final pendingSurveys = box.values.where((s) => !s.synced).toList();

      if (pendingSurveys.isEmpty) {
        print('✅ No hay encuestas pendientes de sincronización');
        return 0;
      }

      print('📤 Sincronizando ${pendingSurveys.length} encuestas pendientes...');

      for (var survey in pendingSurveys) {
        final success = await syncSurveyToSupabase(survey);
        if (success) {
          survey.synced = true;
          await survey.save();
          syncedCount++;
          print('✅ Encuesta ${survey.surveyId} sincronizada');
        } else {
          print('⚠️ No se pudo sincronizar encuesta ${survey.surveyId}');
        }
      }

      // Recargar lista después de sincronizar
      await loadSurveys();

      print('✅ Sincronización completada: $syncedCount/${pendingSurveys.length} encuestas');

    } catch (e) {
      print('❌ Error al sincronizar encuestas pendientes: $e');
    }

    return syncedCount;
  }
}
