import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ssapp/features/reports/domain/report_models.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/pdf_report_base.dart';

class Sf36PdfGenerator extends PdfReportBase {
  const Sf36PdfGenerator()
      : super(
          title: 'Reporte SF-36',
          subtitle: 'Estado de salud',
          accentColor: PdfColors.green,
        );

  @override
  Future<Uint8List> generate(List<Map<String, dynamic>> surveys) async {
    final doc = pw.Document();
    final fonts = await loadFonts();
    final report = SurveyStatsCalculator.computeSF36Report(surveys);

    final timelineRows = <List<String>>[];
    for (var i = 0; i < surveys.length && i < 20; i++) {
      final s = surveys[i];
      final date = ('${s['created_at'] ?? ''}').split('T').first;
      final global = i < report.globalTimeline.length ? report.globalTimeline[i].toStringAsFixed(1) : '-';
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
              'Media global (0-100)': report.globalStats.mean.toStringAsFixed(2),
              'Mediana global': report.globalStats.median.toStringAsFixed(2),
              'Desv. estándar': report.globalStats.stdDev.toStringAsFixed(2),
            },
          ),
          pw.SizedBox(height: 12),
          pw.Text('Dimensiones SF-36', style: pw.TextStyle(font: fonts.bold, fontSize: 11)),
          pw.SizedBox(height: 6),
          buildSimpleTable(
            regular: fonts.regular,
            bold: fonts.bold,
            headers: ['Dimensión', 'Media', 'Mediana', 'Min', 'Max'],
            rows: [
              _dimRow(report.physicalFunctioning),
              _dimRow(report.rolePhysical),
              _dimRow(report.bodilyPain),
              _dimRow(report.generalHealth),
              _dimRow(report.vitality),
              _dimRow(report.socialFunctioning),
              _dimRow(report.roleEmotional),
              _dimRow(report.mentalHealth),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text('Últimos registros', style: pw.TextStyle(font: fonts.bold, fontSize: 11)),
          pw.SizedBox(height: 6),
          buildSimpleTable(
            regular: fonts.regular,
            bold: fonts.bold,
            headers: ['Encuesta', 'Paciente', 'Fecha', 'Global 0-100'],
            rows: timelineRows,
          ),
        ],
      ),
    );
    return doc.save();
  }

  static List<String> _dimRow(SF36DimensionStats dim) {
    return [
      dim.label,
      dim.mean.toStringAsFixed(2),
      dim.median.toStringAsFixed(2),
      dim.min.toStringAsFixed(1),
      dim.max.toStringAsFixed(1),
    ];
  }
}
