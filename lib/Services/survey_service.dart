import 'package:flutter/foundation.dart';
import 'package:ssapp/Services/surveys/survey_catalog.dart';
import 'package:ssapp/Services/surveys/save_survey_use_case.dart';
import 'package:ssapp/Services/surveys/survey_repository.dart';
import 'package:ssapp/Services/surveys/survey_rules.dart';
import 'package:ssapp/models/survey_model.dart';

class SurveyService extends ChangeNotifier {
  final SurveyRepositoryContract _repository;
  late final SaveSurveyUseCase _saveSurveyUseCase;
  List<Map<String, dynamic>> _surveys = [];

  SurveyService({SurveyRepositoryContract? repository})
    : _repository = repository ?? SurveyRepository() {
    _saveSurveyUseCase = SaveSurveyUseCase(_repository);
  }
  
  List<Map<String, dynamic>> get surveys => List.unmodifiable(_surveys);

  /// Obtiene encuestas completadas (con respuestas)
  List<Map<String, dynamic>> getCompletedSurveys() {
    return SurveyRules.completedSurveys(_surveys);
  }

  /// Calcula el score total de una encuesta
  int calculateSurveyScore(Map<String, dynamic> survey) {
    return SurveyRules.calculateScore(survey);
  }

  /// Calcula el score promedio de todas las encuestas completadas
  double getAverageScore() {
    return SurveyRules.averageScore(_surveys);
  }

  /// Obtiene estadísticas completas de las encuestas
  Map<String, dynamic> getStatistics() {
    return SurveyRules.statistics(_surveys);
  }
  
  /// Obtiene encuestas por tipo (BDI=1, BAI=2, WHOQOL=3, MoCA=4, SF-36=5, ASSIST=6, GDS-15=7, Lawton=8, Osteoporosis=9, Katz=10, ICIQ-SF=11)
  List<Map<String, dynamic>> getSurveysByType(int surveyType) {
    return _surveys.where((survey) => survey['survey_type'] == surveyType).toList();
  }

  /// Obtiene el nombre del tipo de encuesta
  String getSurveyTypeName(int surveyId) {
    return SurveyCatalog.nameForId(surveyId);
  }

  /// Obtiene el color del tipo de encuesta
  String getSurveyTypeColor(int surveyId) {
    return SurveyCatalog.colorForId(surveyId);
  }

  /// Carga todas las encuestas
  Future<void> loadSurveys() async {
    try {
      _surveys = await _repository.loadSurveys();
      notifyListeners();
    } catch (e) {
      print('Error al cargar encuestas: $e');
      _surveys = await _repository.loadSurveys();
      notifyListeners();
    }
  }
  // Para usar con Render también si lo necesitas
  static const String renderUrl = 'https://tu-app.onrender.com/api/surveys';

  /// Sincroniza una encuesta con Supabase
  Future<bool> syncSurveyToSupabase(SurveyModel survey) async {
    return _repository.syncSurveyToSupabase(survey);
  }

  /// Guarda localmente y luego intenta sincronizar
  Future<SaveSurveyResult> saveSurvey(SurveyModel survey) {
    return _saveSurveyUseCase.execute(survey);
  }

  /// Obtiene todas las encuestas desde Supabase
  Future<List<Map<String, dynamic>>> getAllSurveysFromSupabase() async {
    return _repository.getAllSurveysFromSupabase();
  }

  /// Sincroniza una encuesta con el backend de Render
  Future<bool> syncSurveyToRender(SurveyModel survey) async {
    try {
      return true;
    } catch (e) {
      print('Error al sincronizar con Render: $e');
      return false;
    }
  }

  /// Sincroniza encuestas pendientes con Supabase
  Future<int> syncPendingSurveys() async {
    final syncedCount = await _repository.syncPendingSurveys();
    await loadSurveys();
    return syncedCount;
  }
}
