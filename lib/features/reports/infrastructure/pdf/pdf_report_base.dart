import 'dart:typed_data';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

abstract class PdfReportBase {
  final String title;
  final String subtitle;
  final PdfColor accentColor;

  const PdfReportBase({
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  Future<Uint8List> generate(List<Map<String, dynamic>> surveys);

  Future<({pw.Font regular, pw.Font bold})> loadFonts() async {
    return (
      regular: await PdfGoogleFonts.notoSansRegular(),
      bold: await PdfGoogleFonts.notoSansBold(),
    );
  }

  pw.Widget buildDocHeader(DateTime now, int surveyCount, pw.Font bold, pw.Font regular) {
    final date = DateFormat('yyyy-MM-dd').format(now);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 18, color: accentColor)),
        pw.SizedBox(height: 4),
        pw.Text(subtitle, style: pw.TextStyle(font: regular, fontSize: 10)),
        pw.Text('Fecha: $date', style: pw.TextStyle(font: regular, fontSize: 9)),
        pw.Text('Encuestas: $surveyCount', style: pw.TextStyle(font: regular, fontSize: 9)),
      ],
    );
  }

  pw.Widget buildFooterNote(pw.Font regular, pw.Font bold) {
    return pw.Text('Reporte generado por SSApp', style: pw.TextStyle(font: regular, fontSize: 9, fontWeight: pw.FontWeight.bold));
  }

  pw.Widget buildStatsSummaryBox({
    required pw.Font regular,
    required pw.Font bold,
    required Map<String, String> values,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: values.entries
            .map((e) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text('${e.key}: ${e.value}', style: pw.TextStyle(font: regular, fontSize: 10)),
                ))
            .toList(),
      ),
    );
  }

  pw.Widget buildSimpleTable({
    required pw.Font regular,
    required pw.Font bold,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    if (rows.isEmpty) {
      return pw.Text('Sin registros para mostrar.', style: pw.TextStyle(font: regular, fontSize: 10));
    }
    return pw.Table.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: accentColor),
      cellStyle: pw.TextStyle(font: regular, fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      border: null,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  /// Embeds a captured chart PNG as a full-width image in the PDF.
  pw.Widget embedChartImage(Uint8List? png, {double height = 160}) {
    if (png == null) return pw.SizedBox.shrink();
    return pw.Container(
      height: height,
      child: pw.Image(pw.MemoryImage(png), fit: pw.BoxFit.contain),
    );
  }

  /// Renders metric cards as a horizontal row in the PDF.
  pw.Widget buildMetricCardsRow({
    required pw.Font regular,
    required pw.Font bold,
    required List<({String label, String value, String? hint})> cards,
  }) {
    return pw.Row(
      children: cards.map((card) => pw.Expanded(
        child: pw.Container(
          margin: const pw.EdgeInsets.symmetric(horizontal: 4),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: accentColor),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            color: PdfColors.white,
          ),
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(card.label, style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey600)),
            pw.SizedBox(height: 3),
            pw.Text(card.value, style: pw.TextStyle(font: bold, fontSize: 14, color: accentColor)),
            if (card.hint != null)
              pw.Text(card.hint!, style: pw.TextStyle(font: regular, fontSize: 7, color: PdfColors.grey500)),
          ]),
        ),
      )).toList(),
    );
  }

  /// Renders a colored interpretation box.
  pw.Widget buildInterpretationBox({
    required pw.Font regular,
    required String text,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F0F9FF'),
        border: pw.Border(left: pw.BorderSide(color: accentColor, width: 3)),
      ),
      child: pw.Text(text, style: pw.TextStyle(font: regular, fontSize: 9)),
    );
  }

  void drawSector(PdfGraphics canvas, double cx, double cy, double r, double startAngle, double sweepAngle) {
    addArcSegment(canvas, cx, cy, r, startAngle, sweepAngle);
  }

  void drawCircle(PdfGraphics canvas, double cx, double cy, double r) {
    addArcSegment(canvas, cx, cy, r, 0, math.pi * 2);
  }

  void addArcSegment(PdfGraphics canvas, double cx, double cy, double r, double startAngle, double sweepAngle) {
    const segments = 32;
    final step = sweepAngle / segments;
    var angle = startAngle;
    canvas.moveTo(cx, cy);
    for (var i = 0; i <= segments; i++) {
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      canvas.lineTo(x, y);
      angle += step;
    }
    canvas.closePath();
  }
}
