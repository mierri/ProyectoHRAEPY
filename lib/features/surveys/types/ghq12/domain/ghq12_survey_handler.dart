import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';

class Ghq12SurveyHandler extends SurveyTypeHandler {
  const Ghq12SurveyHandler();

  @override
  String get type => 'ghq12';

  @override
  int scoreFromStoredResponses(List<dynamic> responses) {
    return responses.fold<int>(0, (sum, response) {
      final item = response as Map<String, dynamic>;
      final questionId = item['question_id'] as int? ?? 0;
      final answerValue = item['answer_value'] as int? ?? 0;
      if (questionId < 1 || questionId > 12) return sum;
      return sum + answerValue;
    });
  }

  @override
  int totalScoreFromResponses(Map<int, int> responses) {
    return responses.entries
        .where((entry) => entry.key >= 1 && entry.key <= 12)
        .fold<int>(0, (sum, entry) => sum + entry.value);
  }

  @override
  String interpretation({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    if (score <= 11) {
      return 'Malestar psicologico bajo en las ultimas dos semanas.';
    }
    if (score <= 20) {
      return 'Malestar psicologico leve. Conviene seguimiento clinico.';
    }
    if (score <= 27) {
      return 'Malestar psicologico moderado. Se recomienda valoracion profesional.';
    }
    return 'Malestar psicologico alto. Se recomienda atencion profesional prioritaria.';
  }

  @override
  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    if (score <= 11) return 'Bajo';
    if (score <= 20) return 'Leve';
    if (score <= 27) return 'Moderado';
    return 'Alto';
  }
}

