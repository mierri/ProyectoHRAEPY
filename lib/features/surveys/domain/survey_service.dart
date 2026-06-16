import 'package:flutter/foundation.dart';
import 'package:ssapp/core/logger/app_logger.dart';
import 'package:ssapp/features/surveys/domain/use_cases/save_survey_use_case.dart';
import 'package:ssapp/features/surveys/data/survey_repository.dart';
import 'package:ssapp/features/surveys/domain/survey_rules.dart';
import 'package:ssapp/shared/models/survey_model.dart';

// Responsabilidad: coordinar operaciones de encuestas para la UI sin lógica de catálogo, scoring ni sincronización directa.
class SurveyService extends ChangeNotifier {
  final SurveyRepositoryContract _repository;
  late final SaveSurveyUseCase _saveSurveyUseCase;
  List<Map<String, dynamic>> _surveys = [];
  Map<String, dynamic>? _cachedStats;

  SurveyService({SurveyRepositoryContract? repository})
    : _repository = repository ?? SurveyRepository() {
    _saveSurveyUseCase = SaveSurveyUseCase(_repository);
  }

  List<Map<String, dynamic>> get surveys => List.unmodifiable(_surveys);

  /// Obtiene encuestas completadas (con respuestas)
  List<Map<String, dynamic>> getCompletedSurveys() {
    return SurveyRules.completedSurveys(_surveys);
  }

  /// Obtiene estadísticas completas de las encuestas.
  /// Cached: returns the same Map reference until surveys change, so
  /// context.select won't trigger spurious rebuilds on every notification.
  Map<String, dynamic> getStatistics() {
    return _cachedStats ??= SurveyRules.statistics(_surveys);
  }
  
  /// Obtiene encuestas por tipo (BDI=1, BAI=2, WHOQOL=3, SF-36=5, ASSIST=6, GDS-15=7, Lawton=8, Osteoporosis=9, Katz=10, ICIQ-SF=11, GHQ-12=12, PHQ-9=13)
  List<Map<String, dynamic>> getSurveysByType(int surveyType) {
    return _surveys.where((survey) => survey['survey_type'] == surveyType).toList();
  }

  /// Carga todas las encuestas
  Future<void> loadSurveys() async {
    try {
      _surveys = await _repository.loadSurveys();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error al cargar encuestas', e);
      _surveys = await _repository.loadSurveys();
      notifyListeners();
    }
  }

  /// Guarda localmente y luego intenta sincronizar
  Future<SaveSurveyResult> saveSurvey(SurveyModel survey) {
    return _saveSurveyUseCase.execute(survey);
  }
}
