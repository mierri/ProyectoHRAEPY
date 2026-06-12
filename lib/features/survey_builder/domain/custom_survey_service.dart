import 'package:flutter/foundation.dart';
import 'package:ssapp/core/logger/app_logger.dart';
import 'package:ssapp/features/survey_builder/data/custom_survey_repository.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/shared/utils/id_generator.dart';

/// Coordina la creacion, edicion y consulta de encuestas personalizadas
/// (creadas por la doctora) para la UI.
class CustomSurveyService extends ChangeNotifier {
  final CustomSurveyRepository _repository;
  List<CustomSurveyDefinition> _surveys = [];

  CustomSurveyService({CustomSurveyRepository? repository})
      : _repository = repository ?? CustomSurveyRepository();

  List<CustomSurveyDefinition> get surveys => List.unmodifiable(_surveys);

  List<CustomSurveyDefinition> get activeSurveys =>
      _surveys.where((s) => s.active).toList();

  Future<void> loadAll() async {
    try {
      _surveys = await _repository.loadAll();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error al cargar encuestas personalizadas', e);
    }
  }

  CustomSurveyDefinition? getById(int id) {
    final match = _surveys.where((s) => s.id == id);
    return match.isEmpty ? null : match.first;
  }

  Future<CustomSurveyDefinition> create(CustomSurveyDefinition definition) async {
    final withId = definition.id == 0
        ? CustomSurveyDefinition(
            id: generateId(),
            title: definition.title,
            description: definition.description,
            colorHex: definition.colorHex,
            questions: definition.questions,
            levels: definition.levels,
            active: definition.active,
          )
        : definition;

    await _repository.save(withId);
    _surveys = [..._surveys, withId];
    notifyListeners();
    return withId;
  }

  Future<void> update(CustomSurveyDefinition definition) async {
    await _repository.save(definition);
    _surveys = _surveys.map((s) => s.id == definition.id ? definition : s).toList();
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _repository.delete(id);
    _surveys = _surveys.where((s) => s.id != id).toList();
    notifyListeners();
  }

  Future<void> toggleActive(int id) async {
    final current = getById(id);
    if (current == null) return;
    await update(current.copyWith(active: !current.active));
  }
}
