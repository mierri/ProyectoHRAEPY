import 'dart:typed_data';

import 'package:ssapp/features/reports/infrastructure/csv/survey_csv_exporter.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';

class ExportDataUseCase {
	final SurveyCsvExporter _csvExporter;

	ExportDataUseCase({SurveyCsvExporter? csvExporter})
			: _csvExporter = csvExporter ?? SurveyCsvExporter();

	Future<Uint8List> exportCsv(
		int surveyType,
		List<Map<String, dynamic>> surveys, {
		CustomSurveyDefinition? customDefinition,
	}) {
		return _csvExporter.export(surveyType, surveys, customDefinition: customDefinition);
	}
}
