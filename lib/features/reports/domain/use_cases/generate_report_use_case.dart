import 'package:ssapp/features/reports/data/report_repository.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';

class GenerateReportUseCase {
	final ReportRepository _repository;

	GenerateReportUseCase({ReportRepository? repository})
			: _repository = repository ?? ReportRepository();

	List<Map<String, dynamic>> execute(
		SurveyService surveyService,
		int surveyType,
	) {
		return _repository.getCompletedSurveysByType(surveyService, surveyType);
	}
}
