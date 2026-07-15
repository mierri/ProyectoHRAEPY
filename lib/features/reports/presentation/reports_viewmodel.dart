import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/core/logger/app_logger.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/shared/models/patient_model.dart';
import 'package:ssapp/features/reports/domain/use_cases/export_data_use_case.dart';
import 'package:ssapp/features/reports/domain/use_cases/generate_report_use_case.dart';
import 'package:ssapp/features/reports/infrastructure/export/report_file_exporter.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/chart_image_capture.dart';
import 'package:ssapp/features/reports/presentation/viewmodels/survey_report_viewmodels.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';

class ReportsViewModel extends ChangeNotifier {
  final GenerateReportUseCase _generateReportUseCase;
  final ExportDataUseCase _exportDataUseCase;

  ReportsViewModel({
    GenerateReportUseCase? generateReportUseCase,
    ExportDataUseCase? exportDataUseCase,
  })  : _generateReportUseCase = generateReportUseCase ?? GenerateReportUseCase(),
        _exportDataUseCase = exportDataUseCase ?? ExportDataUseCase();

  int selectedSurveyType = 1;
  CustomSurveyDefinition? selectedCustomDefinition;
  bool isLoading = false;
  bool isExporting = false;
  List<Map<String, dynamic>> _surveys = [];

  List<Map<String, dynamic>> get surveys => List.unmodifiable(_surveys);
  SurveyReportViewModel get activeReportViewModel =>
      resolveReportViewModel(selectedSurveyType, customDefinition: selectedCustomDefinition);

  Future<void> loadReport(
    SurveyService surveyService,
    int surveyType, {
    int? investigationId,
    int? customSurveyId,
    CustomSurveyDefinition? customDefinition,
    List<PatientModel>? patients,
  }) async {
    selectedSurveyType = surveyType;
    selectedCustomDefinition = customDefinition;
    isLoading = true;
    notifyListeners();
    try {
      _surveys = _generateReportUseCase.execute(
        surveyService,
        surveyType,
        investigationId: investigationId,
        customSurveyId: customSurveyId,
      );
      if (surveyType == 9 && patients != null) {
        _surveys = _withPatientBiometrics(_surveys, patients);
      }
    } catch (e, st) {
      AppLogger.error('Error loading report data', e, st);
      _surveys = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Osteoporosis survey records don't carry weight/height/birth_date/sex —
  /// those live only on the patient record, so the on-screen report (BMI
  /// average, age groups, sex breakdown) needs them merged in per patient_id.
  List<Map<String, dynamic>> _withPatientBiometrics(
    List<Map<String, dynamic>> surveys,
    List<PatientModel> patients,
  ) {
    final patientsById = <int, PatientModel>{
      for (final p in patients) p.patientId: p,
    };
    return surveys.map((survey) {
      final patientId = survey['patient_id'] as int?;
      final patient = patientId != null ? patientsById[patientId] : null;
      if (patient == null) return survey;
      return {
        ...survey,
        if (patient.weight != null) 'weight': patient.weight,
        if (patient.height != null) 'height': patient.height,
        'birth_date': patient.birthDate.toIso8601String(),
        'sex': patient.gender,
      };
    }).toList();
  }

  /// Captures the 3 chart images from the current report section (already rendered),
  /// then generates and shares the PDF with those images embedded.
  Future<void> exportPdf(BuildContext context) async {
    isExporting = true;
    notifyListeners();
    try {
      final bytes = await _buildPdfBytes();
      await saveReportFile(
        bytes: bytes,
        filename: 'reporte_$selectedSurveyType.pdf',
        mimeType: 'application/pdf',
      );
    } catch (e, st) {
      AppLogger.error('Error exporting PDF', e, st);
    } finally {
      isExporting = false;
      notifyListeners();
    }
  }

  Future<void> exportCsv(BuildContext context) async {
    isExporting = true;
    notifyListeners();
    try {
      final patientService = context.read<PatientService>();
      if (patientService.patients.isEmpty) {
        await patientService.loadPatients();
      }
      final bytes = await _exportDataUseCase.exportCsv(
        selectedSurveyType,
        _surveys,
        customDefinition: selectedCustomDefinition,
        patients: patientService.patients,
      );
      await saveReportFile(
        bytes: bytes,
        filename: 'reporte_$selectedSurveyType.csv',
        mimeType: 'text/csv',
      );
    } catch (e, st) {
      AppLogger.error('Error exporting CSV', e, st);
    } finally {
      isExporting = false;
      notifyListeners();
    }
  }

  Future<void> printPdf(BuildContext context) async {
    isExporting = true;
    notifyListeners();
    try {
      final bytes = await _buildPdfBytes();
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e, st) {
      AppLogger.error('Error printing PDF', e, st);
    } finally {
      isExporting = false;
      notifyListeners();
    }
  }

  Future<Uint8List> _buildPdfBytes() async {
    if (!kIsWeb) {
      await WidgetsBinding.instance.endOfFrame;
    }

    final keys = activeReportViewModel.chartKeys;
    final images = <Uint8List?>[];
    for (final key in keys) {
      images.add(await captureChart(key, pixelRatio: 2.0));
    }

    return activeReportViewModel.generatePdfWithImages(_surveys, images);
  }
}
