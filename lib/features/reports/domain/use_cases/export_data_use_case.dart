import 'dart:typed_data';

import 'package:ssapp/features/reports/infrastructure/csv/survey_csv_exporter.dart';

class ExportDataUseCase {
	final SurveyCsvExporter _csvExporter;

	ExportDataUseCase({SurveyCsvExporter? csvExporter})
			: _csvExporter = csvExporter ?? SurveyCsvExporter();

	Future<Uint8List> exportCsv(
		int surveyType,
		List<Map<String, dynamic>> surveys,
	) {
		return _csvExporter.export(surveyType, surveys);
	}
}
