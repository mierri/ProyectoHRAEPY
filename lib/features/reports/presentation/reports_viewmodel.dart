import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ssapp/core/logger/app_logger.dart';
import 'package:ssapp/features/reports/infrastructure/csv/survey_csv_exporter.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/bdi_bai_pdf_generator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/osteoporosis_pdf_generator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/sf36_pdf_generator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/whoqol_pdf_generator.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';

class ReportsViewModel extends ChangeNotifier {
  int selectedSurveyType = 1;
  bool isLoading = false;
  bool isExporting = false;
  List<Map<String, dynamic>> _surveys = [];

  List<Map<String, dynamic>> get surveys => List.unmodifiable(_surveys);

  Future<void> loadReport(SurveyService surveyService, int surveyType) async {
    selectedSurveyType = surveyType;
    isLoading = true;
    notifyListeners();
    try {
      _surveys = surveyService
          .getCompletedSurveys()
          .where((s) => (s['survey_type'] as int? ?? 1) == surveyType)
          .toList();
    } catch (e, st) {
      AppLogger.error('Error loading report data', e, st);
      _surveys = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> exportPdf(BuildContext context) async {
    isExporting = true;
    notifyListeners();
    try {
      final bytes = switch (selectedSurveyType) {
        1 || 2 => await BdiBaiPdfGenerator(surveyType: selectedSurveyType).generate(_surveys),
        3 => await const WhoqolPdfGenerator().generate(_surveys),
        5 => await const Sf36PdfGenerator().generate(_surveys),
        9 => await const OsteoporosisPdfGenerator().generate(_surveys),
        _ => await BdiBaiPdfGenerator(surveyType: selectedSurveyType).generate(_surveys),
      };
      await _shareBytes(bytes, 'reporte_${selectedSurveyType}.pdf', 'application/pdf');
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
      final bytes = await SurveyCsvExporter().export(selectedSurveyType, _surveys);
      await _shareBytes(bytes, 'reporte_${selectedSurveyType}.csv', 'text/csv');
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
