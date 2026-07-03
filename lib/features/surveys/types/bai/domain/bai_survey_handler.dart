import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';

class BaiSurveyHandler extends SurveyTypeHandler {
  const BaiSurveyHandler();

  @override
  String get type => 'bai';

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
    if (score <= 21) return 'Ansiedad muy baja durante la ultima semana.';
    if (score <= 35) return 'Ansiedad moderada durante la ultima semana.';
    return 'Presenta sintomas severos de ansiedad.';
  }

  @override
  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    if (score <= 21) return 'Ansiedad muy baja';
    if (score <= 35) return 'Ansiedad moderada';
    return 'Ansiedad Severa';
  }
}
