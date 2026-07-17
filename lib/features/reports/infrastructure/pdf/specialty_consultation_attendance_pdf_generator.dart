import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ssapp/features/reports/domain/specialty_consultation_attendance_report_support.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/pdf_report_base.dart';

class SpecialtyConsultationAttendancePdfGenerator extends PdfReportBase {
  final List<Uint8List?> chartImages;

  // Matches the on-screen color in SpecialtyConsultationAttendanceReportSection.
  SpecialtyConsultationAttendancePdfGenerator({
    this.chartImages = const [],
  }) : super(
          title: 'Reporte Asistencia en Consulta de Especialidad',
          subtitle: 'Resumen de asistencia y acceso a consultas de especialidad',
          accentColor: PdfColor.fromHex('#B45309'),
        );

  @override
  Future<Uint8List> generate(List<Map<String, dynamic>> surveys) async {
    final fonts = await loadFonts();
    final summary =
        SpecialtyConsultationAttendanceReportSummary.fromSurveys(surveys);
    final doc = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    final previewRows = summary.records.take(20).map((record) {
      final date = record.createdAtDate == null
          ? (record.createdAt.length >= 10
              ? record.createdAt.substring(0, 10)
              : record.createdAt)
          : dateFormat.format(record.createdAtDate!);
      return [
        date,
        record.nombreCompleto.isEmpty ? '—' : record.nombreCompleto,
        record.especialidad.isEmpty ? '—' : record.especialidad,
        record.transportePrivadoLabel.isEmpty
            ? '—'
            : record.transportePrivadoLabel,
        record.faltoCitaLabel.isEmpty ? '—' : record.faltoCitaLabel,
        record.citasPerdidasLabel.isEmpty ? '—' : record.citasPerdidasLabel,
      ];
    }).toList();

    final latestDate = summary.latestSurveyDate == null
        ? '—'
        : dateFormat.format(summary.latestSurveyDate!);

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
                'Este reporte describe patrones de asistencia, transporte y especialidad médica. '
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
                label: 'Con transporte privado',
                value:
                    '${summary.privateTransportPercentage.toStringAsFixed(1)}%',
                hint: '${summary.withPrivateTransport} pacientes',
              ),
              (
                label: 'Con inasistencia reciente',
                value:
                    '${summary.missedAppointmentPercentage.toStringAsFixed(1)}%',
                hint: '${summary.missedAppointmentYes} pacientes',
              ),
              (
                label: 'Especialidad más frecuente',
                value: summary.mostCommonSpecialty,
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
              'Nombre',
              'Especialidad',
              'Transporte',
              'Faltó',
              'Citas perdidas',
            ],
            rows: previewRows,
          ),
        ],
      ),
    );

    return doc.save();
  }
}
