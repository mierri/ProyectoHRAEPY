import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';

class GdsSurveyHandler extends SurveyTypeHandler {
  const GdsSurveyHandler();

  @override
  String get type => 'gds';

  @override
  int scoreFromStoredResponses(List<dynamic> responses) {
    return responses.fold<int>(0, (sum, response) {
      final item = response as Map<String, dynamic>;
      final answerValue = item['answer_value'] as int? ?? 0;
      return sum + answerValue;
    });
  }

  @override
  int totalScoreFromResponses(Map<int, int> responses) {
    return responses.values.fold(0, (sum, score) => sum + score);
  }

  @override
  String interpretation({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    if (score <= 4) return 'Resultado dentro de la normalidad.';
    return 'Presenta sintomas depresivos.';
  }

  @override
  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    if (score <= 4) return 'Normal';
    return 'Sintomas depresivos';
  }
}
