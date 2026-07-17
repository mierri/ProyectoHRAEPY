import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/pdf_report_base.dart';

/// Generic PDF generator that embeds captured chart images.
/// Used by all survey types when [generatePdfWithImages] is called and no
/// dedicated generator exists for that survey type.
class GenericPdfReportGenerator extends PdfReportBase {
  final List<Map<String, dynamic>> surveys;
  final List<Uint8List?> chartImages;

  GenericPdfReportGenerator({
    required String surveyName,
    required this.surveys,
    required this.chartImages,
    PdfColor? accentColor,
  }) : super(
          title: 'Reporte — $surveyName',
          subtitle: 'Resumen estadístico',
          accentColor: accentColor ?? AppPdfColors.tertiary,
        );

  @override
  Future<Uint8List> generate([List<Map<String, dynamic>>? _]) async {
    final fonts = await loadFonts();
    final scores = surveys.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = scores.isEmpty ? null : SurveyStatsCalculator.computeBasicStats(scores);

    final last20 = surveys.take(20).toList();
    final previewRows = last20.map((s) {
      final date = DateFormat('dd/MM/yy').format(DateTime.parse(s['created_at'] as String));
      final score = SurveyStatsCalculator.calculateSurveyScore(s);
      final patId = s['patient_id']?.toString() ?? '—';
      return [date, patId, '$score'];
    }).toList();

    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      footer: (ctx) => buildFooterBar(ctx, fonts.regular),
      build: (ctx) => [
        buildDocHeader(DateTime.now(), surveys.length, fonts.bold, fonts.regular),
        pw.SizedBox(height: 12),
        if (stats != null)
          buildStatsSummaryBox(
            regular: fonts.regular,
            bold: fonts.bold,
            values: {
              'Media': stats.mean.toStringAsFixed(1),
              'Moda': stats.mode.toStringAsFixed(0),
              'Desv. estándar': stats.stdDev.toStringAsFixed(1),
              'Total encuestas': '${stats.count}',
            },
          ),
        if (chartImages.isNotEmpty) pw.SizedBox(height: 14),
        ...chartImages.where((image) => image != null).expand(
              (image) => [
                embedChartImage(image, height: 180),
                pw.SizedBox(height: 12),
              ],
            ),
        pw.SizedBox(height: 8),
        buildSectionTitle('Últimas ${previewRows.length} encuestas', fonts.bold),
        pw.SizedBox(height: 6),
        buildSimpleTable(
          regular: fonts.regular,
          bold: fonts.bold,
          headers: const ['Fecha', 'Paciente ID', 'Puntaje'],
          rows: previewRows,
        ),
      ],
    ));

    return doc.save();
  }
}
