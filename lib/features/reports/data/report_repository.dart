import 'package:ssapp/features/surveys/domain/survey_service.dart';

class ReportRepository {
	List<Map<String, dynamic>> getCompletedSurveysByType(
		SurveyService surveyService,
		int surveyType, {
		int? investigationId,
		int? customSurveyId,
	}) {
		return surveyService
				.getCompletedSurveys()
				.where((s) =>
						(s['survey_type'] as int? ?? 1) == surveyType &&
						(customSurveyId == null ||
								(s['custom_survey_id'] as int?) == customSurveyId) &&
						(investigationId == null ||
								(s['investigation_id'] as int?) == investigationId))
				.toList();
	}
}
