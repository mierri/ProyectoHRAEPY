import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/pdf_report_base.dart';

class BdiBaiPdfGenerator extends PdfReportBase {
  final int surveyType;

  const BdiBaiPdfGenerator({required this.surveyType})
      : super(
          title: 'Reporte ${surveyType == 1 ? 'BDI-II' : 'BAI'}',
          subtitle: 'Resumen estadístico',
          accentColor: PdfColors.blue,
        );

  @override
  Future<Uint8List> generate(List<Map<String, dynamic>> surveys) async {
    final doc = pw.Document();
    final fonts = await loadFonts();
    final scores = surveys.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);
    final dist = surveyType == 1
        ? SurveyStatsCalculator.bdiDistribution(surveys)
        : SurveyStatsCalculator.baiDistribution(surveys);

    final previewRows = surveys.take(20).map((s) {
      final score = SurveyStatsCalculator.calculateSurveyScore(s);
      final level = surveyType == 1
          ? SurveyStatsCalculator.bdiLevel(score)
          : SurveyStatsCalculator.baiLevel(score);
      final date = ('${s['created_at'] ?? ''}').split('T').first;
      return [
        '${s['survey_id'] ?? ''}',
        '${s['patient_id'] ?? ''}',
        date,
        '$score',
        level,
      ];
    }).toList();

    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          buildDocHeader(DateTime.now(), surveys.length, fonts.bold, fonts.regular),
          pw.SizedBox(height: 12),
          buildStatsSummaryBox(
            regular: fonts.regular,
            bold: fonts.bold,
            values: {
              'Tipo': surveyType == 1 ? 'BDI-II' : 'BAI',
              'Registros': '${surveys.length}',
              'Media': stats.mean.toStringAsFixed(2),
              'Mediana': stats.median.toStringAsFixed(2),
              'Desv. estándar': stats.stdDev.toStringAsFixed(2),
              'Min - Max': '${stats.min.toStringAsFixed(0)} - ${stats.max.toStringAsFixed(0)}',
            },
          ),
          pw.SizedBox(height: 12),
          pw.Text('Distribución por nivel', style: pw.TextStyle(font: fonts.bold, fontSize: 11)),
          pw.SizedBox(height: 6),
          buildSimpleTable(
            regular: fonts.regular,
            bold: fonts.bold,
            headers: ['Nivel', 'Rango', 'Cantidad', '%'],
            rows: dist.counts.entries.map((entry) {
              final pct = dist.pct(entry.key).toStringAsFixed(1);
              return [entry.key, dist.ranges[entry.key] ?? '', '${entry.value}', '$pct%'];
            }).toList(),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Últimos registros', style: pw.TextStyle(font: fonts.bold, fontSize: 11)),
          pw.SizedBox(height: 6),
          buildSimpleTable(
            regular: fonts.regular,
            bold: fonts.bold,
            headers: ['Encuesta', 'Paciente', 'Fecha', 'Score', 'Nivel'],
            rows: previewRows,
          ),
        ],
      ),
    );
    return doc.save();
  }
}
