import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';

class LawtonSurveyHandler extends SurveyTypeHandler {
  const LawtonSurveyHandler();

  @override
  String get type => 'lawton';

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
    if (score == questionsCount) {
      return 'Independencia total para las actividades instrumentales evaluadas.';
    }
    return 'Presenta deterioro funcional en una o mas actividades instrumentales.';
  }

  @override
  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    if (score == questionsCount) return 'Independencia total';
    return 'Deterioro funcional';
  }
}
