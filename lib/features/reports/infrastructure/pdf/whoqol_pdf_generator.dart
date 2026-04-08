import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ssapp/features/reports/domain/report_models.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/pdf_report_base.dart';

class WhoqolPdfGenerator extends PdfReportBase {
  const WhoqolPdfGenerator()
      : super(
          title: 'Reporte WHOQOL-BREF',
          subtitle: 'Calidad de vida',
          accentColor: PdfColors.indigo,
        );

  @override
  Future<Uint8List> generate(List<Map<String, dynamic>> surveys) async {
    final doc = pw.Document();
    final fonts = await loadFonts();
    final report = SurveyStatsCalculator.computeWhoqolReport(surveys);

    final timelineRows = <List<String>>[];
    for (var i = 0; i < surveys.length && i < 20; i++) {
      final s = surveys[i];
      final date = ('${s['created_at'] ?? ''}').split('T').first;
      final global = i < report.globalTimeline.length ? report.globalTimeline[i].toStringAsFixed(0) : '-';
      timelineRows.add([
        '${s['survey_id'] ?? ''}',
        '${s['patient_id'] ?? ''}',
        date,
        global,
      ]);
    }

    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          buildDocHeader(DateTime.now(), surveys.length, fonts.bold, fonts.regular),
          pw.SizedBox(height: 12),
          buildStatsSummaryBox(
            regular: fonts.regular,
            bold: fonts.bold,
            values: {
              'Registros': '${surveys.length}',
              'Media global': report.globalStats.mean.toStringAsFixed(2),
              'Mediana global': report.globalStats.median.toStringAsFixed(2),
              'Q1 más frecuente': _topKey(report.globalItems.q1Distribution),
              'Q2 más frecuente': _topKey(report.globalItems.q2Distribution),
            },
          ),
          pw.SizedBox(height: 12),
          pw.Text('Dominios WHOQOL', style: pw.TextStyle(font: fonts.bold, fontSize: 11)),
          pw.SizedBox(height: 6),
          buildSimpleTable(
            regular: fonts.regular,
            bold: fonts.bold,
            headers: ['Dominio', 'Media', 'Mediana', 'Min', 'Max'],
            rows: [
              _domRow(report.dom1),
              _domRow(report.dom2),
              _domRow(report.dom3),
              _domRow(report.dom4),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text('Últimos registros', style: pw.TextStyle(font: fonts.bold, fontSize: 11)),
          pw.SizedBox(height: 6),
          buildSimpleTable(
            regular: fonts.regular,
            bold: fonts.bold,
            headers: ['Encuesta', 'Paciente', 'Fecha', 'Global'],
            rows: timelineRows,
          ),
        ],
      ),
    );
    return doc.save();
  }

  static List<String> _domRow(WhoqolDomainStats dom) {
    return [
      '${dom.label}',
      dom.mean.toStringAsFixed(2),
      dom.median.toStringAsFixed(2),
      dom.min.toStringAsFixed(0),
      dom.max.toStringAsFixed(0),
    ];
  }

  static String _topKey(Map<String, int> dist) {
    if (dist.isEmpty) {
      return '-';
    }
    return dist.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
