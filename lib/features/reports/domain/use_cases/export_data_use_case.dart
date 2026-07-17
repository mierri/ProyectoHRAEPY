import 'dart:typed_data';

import 'package:ssapp/features/reports/infrastructure/excel/survey_excel_exporter.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/shared/models/patient_model.dart';

class ExportDataUseCase {
  final SurveyExcelExporter _excelExporter;

  ExportDataUseCase({SurveyExcelExporter? excelExporter})
    : _excelExporter = excelExporter ?? SurveyExcelExporter();

  Future<Uint8List> exportExcel(
    int surveyType,
    List<Map<String, dynamic>> surveys, {
    CustomSurveyDefinition? customDefinition,
    List<PatientModel>? patients,
  }) {
    return _excelExporter.export(
      surveyType,
      surveys,
      customDefinition: customDefinition,
      patients: patients,
    );
  }
}
