import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ssapp/features/reports/domain/report_models.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/pdf_report_base.dart';

class BdiBaiPdfGenerator extends PdfReportBase {
  final int surveyType;
  final List<Uint8List?> chartImages;

  static String _surveyName(int surveyType) {
    return switch (surveyType) {
      1 => 'BDI-II',
      2 => 'BAI',
      6 => 'ASSIST V3.0',
      7 => 'GDS-15',
      8 => 'Lawton AIVD',
      10 => 'Katz ABVD',
      11 => 'ICIQ-SF',
      12 => 'GHQ-12',
      13 => 'PHQ-9',
      _ => 'BDI-II',
    };
  }

  static String _levelFor(int surveyType, int score) {
    return switch (surveyType) {
      2 => SurveyStatsCalculator.baiLevel(score),
      6 => SurveyStatsCalculator.assistLevel(score),
      7 => SurveyStatsCalculator.gdsLevel(score),
      8 => SurveyStatsCalculator.lawtonLevel(score),
      10 => SurveyStatsCalculator.katzLevel(score),
      11 => SurveyStatsCalculator.iciqsfLevel(score),
      12 => SurveyStatsCalculator.ghq12Level(score),
      13 => SurveyStatsCalculator.phq9Level(score),
      _ => SurveyStatsCalculator.bdiLevel(score),
    };
  }

  static LevelDistribution _distributionFor(int surveyType, List<Map<String, dynamic>> surveys) {
    return switch (surveyType) {
      2 => SurveyStatsCalculator.baiDistribution(surveys),
      6 => SurveyStatsCalculator.assistDistribution(surveys),
      7 => SurveyStatsCalculator.gdsDistribution(surveys),
      8 => SurveyStatsCalculator.lawtonDistribution(surveys),
      10 => SurveyStatsCalculator.katzDistribution(surveys),
      11 => SurveyStatsCalculator.iciqsfDistribution(surveys),
      12 => SurveyStatsCalculator.ghq12Distribution(surveys),
      13 => SurveyStatsCalculator.phq9Distribution(surveys),
      _ => SurveyStatsCalculator.bdiDistribution(surveys),
    };
  }

  // Matches each survey's on-screen color (see the respective
  // `*_report_section.dart` widget's `_color` constant).
  static PdfColor _accentFor(int surveyType) {
    return switch (surveyType) {
      1 => PdfColor.fromHex('#10B981'), // BDI-II
      2 => PdfColor.fromHex('#14B8A6'), // BAI
      6 => PdfColor.fromHex('#6B7FBD'), // ASSIST V3.0
      7 => PdfColor.fromHex('#0EA5E9'), // GDS-15
      8 => PdfColor.fromHex('#14B8A6'), // Lawton AIVD
      10 => PdfColor.fromHex('#0D9488'), // Katz ABVD
      11 => PdfColor.fromHex('#2563EB'), // ICIQ-SF
      12 => PdfColor.fromHex('#0284C7'), // GHQ-12
      13 => PdfColor.fromHex('#9333EA'), // PHQ-9
      _ => PdfColor.fromHex('#10B981'),
    };
  }

  BdiBaiPdfGenerator({required this.surveyType, this.chartImages = const []})
      : super(
          title: 'Reporte ${_surveyName(surveyType)}',
          subtitle: 'Resumen estadístico',
          accentColor: _accentFor(surveyType),
        );

  @override
  Future<Uint8List> generate(List<Map<String, dynamic>> surveys) async {
    final doc = pw.Document();
    final fonts = await loadFonts();
    final scores = surveys.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);
    final dist = _distributionFor(surveyType, surveys);

    final previewRows = surveys.take(20).map((s) {
      final score = SurveyStatsCalculator.calculateSurveyScore(s);
      final level = _levelFor(surveyType, score);
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
        footer: (ctx) => buildFooterBar(ctx, fonts.regular),
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
          buildSectionTitle('Distribución por nivel', fonts.bold),
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
          if (chartImages.isNotEmpty) pw.SizedBox(height: 14),
          ...chartImages.where((image) => image != null).expand(
                (image) => [
                  embedChartImage(image, height: 180),
                  pw.SizedBox(height: 12),
                ],
              ),
          pw.SizedBox(height: 12),
          buildSectionTitle('Últimos registros', fonts.bold),
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
