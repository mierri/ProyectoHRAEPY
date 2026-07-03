import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';
import 'package:ssapp/features/surveys/types/moca_basic/domain/moca_basic_scoring.dart';

class MocaBasicSurveyHandler extends SurveyTypeHandler {
  const MocaBasicSurveyHandler();

  @override
  String get type => 'moca_basic';

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
    return MocaBasicScoring.totalScore(map);
  }

  @override
  int totalScoreFromResponses(Map<int, int> responses) {
    return MocaBasicScoring.totalScore(responses);
  }

  @override
  String interpretation({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    return MocaBasicScoring.interpretation(score);
  }

  @override
  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    return MocaBasicScoring.levelForScore(score);
  }
}
