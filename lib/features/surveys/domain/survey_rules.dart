import 'package:ssapp/features/surveys/domain/survey_catalog.dart';
import 'package:ssapp/features/surveys/core/domain/survey_type_handler_registry.dart';
import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';

class SurveyRules {
  static int calculateScore(Map<String, dynamic> survey) {
    final responses = survey['responses'] as List?;
    if (responses == null || responses.isEmpty) return 0;

    final surveyType = survey['survey_type'] as int? ?? SurveyCatalog.bdi;
    final typeCode = SurveyCatalog.typeForId(surveyType);
    final handler = SurveyTypeHandlerRegistry.resolve(typeCode);
    return handler.scoreFromStoredResponses(List<dynamic>.from(responses));
  }

  static List<Map<String, dynamic>> completedSurveys(List<Map<String, dynamic>> surveys) {
    return surveys.where((survey) {
      final responses = survey['responses'] as List?;
      return responses != null && responses.isNotEmpty;
    }).toList();
  }

  static double averageScore(List<Map<String, dynamic>> surveys) {
    final completed = completedSurveys(surveys);
    if (completed.isEmpty) return 0.0;

    final totalScore = completed.fold<int>(0, (sum, survey) {
      return sum + calculateScore(survey);
    });

    return totalScore / completed.length;
  }

  static Map<String, dynamic> statistics(List<Map<String, dynamic>> surveys) {
    final completed = completedSurveys(surveys);
    final scores = completed.map(calculateScore).toList()..sort();
    final synced = surveys.where((s) => s['synced'] == true).length;
    final pending = surveys.where((s) => s['synced'] != true).length;

    return {
      'total': surveys.length,
      'synced': synced,
      'pending': pending,
      'completed': completed.length,
      'incomplete': surveys.length - completed.length,
      'averageScore': averageScore(surveys).toStringAsFixed(1),
      'minScore': scores.isEmpty ? 0 : scores.first,
      'maxScore': scores.isEmpty ? 0 : scores.last,
      'medianScore': scores.isEmpty ? 0 : scores[scores.length ~/ 2],
    };
  }

  static int totalScoreFromResponses(String surveyType, Map<int, int> responses) {
    final handler = SurveyTypeHandlerRegistry.resolve(surveyType);
    return handler.totalScoreFromResponses(responses);
  }

  static String interpretation(
    String surveyType,
    Map<int, int> responses,
    List<SurveyQuestion> questions,
  ) {
    final handler = SurveyTypeHandlerRegistry.resolve(surveyType);
    final score = totalScoreFromResponses(surveyType, responses);
    return handler.interpretation(
      score: score,
      responses: responses,
      questionsCount: questions.length,
    );
  }

  static String severityLevel(
    String surveyType,
    Map<int, int> responses,
    List<SurveyQuestion> questions,
  ) {
    final handler = SurveyTypeHandlerRegistry.resolve(surveyType);
    final score = totalScoreFromResponses(surveyType, responses);
    return handler.severityLevel(
      score: score,
      responses: responses,
      questionsCount: questions.length,
    );
  }
}