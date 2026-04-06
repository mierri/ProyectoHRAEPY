import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';
import 'package:ssapp/features/surveys/types/iciq_sf/domain/iciq_sf_questions.dart';

class IciqSfSurveyHandler extends SurveyTypeHandler {
  const IciqSfSurveyHandler();

  @override
  String get type => 'iciqsf';

  @override
  int scoreFromStoredResponses(List<dynamic> responses) {
    return responses.fold<int>(0, (sum, response) {
      final item = response as Map<String, dynamic>;
      final questionId = item['question_id'] as int? ?? 0;
      if (questionId == 4) return sum;
      final answerValue = item['answer_value'] as int? ?? 0;
      return sum + answerValue;
    });
  }

  @override
  int totalScoreFromResponses(Map<int, int> responses) {
    return IciqSfQuestions.calculateScore(responses);
  }

  @override
  String interpretation({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    return IciqSfQuestions.evaluate(responses).interpretacion;
  }

  @override
  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    final result = IciqSfQuestions.evaluate(responses);
    if (result.score == 0) return 'Sin incontinencia';
    return 'Impacto ${result.severidad}';
  }
}
