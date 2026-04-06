import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';

class OsteoporosisSurveyHandler extends SurveyTypeHandler {
  const OsteoporosisSurveyHandler();

  @override
  String get type => 'osteoporosis';

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
    if (score >= 7) {
      return 'El puntaje maximo para comparacion es 6. Cruce el puntaje, edad e IMC en la tabla correspondiente.';
    }
    return 'Cruce el puntaje, edad e IMC en la tabla correspondiente para determinar el riesgo.';
  }

  @override
  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    return 'Puntaje: ${score > 6 ? 6 : score}';
  }
}
