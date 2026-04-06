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
    if (score <= 7) return 'Los sintomas de ansiedad son minimos o inexistentes.';
    if (score <= 15) return 'Presenta sintomas leves de ansiedad.';
    if (score <= 25) return 'Presenta sintomas moderados de ansiedad.';
    return 'Presenta sintomas severos de ansiedad.';
  }

  @override
  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    if (score <= 7) return 'Ansiedad Minima';
    if (score <= 15) return 'Ansiedad Leve';
    if (score <= 25) return 'Ansiedad Moderada';
    return 'Ansiedad Severa';
  }
}
