import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';

/// Generic PDF generator that embeds captured chart images.
/// Used by all survey types when [generatePdfWithImages] is called.
class GenericPdfReportGenerator {
  final String surveyName;
  final List<Map<String, dynamic>> surveys;
  final List<Uint8List?> chartImages;

  const GenericPdfReportGenerator({
    required this.surveyName,
    required this.surveys,
    required this.chartImages,
  });

  Future<Uint8List> generate() async {
    final regular = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();

    final scores = surveys.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = scores.isEmpty ? null : SurveyStatsCalculator.computeBasicStats(scores);
    final now = DateTime.now();
    final date = DateFormat('dd/MM/yyyy HH:mm').format(now);

    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (ctx) => _buildHeader(ctx, bold, regular, date),
      footer: (ctx) => _buildFooter(ctx, regular),
      build: (ctx) => [
        // Metric summary box
        if (stats != null) _buildMetricBox(stats, regular, bold),
        pw.SizedBox(height: 16),
        // Chart images
        ...chartImages.where((img) => img != null).map((img) => pw.Column(children: [
          pw.Image(pw.MemoryImage(img!), fit: pw.BoxFit.contain, height: 200),
          pw.SizedBox(height: 14),
        ])),
        // Recent surveys table
        pw.SizedBox(height: 8),
        _buildSurveysTable(regular, bold),
      ],
    ));

    return doc.save();
  }

  pw.Widget _buildHeader(pw.Context ctx, pw.Font bold, pw.Font regular, String date) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text('Reporte — $surveyName',
          style: pw.TextStyle(font: bold, fontSize: 16, color: const PdfColor(0.055, 0.478, 0.525))),
      pw.SizedBox(height: 4),
      pw.Text('Generado: $date  |  Encuestas: ${surveys.length}',
          style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.grey600)),
      pw.Divider(height: 16, color: PdfColors.grey300),
    ]);
  }

  pw.Widget _buildFooter(pw.Context ctx, pw.Font regular) {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Text('Reporte generado por SSApp', style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey500)),
      pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}',
          style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey500)),
    ]);
  }

  pw.Widget _buildMetricBox(dynamic stats, pw.Font regular, pw.Font bold) {
    final metrics = [
      ('Media', stats.mean.toStringAsFixed(1)),
      ('Moda', stats.mode.toStringAsFixed(0)),
      ('Desv. Est.', stats.stdDev.toStringAsFixed(1)),
      ('Total encuestas', '${stats.count}'),
    ];
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: const PdfColor(0.941, 0.988, 0.976),
        border: pw.Border.all(color: const PdfColor(0.055, 0.478, 0.525), width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: metrics.map((m) => pw.Column(children: [
          pw.Text(m.$1, style: pw.TextStyle(font: regular, fontSize: 9, color: PdfColors.grey600)),
          pw.SizedBox(height: 3),
          pw.Text(m.$2,
              style: pw.TextStyle(font: bold, fontSize: 16, color: const PdfColor(0.055, 0.478, 0.525))),
        ])).toList(),
      ),
    );
  }

  pw.Widget _buildSurveysTable(pw.Font regular, pw.Font bold) {
    final last20 = surveys.take(20).toList();
    if (last20.isEmpty) return pw.SizedBox.shrink();

    final rows = last20.map((s) {
      final date = DateFormat('dd/MM/yy').format(DateTime.parse(s['created_at'] as String));
      final score = SurveyStatsCalculator.calculateSurveyScore(s);
      final patId = s['patient_id']?.toString() ?? '—';
      return [date, patId, '$score'];
    }).toList();

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text('Últimas ${last20.length} encuestas',
          style: pw.TextStyle(font: bold, fontSize: 11)),
      pw.SizedBox(height: 6),
      pw.Table.fromTextArray(
        headers: ['Fecha', 'Paciente ID', 'Puntaje'],
        data: rows,
        headerStyle: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white),
        headerDecoration: const pw.BoxDecoration(color: PdfColor(0.055, 0.478, 0.525)),
        cellStyle: pw.TextStyle(font: regular, fontSize: 9),
        border: null,
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      ),
    ]);
  }
}
