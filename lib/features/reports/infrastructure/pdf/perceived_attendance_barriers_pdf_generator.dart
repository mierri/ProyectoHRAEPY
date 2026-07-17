import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ssapp/features/reports/domain/perceived_attendance_barriers_report_support.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/pdf_report_base.dart';

class PerceivedAttendanceBarriersPdfGenerator extends PdfReportBase {
  final List<Uint8List?> chartImages;

  // Matches the on-screen color in PerceivedAttendanceBarriersReportSection.
  PerceivedAttendanceBarriersPdfGenerator({
    this.chartImages = const [],
  }) : super(
          title: 'Reporte Barreras Percibidas para la Asistencia',
          subtitle: 'Resumen de motivos de inasistencia reciente y futura',
          accentColor: PdfColor.fromHex('#BE123C'),
        );

  @override
  Future<Uint8List> generate(List<Map<String, dynamic>> surveys) async {
    final fonts = await loadFonts();
    final summary = PerceivedAttendanceBarriersReportSummary.fromSurveys(
      surveys,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');
    final doc = pw.Document();

    final latestDate = summary.latestSurveyDate == null
        ? '—'
        : dateFormat.format(summary.latestSurveyDate!);

    final previewRows = summary.records.take(20).map((record) {
      final date = record.createdAtDate == null
          ? (record.createdAt.length >= 10
              ? record.createdAt.substring(0, 10)
              : record.createdAt)
          : dateFormat.format(record.createdAtDate!);
      return [
        date,
        record.recentReason?.resolvedLabel ?? '—',
        record.primaryFutureReason?.resolvedLabel ?? '—',
        record.secondaryFutureReason?.resolvedLabel ?? '—',
        record.tertiaryFutureReason?.resolvedLabel ?? '—',
      ];
    }).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        footer: (ctx) => buildFooterBar(ctx, fonts.regular),
        build: (_) => [
          buildDocHeader(
            DateTime.now(),
            summary.total,
            fonts.bold,
            fonts.regular,
          ),
          pw.SizedBox(height: 12),
          buildInterpretationBox(
            regular: fonts.regular,
            text:
                'Este reporte resume los principales motivos de inasistencia reciente y las barreras percibidas para futuras consultas. '
                'La encuesta no genera puntaje clínico.',
          ),
          pw.SizedBox(height: 12),
          buildMetricCardsRow(
            regular: fonts.regular,
            bold: fonts.bold,
            cards: [
              (
                label: 'Total encuestas',
                value: '${summary.total}',
                hint: 'Registros incluidos',
              ),
              (
                label: 'Con antecedente reciente',
                value:
                    '${summary.antecedentSectionPercentage.toStringAsFixed(1)}%',
                hint: '${summary.withAntecedentSection} pacientes',
              ),
              (
                label: 'Motivo futuro #1',
                value: summary.topPrimaryReason,
                hint: 'Más frecuente como principal',
              ),
              (
                label: 'Motivo global futuro',
                value: summary.topOverallFutureReason,
                hint: 'Última encuesta: $latestDate',
              ),
            ],
          ),
          if (chartImages.isNotEmpty) pw.SizedBox(height: 14),
          ...chartImages.where((image) => image != null).expand(
                (image) => [
                  embedChartImage(image, height: 180),
                  pw.SizedBox(height: 12),
                ],
              ),
          buildSectionTitle('Últimos registros', fonts.bold),
          pw.SizedBox(height: 6),
          buildSimpleTable(
            regular: fonts.regular,
            bold: fonts.bold,
            headers: const [
              'Fecha',
              'Motivo reciente',
              'Motivo 1',
              'Motivo 2',
              'Motivo 3',
            ],
            rows: previewRows,
          ),
        ],
      ),
    );

    return doc.save();
  }
}
