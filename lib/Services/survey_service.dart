import 'package:flutter/foundation.dart';
import 'package:ssapp/config/supabase_config.dart';
import 'package:ssapp/models/survey_model.dart';

class SurveyService extends ChangeNotifier {
  List<Map<String, dynamic>> _surveys = [];
  
  /// Obtiene estadísticas de las encuestas
  Map<String, dynamic> getStatistics() {
    return {
      'totalSurveys': _surveys.length,
      'lastSync': DateTime.now(),
    };
  }
  
  /// Carga todas las encuestas
  Future<void> loadSurveys() async {
    _surveys = await getAllSurveysFromSupabase();
    notifyListeners();
  }
  // Para usar con Render también si lo necesitas
  static const String renderUrl = 'https://tu-app.onrender.com/api/surveys';

  /// Sincroniza una encuesta con Supabase
  Future<bool> syncSurveyToSupabase(SurveyModel survey) async {
    try {
      final supabase = SupabaseConfig.client;
      
      // Preparar datos para insertar
      final surveyData = {
        'survey_id': survey.surveyId,
        'created_at': DateTime.now().toIso8601String(),
        'synced': true,
      };

      // Insertar encuesta en la tabla 'surveys'
      final surveyResponse = await supabase
          .from('surveys')
          .insert(surveyData)
          .select()
          .single();

      final dbSurveyId = surveyResponse['id'];

      // Insertar respuestas en la tabla 'responses'
      final responsesData = survey.responses.map((r) => {
        'survey_id': dbSurveyId,
        'question_id': r.questionId,
        'answer_value': r.answerValue,
      }).toList();

      await supabase
          .from('responses')
          .insert(responsesData);

      return true;
    } catch (e) {
      print('Error al sincronizar con Supabase: $e');
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
}
