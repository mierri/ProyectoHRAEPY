import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/pdf_report_base.dart';

class OsteoporosisPdfGenerator extends PdfReportBase {
  final List<Uint8List?> chartImages;

  // Matches the on-screen color in OsteoporosisReportSection.
  OsteoporosisPdfGenerator({this.chartImages = const []})
      : super(
          title: 'Reporte Osteoporosis',
          subtitle: 'Riesgo de fractura',
          accentColor: PdfColor.fromHex('#145374'),
        );

  @override
  Future<Uint8List> generate(List<Map<String, dynamic>> surveys) async {
    final doc = pw.Document();
    final fonts = await loadFonts();
    final scores = surveys
        .map((s) => s['score'] as int? ?? SurveyStatsCalculator.calculateSurveyScore(s))
        .toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);

    var low = 0;
    var high = 0;
    var unknown = 0;
    for (final s in surveys) {
      final risk = (s['risk_level'] as String?)?.toLowerCase();
      if (risk == 'high') {
        high++;
      } else if (risk == 'low') {
        low++;
      } else {
        unknown++;
      }
    }

    final previewRows = surveys.take(20).map((s) {
      final date = ('${s['created_at'] ?? ''}').split('T').first;
      final score = s['score'] as int? ?? SurveyStatsCalculator.calculateSurveyScore(s);
      return [
        '${s['survey_id'] ?? ''}',
        '${s['patient_id'] ?? ''}',
        date,
        '$score',
        '${s['risk_level'] ?? 'n/a'}',
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
              'Registros': '${surveys.length}',
              'Media score': stats.mean.toStringAsFixed(2),
              'Mediana score': stats.median.toStringAsFixed(2),
              'Riesgo bajo': '$low',
              'Riesgo alto': '$high',
              'Sin etiqueta': '$unknown',
            },
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
            headers: ['Encuesta', 'Paciente', 'Fecha', 'Score', 'Riesgo'],
            rows: previewRows,
          ),
        ],
      ),
    );
    return doc.save();
  }
}
