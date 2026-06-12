import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';

/// Handler generico para encuestas personalizadas: el puntaje es la suma
/// de todas las respuestas, sin reglas de interpretacion fijas (la doctora
/// define sus propios rangos en CustomSurveyDefinition.levels).
class CustomSurveyHandler extends SurveyTypeHandler {
  const CustomSurveyHandler();

  @override
  String get type => 'custom';

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
    return responses.values.fold<int>(0, (sum, value) => sum + value);
  }

  @override
  String interpretation({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    return 'Puntaje total: $score';
  }

  @override
  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    return 'Personalizado';
  }
}
