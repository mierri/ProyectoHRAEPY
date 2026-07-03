import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';

class BdiSurveyHandler extends SurveyTypeHandler {
  const BdiSurveyHandler();

  @override
  String get type => 'bdi';

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
    if (score <= 13) return 'Depresion minima o ausencia de sintomas clinicamente relevantes.';
    if (score <= 19) return 'Presenta sintomas leves de depresion.';
    if (score <= 28) return 'Presenta sintomas moderados de depresion.';
    return 'Presenta sintomas severos de depresion.';
  }

  @override
  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    if (score <= 13) return 'Depresion Minima';
    if (score <= 19) return 'Depresion Leve';
    if (score <= 28) return 'Depresion Moderada';
    return 'Depresion Severa';
  }
}
