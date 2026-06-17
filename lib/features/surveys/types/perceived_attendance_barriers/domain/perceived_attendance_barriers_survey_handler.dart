import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';

class PerceivedAttendanceBarriersSurveyHandler extends SurveyTypeHandler {
  const PerceivedAttendanceBarriersSurveyHandler();

  @override
  String get type => 'perceived_attendance_barriers';

  @override
  int scoreFromStoredResponses(List<dynamic> responses) {
    return 0;
  }

  @override
  int totalScoreFromResponses(Map<int, int> responses) {
    return 0;
  }

  @override
  String interpretation({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    return 'Encuesta sin puntuación.';
  }

  @override
  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    return 'Sin puntuación';
  }
}
