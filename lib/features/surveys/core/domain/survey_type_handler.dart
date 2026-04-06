abstract class SurveyTypeHandler {
  const SurveyTypeHandler();

  String get type;

  int scoreFromStoredResponses(List<dynamic> responses);

  int totalScoreFromResponses(Map<int, int> responses);

  String interpretation({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  });

  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  });
}
