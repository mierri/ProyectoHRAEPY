import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';
import 'package:ssapp/features/surveys/types/katz/domain/katz_questions.dart';

class KatzSurveyHandler extends SurveyTypeHandler {
  const KatzSurveyHandler();

  @override
  String get type => 'katz';

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
    return KatzQuestions.evaluate(responses).interpretacion;
  }

  @override
  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    return 'Katz ${KatzQuestions.evaluate(responses).clasificacionKatz}';
  }
}
