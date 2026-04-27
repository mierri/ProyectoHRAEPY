import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';

class Phq9SurveyHandler extends SurveyTypeHandler {
  const Phq9SurveyHandler();

  @override
  String get type => 'phq9';

  @override
  int scoreFromStoredResponses(List<dynamic> responses) {
    return responses.fold<int>(0, (sum, response) {
      final item = response as Map<String, dynamic>;
      final questionId = item['question_id'] as int? ?? 0;
      final answerValue = item['answer_value'] as int? ?? 0;
      if (questionId < 1 || questionId > 9) return sum;
      return sum + answerValue;
    });
  }

  @override
  int totalScoreFromResponses(Map<int, int> responses) {
    return responses.entries
        .where((entry) => entry.key >= 1 && entry.key <= 9)
        .fold<int>(0, (sum, entry) => sum + entry.value);
  }

  @override
  String interpretation({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    final suicidalIdeation = (responses[9] ?? 0) > 0;

    if (score <= 4) {
      return suicidalIdeation
          ? 'Sintomas minimos, pero existe ideacion autolesiva. Requiere valoracion clinica inmediata.'
          : 'Sintomas depresivos minimos o ausentes.';
    }
    if (score <= 9) {
      return suicidalIdeation
          ? 'Sintomas leves con ideacion autolesiva. Se recomienda evaluacion profesional prioritaria.'
          : 'Sintomas depresivos leves.';
    }
    if (score <= 14) {
      return suicidalIdeation
          ? 'Sintomas moderados con ideacion autolesiva. Se recomienda atencion profesional urgente.'
          : 'Sintomas depresivos moderados. Se recomienda valoracion profesional.';
    }
    if (score <= 19) {
      return suicidalIdeation
          ? 'Sintomas moderadamente graves con ideacion autolesiva. Requiere atencion urgente.'
          : 'Sintomas depresivos moderadamente graves. Se recomienda manejo clinico activo.';
    }
    return suicidalIdeation
        ? 'Sintomas depresivos graves con ideacion autolesiva. Requiere atencion inmediata.'
        : 'Sintomas depresivos graves. Requiere atencion profesional inmediata.';
  }

  @override
  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    if (score <= 4) return 'Minima';
    if (score <= 9) return 'Leve';
    if (score <= 14) return 'Moderada';
    if (score <= 19) return 'Moderadamente grave';
    return 'Grave';
  }
}

