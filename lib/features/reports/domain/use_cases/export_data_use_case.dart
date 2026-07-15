import 'dart:typed_data';

import 'package:ssapp/features/reports/infrastructure/csv/survey_csv_exporter.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/shared/models/patient_model.dart';

class ExportDataUseCase {
	final SurveyCsvExporter _csvExporter;

	ExportDataUseCase({SurveyCsvExporter? csvExporter})
			: _csvExporter = csvExporter ?? SurveyCsvExporter();

	Future<Uint8List> exportCsv(
		int surveyType,
		List<Map<String, dynamic>> surveys, {
		CustomSurveyDefinition? customDefinition,
		List<PatientModel>? patients,
	}) {
		return _csvExporter.export(
			surveyType,
			surveys,
			customDefinition: customDefinition,
			patients: patients,
		);
	}
}
