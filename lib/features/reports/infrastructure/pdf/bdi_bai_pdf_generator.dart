import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/pdf_report_base.dart';

class BdiBaiPdfGenerator extends PdfReportBase {
  final int surveyType;

  static String _surveyName(int surveyType) {
    return switch (surveyType) {
      2 => 'BAI',
      12 => 'GHQ-12',
      13 => 'PHQ-9',
      _ => 'BDI-II',
    };
  }

  BdiBaiPdfGenerator({required this.surveyType})
      : super(
          title: 'Reporte ${_surveyName(surveyType)}',
          subtitle: 'Resumen estadístico',
          accentColor: PdfColors.blue,
        );

  @override
  Future<Uint8List> generate(List<Map<String, dynamic>> surveys) async {
    final doc = pw.Document();
    final fonts = await loadFonts();
    final scores = surveys.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);
    final dist = switch (surveyType) {
      2 => SurveyStatsCalculator.baiDistribution(surveys),
      12 => SurveyStatsCalculator.ghq12Distribution(surveys),
      13 => SurveyStatsCalculator.phq9Distribution(surveys),
      _ => SurveyStatsCalculator.bdiDistribution(surveys),
    };

    final previewRows = surveys.take(20).map((s) {
      final score = SurveyStatsCalculator.calculateSurveyScore(s);
      final level = switch (surveyType) {
        2 => SurveyStatsCalculator.baiLevel(score),
        12 => SurveyStatsCalculator.ghq12Level(score),
        13 => SurveyStatsCalculator.phq9Level(score),
        _ => SurveyStatsCalculator.bdiLevel(score),
      };
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
              'Tipo': _surveyName(surveyType),
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
