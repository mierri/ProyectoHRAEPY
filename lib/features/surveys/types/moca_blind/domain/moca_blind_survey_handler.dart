import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';
import 'package:ssapp/features/surveys/types/moca_blind/domain/moca_blind_scoring.dart';

class MocaBlindSurveyHandler extends SurveyTypeHandler {
  const MocaBlindSurveyHandler();

  @override
  String get type => 'moca_blind';

  @override
  int scoreFromStoredResponses(List<dynamic> responses) {
    final map = <int, int>{};
    for (final response in responses) {
      final item = response as Map<String, dynamic>;
      final questionId = item['question_id'] as int?;
      final answerValue = item['answer_value'] as int?;
      if (questionId != null && answerValue != null) {
        map[questionId] = answerValue;
      }
    }
    return MocaBlindScoring.totalScore(map);
  }

  @override
  int totalScoreFromResponses(Map<int, int> responses) {
    return MocaBlindScoring.totalScore(responses);
  }

  @override
  String interpretation({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    return MocaBlindScoring.interpretation(score);
  }

  @override
  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    return MocaBlindScoring.levelForScore(score);
  }
}
