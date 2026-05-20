import 'package:ssapp/features/surveys/domain/survey_service.dart';

class ReportRepository {
	List<Map<String, dynamic>> getCompletedSurveysByType(
		SurveyService surveyService,
		int surveyType, {
		int? investigationId,
	}) {
		return surveyService
				.getCompletedSurveys()
				.where((s) =>
						(s['survey_type'] as int? ?? 1) == surveyType &&
						(investigationId == null ||
								(s['investigation_id'] as int?) == investigationId))
				.toList();
	}
}
