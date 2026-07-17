import 'dart:typed_data';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Palette mirrored from the app's Material theme
/// (see lib/shared/utils/theme.dart) so generated PDF reports look like part
/// of the same product instead of a generic default report.
class AppPdfColors {
  AppPdfColors._();

  static final primary = PdfColor.fromHex('#8CB8FF');
  static final primaryContainer = PdfColor.fromHex('#D8E6FF');
  static final secondary = PdfColor.fromHex('#6B7FBD');
  static final tertiary = PdfColor.fromHex('#5EC4C1');
  static final error = PdfColor.fromHex('#BA1A1A');

  static final ink = PdfColor.fromHex('#1A1B1E');
  static final muted = PdfColor.fromHex('#75777F');
  static final outline = PdfColor.fromHex('#E1E2EC');
}

PdfColor _mix(PdfColor a, PdfColor b, double t) => PdfColor(
      a.red + (b.red - a.red) * t,
      a.green + (b.green - a.green) * t,
      a.blue + (b.blue - a.blue) * t,
    );

/// Lightens [color] toward white by [amount] (0-1). Used for soft tints of
/// each report's accent color (card backgrounds, zebra rows, pills).
PdfColor _tint(PdfColor color, double amount) => _mix(color, PdfColors.white, amount);

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

  /// Masthead: a brand mark with the title/subtitle on the left and
  /// date/count pills on the right, over a soft tint of [accentColor].
  pw.Widget buildDocHeader(DateTime now, int surveyCount, pw.Font bold, pw.Font regular) {
    final date = DateFormat('dd/MM/yyyy').format(now);
    final soft = _tint(accentColor, 0.9);

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: pw.BoxDecoration(
        color: soft,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 34,
                height: 34,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: accentColor),
                child: pw.Text('S', style: pw.TextStyle(font: bold, fontSize: 15, color: PdfColors.white)),
              ),
              pw.SizedBox(width: 10),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 18, color: AppPdfColors.ink)),
                  pw.SizedBox(height: 2),
                  pw.Text(subtitle, style: pw.TextStyle(font: regular, fontSize: 9, color: AppPdfColors.muted)),
                ],
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _pill(regular: regular, bold: bold, label: 'Fecha', value: date),
              pw.SizedBox(height: 5),
              _pill(regular: regular, bold: bold, label: 'Encuestas', value: '$surveyCount'),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _pill({
    required pw.Font regular,
    required pw.Font bold,
    required String label,
    required String value,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: accentColor, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Text('$label: $value', style: pw.TextStyle(font: bold, fontSize: 8, color: accentColor)),
    );
  }

  /// Footer bar with the brand note on the left and the page number on the
  /// right, separated from the content by a thin rule. Pass as the
  /// `footer:` callback of [pw.MultiPage] so page numbers stay accurate.
  pw.Widget buildFooterBar(pw.Context ctx, pw.Font regular) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: AppPdfColors.outline, width: 0.75)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Reporte generado por SSApp',
              style: pw.TextStyle(font: regular, fontSize: 8, color: AppPdfColors.muted)),
          pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}',
              style: pw.TextStyle(font: regular, fontSize: 8, color: AppPdfColors.muted)),
        ],
      ),
    );
  }

  /// Simple brand note without page numbers. Prefer [buildFooterBar] as the
  /// `footer:` callback of a [pw.MultiPage] so pages are numbered.
  pw.Widget buildFooterNote(pw.Font regular, pw.Font bold) {
    return pw.Text('Reporte generado por SSApp',
        style: pw.TextStyle(font: bold, fontSize: 9, color: AppPdfColors.muted));
  }

  /// A small colored accent bar next to a section title, used to break up
  /// long reports into clearly labeled sections.
  pw.Widget buildSectionTitle(String text, pw.Font bold) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(width: 3, height: 12, color: accentColor),
        pw.SizedBox(width: 6),
        pw.Text(text, style: pw.TextStyle(font: bold, fontSize: 11, color: AppPdfColors.ink)),
      ],
    );
  }

  /// Stat card with a colored top bar and a two-column grid of label/value
  /// pairs, replacing the old plain bordered box.
  pw.Widget buildStatsSummaryBox({
    required pw.Font regular,
    required pw.Font bold,
    required Map<String, String> values,
  }) {
    final entries = values.entries.toList();
    final rows = <pw.Widget>[];
    for (var i = 0; i < entries.length; i += 2) {
      final first = entries[i];
      final second = i + 1 < entries.length ? entries[i + 1] : null;
      rows.add(pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: _statEntry(first, regular, bold)),
            pw.Expanded(child: second != null ? _statEntry(second, regular, bold) : pw.SizedBox()),
          ],
        ),
      ));
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: AppPdfColors.outline, width: 0.75),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            height: 4,
            decoration: pw.BoxDecoration(
              color: accentColor,
              borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(10)),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: rows),
          ),
        ],
      ),
    );
  }

  pw.Widget _statEntry(MapEntry<String, String> entry, pw.Font regular, pw.Font bold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(entry.key, style: pw.TextStyle(font: regular, fontSize: 8, color: AppPdfColors.muted)),
        pw.SizedBox(height: 2),
        pw.Text(entry.value, style: pw.TextStyle(font: bold, fontSize: 13, color: accentColor)),
      ],
    );
  }

  pw.Widget buildSimpleTable({
    required pw.Font regular,
    required pw.Font bold,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    if (rows.isEmpty) {
      return pw.Text('Sin registros para mostrar.',
          style: pw.TextStyle(font: regular, fontSize: 10, color: AppPdfColors.muted));
    }
    return pw.Table.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white),
      headerDecoration: pw.BoxDecoration(color: accentColor),
      cellStyle: pw.TextStyle(font: regular, fontSize: 9, color: AppPdfColors.ink),
      cellAlignment: pw.Alignment.centerLeft,
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: AppPdfColors.outline, width: 0.5),
      ),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
      oddRowDecoration: pw.BoxDecoration(color: _tint(accentColor, 0.94)),
    );
  }

  /// Embeds a captured chart PNG as a full-width image in the PDF, inside a
  /// bordered card so it doesn't float loose on the page.
  pw.Widget embedChartImage(Uint8List? png, {double height = 160}) {
    if (png == null) return pw.SizedBox.shrink();
    return pw.Container(
      height: height,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: AppPdfColors.outline, width: 0.75),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Image(pw.MemoryImage(png), fit: pw.BoxFit.contain),
    );
  }

  /// Renders metric cards as a horizontal row of rounded tiles with a
  /// colored top bar.
  pw.Widget buildMetricCardsRow({
    required pw.Font regular,
    required pw.Font bold,
    required List<({String label, String value, String? hint})> cards,
  }) {
    return pw.Row(
      children: cards
          .map((card) => pw.Expanded(
                child: pw.Container(
                  margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    border: pw.Border.all(color: AppPdfColors.outline, width: 0.75),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        height: 3,
                        decoration: pw.BoxDecoration(
                          color: accentColor,
                          borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(8)),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(card.label,
                                style: pw.TextStyle(font: regular, fontSize: 8, color: AppPdfColors.muted)),
                            pw.SizedBox(height: 3),
                            pw.Text(card.value,
                                style: pw.TextStyle(font: bold, fontSize: 14, color: accentColor)),
                            if (card.hint != null) ...[
                              pw.SizedBox(height: 2),
                              pw.Text(card.hint!,
                                  style: pw.TextStyle(font: regular, fontSize: 7, color: AppPdfColors.muted)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  /// Renders a colored interpretation/note box.
  pw.Widget buildInterpretationBox({
    required pw.Font regular,
    required String text,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: _tint(accentColor, 0.92),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border(left: pw.BorderSide(color: accentColor, width: 3)),
      ),
      child: pw.Text(text, style: pw.TextStyle(font: regular, fontSize: 9, color: AppPdfColors.ink)),
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
