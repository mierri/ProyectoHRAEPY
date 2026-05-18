import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ssapp/core/logger/app_logger.dart';
import 'package:ssapp/features/reports/domain/use_cases/export_data_use_case.dart';
import 'package:ssapp/features/reports/domain/use_cases/generate_report_use_case.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/chart_image_capture.dart';
import 'package:ssapp/features/reports/presentation/viewmodels/survey_report_viewmodels.dart';
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
  bool isLoading = false;
  bool isExporting = false;
  List<Map<String, dynamic>> _surveys = [];

  List<Map<String, dynamic>> get surveys => List.unmodifiable(_surveys);
  SurveyReportViewModel get activeReportViewModel =>
      resolveReportViewModel(selectedSurveyType);

  Future<void> loadReport(SurveyService surveyService, int surveyType) async {
    selectedSurveyType = surveyType;
    isLoading = true;
    notifyListeners();
    try {
      _surveys = _generateReportUseCase.execute(surveyService, surveyType);
    } catch (e, st) {
      AppLogger.error('Error loading report data', e, st);
      _surveys = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Captures the 3 chart images from the current report section (already rendered),
  /// then generates and shares the PDF with those images embedded.
  Future<void> exportPdf(BuildContext context) async {
    isExporting = true;
    notifyListeners();
    try {
      // Wait for any pending frame so RepaintBoundary contents are up to date
      await WidgetsBinding.instance.endOfFrame;

      final keys = activeReportViewModel.chartKeys;
      final images = <Uint8List?>[];
      for (final key in keys) {
        images.add(await captureChart(key, pixelRatio: 2.5));
      }

      final bytes = await activeReportViewModel.generatePdfWithImages(_surveys, images);
      await _shareBytes(bytes, 'reporte_$selectedSurveyType.pdf', 'application/pdf');
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
      final bytes = await _exportDataUseCase.exportCsv(selectedSurveyType, _surveys);
      await _shareBytes(bytes, 'reporte_$selectedSurveyType.csv', 'text/csv');
    } catch (e, st) {
      AppLogger.error('Error exporting CSV', e, st);
    } finally {
      isExporting = false;
      notifyListeners();
    }
  }

  Future<void> _shareBytes(Uint8List bytes, String filename, String mimeType) async {
    if (kIsWeb) {
      await SharePlus.instance.share(
        ShareParams(files: [XFile.fromData(bytes, mimeType: mimeType, name: filename)]),
      );
      return;
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }
}
