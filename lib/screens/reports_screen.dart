import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' as material;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/controllers/reports_controller.dart';
import 'package:ssapp/models/whoqol_questions.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ssapp/utils/toast_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedSurveyType = 1;

  @override
  Widget build(BuildContext context) {
    final surveyService = context.watch<SurveyService>();
    final allSurveys = surveyService.getCompletedSurveys();

    final surveys = allSurveys.where((s) {
      final surveyType = s['survey_type'] as int? ?? 1;
      return surveyType == _selectedSurveyType;
    }).toList();

    // Stats via controller
    final scores = surveys.map((s) => ReportsController.calculateSurveyScore(s)).toList();
    final stats = ReportsController.computeBasicStats(scores);

    // WHOQOL report data
    final whoqolData = _selectedSurveyType == 3
        ? ReportsController.computeWhoqolReport(surveys)
        : null;

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Reportes y Estadísticas'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              onPressed: () => material.Navigator.of(context).pop(),
              variance: ButtonVariance.ghost,
            ),
          ],
        ),
      ],
      child: surveys.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(material.Icons.bar_chart, size: 80,
                      color: Theme.of(context).colorScheme.mutedForeground),
                  const Gap(16),
                  Text(
                    allSurveys.isEmpty
                        ? 'No hay encuestas completadas'
                        : 'No hay encuestas de este tipo',
                    style: TextStyle(fontSize: 20,
                        color: Theme.of(context).colorScheme.mutedForeground),
                  ),
                  const Gap(8),
                  Text(allSurveys.isEmpty
                      ? 'Completa algunas encuestas para ver estadísticas'
                      : 'Selecciona otro tipo de encuesta en el selector')
                      .muted().small(),
                  const Gap(24),
                  _buildTypeSelector(),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector
                  SurfaceCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          const Text('Tipo:').semiBold(),
                          const Gap(10),
                          Expanded(child: _buildTypeSelector()),
                        ],
                      ),
                    ),
                  ),
                  const Gap(24),

                  // export buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlineButton(
                        onPressed: surveys.isEmpty ? null : () {
                          if (_selectedSurveyType == 3) {
                            _exportWhoqolCSV(context, surveys);
                          } else {
                            _exportToSPSS(context, surveys, surveyService);
                          }
                        },
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(material.Icons.table_chart, size: 14),
                          const Gap(4),
                          const Text('Exportar CSV'),
                        ]),
                      ),
                      PrimaryButton(
                        onPressed: surveys.isEmpty ? null : () {
                          if (_selectedSurveyType == 3) {
                            final wd = ReportsController.computeWhoqolReport(surveys);
                            _generateWhoqolPDFReport(context, surveys, wd);
                          } else {
                            _generatePDFReport(context, surveys, surveyService, _calculateStatistics(surveys, surveyService));
                          }
                        },
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(material.Icons.picture_as_pdf, size: 14),
                          const Gap(4),
                          const Text('Exportar PDF'),
                        ]),
                      ),
                    ],
                  ),
                  const Gap(24),

                  // whoqol layout
                  if (_selectedSurveyType == 3 && whoqolData != null) ...[
                    _WhoqolReportSection(data: whoqolData),
                  ] else ...[
                    // bdi y bai layout
                    Text('Medidas de Tendencia Central',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Gap(12),
                    LayoutBuilder(builder: (context, constraints) {
                      final cardW = (constraints.maxWidth - 12) / 2;
                      final statH = (cardW * 0.48).clamp(72.0, 110.0);
                      final infoH = (cardW * 0.32).clamp(56.0, 80.0);
                      return Column(children: [
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12, mainAxisSpacing: 12,
                          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: cardW / statH,
                          children: [
                            _StatCard(title: 'Media', value: stats.mean.toStringAsFixed(1),
                                icon: material.Icons.analytics, color: const Color(0xFF3B82F6)),
                            _StatCard(title: 'Mediana', value: stats.median.toStringAsFixed(1),
                                icon: material.Icons.show_chart, color: const Color(0xFF10B981)),
                            _StatCard(title: 'Moda', value: stats.mode.toStringAsFixed(0),
                                icon: material.Icons.timeline, color: const Color(0xFF8B5CF6)),
                            _StatCard(title: 'Desv. Estándar', value: stats.stdDev.toStringAsFixed(2),
                                icon: material.Icons.scatter_plot, color: const Color(0xFFF59E0B)),
                          ],
                        ),
                        const Gap(12),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12, mainAxisSpacing: 12,
                          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: cardW / infoH,
                          children: [
                            _InfoCard(title: 'Total de Encuestas', value: surveys.length.toString()),
                            _InfoCard(title: 'Puntaje Mínimo', value: stats.min.toInt().toString()),
                            _InfoCard(title: 'Puntaje Máximo', value: stats.max.toInt().toString()),
                            _InfoCard(title: 'Rango', value: stats.range.toInt().toString()),
                          ],
                        ),
                      ]);
                    }),
                    const Gap(24),

                    Text('Distribución de Resultados',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Gap(16),

                    SurfaceCard(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Distribución por Nivel de Severidad').semiBold().large(),
                          const Gap(24),
                          SizedBox(height: 300,
                            child: _LevelDistributionChart(surveys: surveys,
                                surveyService: surveyService, surveyType: _selectedSurveyType)),
                        ]),
                      ),
                    ),
                    const Gap(24),

                    SurfaceCard(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Tendencia Temporal de Puntajes').semiBold().large(),
                          const Gap(24),
                          SizedBox(height: 300,
                            child: _TimelineChart(surveys: surveys, surveyService: surveyService)),
                        ]),
                      ),
                    ),
                    const Gap(24),

                    SurfaceCard(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Proporción por Nivel de Severidad').semiBold().large(),
                          const Gap(4),
                          Text('Distribución porcentual de encuestados por nivel',
                              style: TextStyle(fontSize: 12,
                                  color: Theme.of(context).colorScheme.mutedForeground)),
                          const Gap(24),
                          LayoutBuilder(builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 400;
                            return SizedBox(
                              height: isNarrow ? 480 : 320,
                              child: _SeverityPieChart(surveys: surveys,
                                  surveyService: surveyService, surveyType: _selectedSurveyType),
                            );
                          }),
                        ]),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildTypeSelector() {
    return Select<int>(
      value: _selectedSurveyType,
      onChanged: (v) { if (v != null) setState(() => _selectedSurveyType = v); },
      itemBuilder: (context, item) {
        const names = {1: 'BDI-II', 2: 'BAI', 3: 'WHOQOL-BREF'};
        return Text(names[item] ?? '$item');
      },
      popup: SelectPopup(
        items: SelectItemList(children: [
          SelectItemButton(value: 1, child: const Text('BDI-II — Inventario de Depresión de Beck')),
          SelectItemButton(value: 2, child: const Text('BAI — Inventario de Ansiedad de Beck')),
          SelectItemButton(value: 3, child: const Text('WHOQOL-BREF — Calidad de Vida')),
        ]),
      ).call,
    );
  }

  Map<String, double> _calculateStatistics(
    List<Map<String, dynamic>> surveys,
    SurveyService surveyService,
  ) {
    final scores = surveys.map((s) => ReportsController.calculateSurveyScore(s)).toList();
    final s = ReportsController.computeBasicStats(scores);
    return {
      'mean': s.mean, 'median': s.median, 'mode': s.mode,
      'stdDev': s.stdDev, 'min': s.min, 'max': s.max,
    };
  }

  Future<void> _exportToSPSS(BuildContext context, List<Map<String, dynamic>> surveys, SurveyService surveyService) async {
    try {
      final surveyTypeName = _selectedSurveyType == 1 ? 'BDI-II' : 'BAI';

      List<List<dynamic>> rows = [
        ['ID_Encuesta', 'ID_Paciente', 'Fecha', 'Tipo_Encuesta', 'Puntaje_Total', 'Nivel_Severidad']
      ];

      for (var survey in surveys) {
        final surveyId = survey['survey_id'];
        final patientId = survey['patient_id'] ?? 'N/A';
        final date = DateTime.parse(survey['created_at']).toString().split(' ')[0];
        final score = ReportsController.calculateSurveyScore(survey);
        final level = _getLevelText(score, _selectedSurveyType);

        rows.add([
          surveyId,
          patientId,
          date,
          surveyTypeName,
          score,
          level,
        ]);
      }

      String csvString = '';
      for (var row in rows) {
        csvString += '${row.map((cell) {
          final cellStr = cell.toString();
          if (cellStr.contains(',') || cellStr.contains('"') || cellStr.contains('\n')) {
            return '"${cellStr.replaceAll('"', '""')}"';
          }
          return cellStr;
        }).join(',')}\n';
      }

      final bom = [0xEF, 0xBB, 0xBF]; // UTF-8 BOM
      final csvBytes = utf8.encode(csvString);
      final bytes = Uint8List.fromList(bom + csvBytes);

      final fileName = 'datos_${surveyTypeName}_${DateTime.now().millisecondsSinceEpoch}.csv';

      if (kIsWeb) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], text: 'Exportar datos CSV'),
        );
      }

      showCenteredToast(
        context,
        title: 'Datos exportados',
        subtitle: 'Archivo CSV descargado exitosamente',
        icon: material.Icons.check_circle,
        iconColor: const Color(0xFF10B981),
        location: ToastLocation.bottomCenter,
      );
    } catch (e) {
      showCenteredToast(
        context,
        title: 'Error al exportar',
        subtitle: 'No se pudo generar el archivo: $e',
        icon: material.Icons.error,
        iconColor: const Color(0xFFEF4444),
        location: ToastLocation.bottomCenter,
      );
    }
  }

  String _getLevelText(int score, int surveyType) {
    if (surveyType == 1) return ReportsController.bdiLevel(score);
    return ReportsController.baiLevel(score);
  }

  // csv del whoqol
  Future<void> _exportWhoqolCSV(
    BuildContext context,
    List<Map<String, dynamic>> surveys,
  ) async {
    try {
      // header
      final header = [
        'ID_Encuesta', 'ID_Paciente', 'Fecha',
        'Q1_Calidad_Vida', 'Q2_Salud',
        'Q3', 'Q4', 'Q5', 'Q6', 'Q7', 'Q8', 'Q9', 'Q10',
        'Q11', 'Q12', 'Q13', 'Q14', 'Q15', 'Q16', 'Q17', 'Q18',
        'Q19', 'Q20', 'Q21', 'Q22', 'Q23', 'Q24', 'Q25', 'Q26',
        'DOM1_SaludFisica', 'DOM2_Psicologica', 'DOM3_Relaciones', 'DOM4_Ambiente',
        'Puntaje_Global',
      ];

      final rows = <List<dynamic>>[header];

      final sorted = List<Map<String, dynamic>>.from(surveys)
        ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));

      for (final s in sorted) {
        final responses = s['responses'] as List? ?? [];
        final respMap = <int, int>{};
        for (final r in responses) {
          final q = r['question_id'] as int?;
          final v = r['answer_value'] as int?;
          if (q != null && v != null) respMap[q] = v;
        }

        int? domScore(List<int> qs) {
          int tot = 0;
          for (final qn in qs) {
            final raw = respMap[qn];
            if (raw == null) return null;
            final q = WhoqolQuestions.questions.firstWhere((q) => q.number == qn);
            tot += WhoqolQuestions.adjustedScore(rawScore: raw, reversed: q.reversed);
          }
          return tot;
        }

        int? globalScore() {
          int tot = 0;
          for (final q in WhoqolQuestions.questions) {
            final raw = respMap[q.number];
            if (raw == null) return null;
            tot += WhoqolQuestions.adjustedScore(rawScore: raw, reversed: q.reversed);
          }
          return tot;
        }

        final dom1 = domScore(WhoqolQuestions.domain1Questions);
        final dom2 = domScore(WhoqolQuestions.domain2Questions);
        final dom3 = domScore(WhoqolQuestions.domain3Questions);
        final dom4 = domScore(WhoqolQuestions.domain4Questions);
        final global = globalScore();

        rows.add([
          s['survey_id'],
          s['patient_id'] ?? 'N/A',
          DateTime.parse(s['created_at']).toString().split(' ')[0],
          // Q1..Q26 raw values
          for (int i = 1; i <= 26; i++) respMap[i] ?? '',
          dom1 ?? '', dom2 ?? '', dom3 ?? '', dom4 ?? '',
          global ?? '',
        ]);
      }

      String csvString = '';
      for (final row in rows) {
        csvString += '${row.map((cell) {
          final s = cell.toString();
          return (s.contains(',') || s.contains('"') || s.contains('\n'))
              ? '"${s.replaceAll('"', '""')}"'
              : s;
        }).join(',')}\n';
      }

      final bom = [0xEF, 0xBB, 0xBF];
      final bytes = Uint8List.fromList(bom + utf8.encode(csvString));
      final fileName = 'datos_WHOQOL_${DateTime.now().millisecondsSinceEpoch}.csv';

      if (kIsWeb) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], text: 'Datos WHOQOL-BREF CSV'),
        );
      }

      if (context.mounted) {
        showCenteredToast(context,
          title: 'CSV exportado',
          subtitle: '${surveys.length} encuestas WHOQOL exportadas',
          icon: material.Icons.check_circle,
          iconColor: const Color(0xFF10B981),
          location: ToastLocation.bottomCenter);
      }
    } catch (e) {
      if (context.mounted) {
        showCenteredToast(context,
          title: 'Error al exportar',
          subtitle: 'No se pudo generar el CSV: $e',
          icon: material.Icons.error,
          iconColor: const Color(0xFFEF4444),
          location: ToastLocation.bottomCenter);
      }
    }
  }

  // pdf de whoqol
  Future<void> _generateWhoqolPDFReport(
    BuildContext context,
    List<Map<String, dynamic>> surveys,
    WhoqolReportData data,
  ) async {
    try {
      final pdf = pw.Document();
      final fontRegular = await PdfGoogleFonts.notoSansRegular();
      final fontBold    = await PdfGoogleFonts.notoSansBold();
      final canvasFont = PdfFont.helvetica(pdf.document);
      final canvasFontBold = PdfFont.helveticaBold(pdf.document);

      pw.TextStyle st({double sz = 10, bool bold = false, PdfColor? color}) =>
          pw.TextStyle(font: bold ? fontBold : fontRegular, fontSize: sz, color: color);

      // colores de dominios
      const dom1Color = PdfColor(0.055, 0.647, 0.914); // #0EA5E9
      const dom2Color = PdfColor(0.545, 0.361, 0.965); // #8B5CF6
      const dom3Color = PdfColor(0.063, 0.725, 0.506); // #10B981
      const dom4Color = PdfColor(0.961, 0.620, 0.043); // #F59E0B
      const whoqolColor = PdfColor(0.486, 0.228, 0.929); // #7C3AED

      // helper: stat summary box
      pw.Widget statBox(String label, String val) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(val, style: st(sz: 15, bold: true, color: PdfColors.deepPurple800)),
          pw.SizedBox(height: 2),
          pw.Text(label, style: st(sz: 8, color: PdfColors.grey700)),
        ],
      );

      // helper: Q1/Q2 bar chart
      pw.Widget itemBar(String title, Map<String, int> dist, PdfColor color) {
        final total = dist.values.fold(0, (a, b) => a + b);
        final maxV = dist.values.isEmpty ? 1 : dist.values.reduce((a, b) => a > b ? a : b);
        const chartH = 60.0;
        const barW   = 24.0;
        const gap    = 6.0;
        return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(title, style: st(sz: 9, bold: true)),
          pw.SizedBox(height: 4),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: dist.entries.map((e) {
              final h = maxV == 0 ? 0.0 : (e.value / maxV * chartH);
              final pct = total == 0 ? 0.0 : e.value / total * 100;
              return pw.Padding(
                padding: pw.EdgeInsets.only(right: gap),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('${pct.toStringAsFixed(0)}%', style: st(sz: 7)),
                    pw.SizedBox(height: 2),
                    pw.Container(
                      width: barW, height: h == 0 ? 1 : h,
                      color: h == 0 ? PdfColors.grey300 : color,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(e.key, style: st(sz: 7, color: PdfColors.grey700)),
                    pw.Text('(${e.value})', style: st(sz: 6, color: PdfColors.grey600)),
                  ],
                ),
              );
            }).toList(),
          ),
        ]);
      }

      // helper: timeline chart
      pw.Widget timelineChart(String title, List<double> scores, PdfColor color, double maxY) {
        if (scores.length < 2) {
          return pw.Text('Se necesitan al menos 2 encuestas para la tendencia.',
              style: st(sz: 9, color: PdfColors.grey600));
        }
        final n = scores.length;
        const w = 460.0, h = 100.0;
        final step = (n / 8).ceil().clamp(1, n);
        final xTicks = <int>[
          for (int i = 0; i < n; i += step) i,
          if ((n - 1) % step != 0) n - 1,
        ];
        return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(title, style: st(sz: 10, bold: true)),
          pw.SizedBox(height: 4),
          pw.SizedBox(
            width: w, height: h + 24,
            child: pw.CustomPaint(painter: (canvas, size) {
              final effectiveMax = maxY == 0 ? 1.0 : maxY;
              // axes
              canvas.setStrokeColor(PdfColors.grey400);
              canvas.setLineWidth(0.5);
              canvas.drawLine(30, 0, 30, h);
              canvas.drawLine(30, h, w, h);
              canvas.strokePath();
              // y grid lines
              for (int i = 0; i <= 4; i++) {
                final y = h - (i / 4 * h);
                canvas.setStrokeColor(PdfColors.grey200);
                canvas.setLineWidth(0.3);
                canvas.drawLine(30, y, w, y);
                canvas.strokePath();
                final label = (effectiveMax * i / 4).toStringAsFixed(0);
                canvas.drawString(canvasFont, 7, label, 0, y - 3);
              }
              // x labels
              for (final xi in xTicks) {
                final x = 30 + xi / (n - 1) * (w - 30);
                canvas.drawString(canvasFont, 7, '#${xi + 1}', x - 6, h + 4);
              }
              // line
              canvas.setStrokeColor(color);
              canvas.setLineWidth(1.5);
              for (int i = 0; i < scores.length - 1; i++) {
                final x1 = 30 + i / (n - 1) * (w - 30);
                final y1 = h - (scores[i] / effectiveMax * h).clamp(0, h);
                final x2 = 30 + (i + 1) / (n - 1) * (w - 30);
                final y2 = h - (scores[i + 1] / effectiveMax * h).clamp(0, h);
                canvas.drawLine(x1, y1, x2, y2);
                canvas.strokePath();
              }
              // dots
              canvas.setFillColor(color);
              for (int i = 0; i < scores.length; i++) {
                final x = 30 + i / (n - 1) * (w - 30);
                final y = h - (scores[i] / effectiveMax * h).clamp(0, h);
                _drawPdfCircle(canvas, x, y, 2.5);
              }
            }),
          ),
        ]);
      }

      // helper: domain bar chart
      pw.Widget domainBarChart(WhoqolReportData d) {
        final doms = [
          ('Fisica',      d.dom1.mean, dom1Color, d.dom1.maxPossible),
          ('Psicologica', d.dom2.mean, dom2Color, d.dom2.maxPossible),
          ('Relaciones',  d.dom3.mean, dom3Color, d.dom3.maxPossible),
          ('Ambiente',    d.dom4.mean, dom4Color, d.dom4.maxPossible),
        ];
        final maxM = doms.map((d) => d.$4.toDouble()).reduce((a, b) => a > b ? a : b);
        const chartH = 100.0;
        const barW   = 50.0;
        const gap    = 20.0;
        return pw.SizedBox(
          height: chartH + 40,
          child: pw.CustomPaint(painter: (canvas, size) {
            for (int i = 0; i < doms.length; i++) {
              final dom = doms[i];
              final barH = dom.$2 / maxM * chartH;
              final x = i * (barW + gap);
              // bar
              canvas.setFillColor(dom.$3);
              canvas.drawRect(x, chartH - barH, barW, barH);
              canvas.fillPath();
              // label
              canvas.setFillColor(PdfColors.black);
              canvas.drawString(canvasFont, 8, dom.$1, x + 2, chartH + 4);
              canvas.drawString(canvasFontBold, 8,
                  '${dom.$2.toStringAsFixed(1)}/${dom.$4}', x + 2, chartH + 14);
            }
            // axis
            canvas.setStrokeColor(PdfColors.grey400);
            canvas.setLineWidth(0.5);
            canvas.drawLine(0, chartH, (barW + gap) * 4, chartH);
            canvas.strokePath();
          }),
        );
      }

      // helper: pie chart
      pw.Widget domainPie(WhoqolReportData d) {
        final vals = [d.dom1.mean, d.dom2.mean, d.dom3.mean, d.dom4.mean];
        final colors = [dom1Color, dom2Color, dom3Color, dom4Color];
        final labels = ['Salud Fisica', 'Psicologica', 'Relaciones', 'Ambiente'];
        final total  = vals.fold<double>(0, (a, b) => a + b);

        return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.SizedBox(
            width: 130, height: 130,
            child: pw.CustomPaint(painter: (canvas, size) {
              if (total == 0) return;
              final cx = size.x / 2, cy = size.y / 2, r = size.x / 2 - 4;
              double ang = -math.pi / 2;
              for (int i = 0; i < vals.length; i++) {
                if (vals[i] == 0) continue;
                final sweep = vals[i] / total * 2 * math.pi;
                canvas.setFillColor(colors[i]);
                _drawPdfSector(canvas, cx, cy, r, ang, sweep);
                ang += sweep;
              }
              canvas.setFillColor(PdfColors.white);
              _drawPdfCircle(canvas, cx, cy, r * 0.38);
            }),
          ),
          pw.SizedBox(width: 16),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: vals.asMap().entries.map((e) {
              final pct = total == 0 ? 0.0 : e.value / total * 100;
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(children: [
                  pw.Container(width: 10, height: 10, color: colors[e.key]),
                  pw.SizedBox(width: 5),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text(labels[e.key], style: st(sz: 9, bold: true)),
                    pw.Text('${e.value.toStringAsFixed(1)} (${pct.toStringAsFixed(1)}%)',
                        style: st(sz: 8, color: PdfColors.grey700)),
                  ]),
                ]),
              );
            }).toList(),
          ),
        ]);
      }

      final now = DateTime.now();

      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        build: (pw.Context ctx) => [
          // header pdf
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Reporte WHOQOL-BREF',
                style: st(sz: 22, bold: true, color: whoqolColor)),
            pw.SizedBox(height: 4),
            pw.Text('Cuestionario de Calidad de Vida — OMS',
                style: st(sz: 13, color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            pw.Text(
              'Generado el ${now.day}/${now.month}/${now.year}  |  '
              'Total: ${surveys.length} encuestas',
              style: st(sz: 11, color: PdfColors.grey600)),
            pw.Divider(thickness: 2, color: whoqolColor),
          ]),
          pw.SizedBox(height: 16),

          // resumen global
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: const PdfColor(0.94, 0.90, 1.0),
              borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Resumen Estadistico Global (26 preguntas)',
                  style: st(sz: 13, bold: true, color: PdfColors.deepPurple800)),
              pw.SizedBox(height: 10),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceAround, children: [
                statBox('Total encuestas', data.surveyCount.toString()),
                statBox('Media', data.globalStats.mean.toStringAsFixed(1)),
                statBox('Mediana', data.globalStats.median.toStringAsFixed(1)),
                statBox('Desv. Est.', data.globalStats.stdDev.toStringAsFixed(2)),
                statBox('Min', data.globalStats.min.toInt().toString()),
                statBox('Max', data.globalStats.max.toInt().toString()),
                statBox('Max posible', '130'),
              ]),
            ]),
          ),
          pw.SizedBox(height: 20),

          // Q1 / Q2
          pw.Text('Items Globales — Q1 y Q2',
              style: st(sz: 14, bold: true)),
          pw.SizedBox(height: 8),
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Expanded(child: itemBar(
              'Q1 - Calidad de vida',
              data.globalItems.q1Distribution,
              whoqolColor,
            )),
            pw.SizedBox(width: 20),
            pw.Expanded(child: itemBar(
              'Q2 - Satisfaccion con salud',
              data.globalItems.q2Distribution,
              const PdfColor(0.23, 0.51, 0.96),
            )),
          ]),
          pw.SizedBox(height: 4),
          pw.Text(
            'Escala Q1/Q2: 1=Muy mala/Muy insatisfecho, 2=Poco/Insatisfecho, '
            '3=Lo normal, 4=Bastante buena/Satisfecho, 5=Muy buena/Muy satisfecho',
            style: st(sz: 8, color: PdfColors.grey600)),
          pw.SizedBox(height: 20),

          // dimensiones
          pw.Text('Puntajes por Dominio',
              style: st(sz: 14, bold: true)),
          pw.SizedBox(height: 4),
          pw.Text('Mayor puntaje = mejor calidad de vida',
              style: st(sz: 9, color: PdfColors.grey600)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableHeaderF('Dominio', fontBold),
                  _buildTableHeaderF('Preguntas', fontBold),
                  _buildTableHeaderF('Media', fontBold),
                  _buildTableHeaderF('Mediana', fontBold),
                  _buildTableHeaderF('Desv.Est', fontBold),
                  _buildTableHeaderF('Max posible', fontBold),
                  _buildTableHeaderF('%', fontBold),
                ],
              ),
              ...([
                ('Salud Fisica',      data.dom1, dom1Color),
                ('Salud Psicologica', data.dom2, dom2Color),
                ('Relaciones Soc.',   data.dom3, dom3Color),
                ('Ambiente',          data.dom4, dom4Color),
              ].map((t) {
                final dom = t.$2;
                final pct = dom.maxPossible == 0 ? 0.0 : dom.mean / dom.maxPossible * 100;
                return pw.TableRow(children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(t.$1, style: st(sz: 9, bold: true, color: t.$3))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(dom.questionCount.toString(), style: st(sz: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(dom.mean.toStringAsFixed(1), style: st(sz: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(dom.median.toStringAsFixed(1), style: st(sz: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(dom.stdDev.toStringAsFixed(2), style: st(sz: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(dom.maxPossible.toString(), style: st(sz: 9))),
                  pw.Padding(padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('${pct.toStringAsFixed(1)}%', style: st(sz: 9, bold: true))),
                ]);
              })),
            ],
          ),
          pw.SizedBox(height: 20),

          // gráfica de barras
          pw.Text('Grafica 1: Media por Dominio',
              style: st(sz: 13, bold: true)),
          pw.SizedBox(height: 8),
          domainBarChart(data),
          pw.SizedBox(height: 20),

          // gráfica de pastel
          pw.Text('Grafica 2: Proporcion por Dominio',
              style: st(sz: 13, bold: true)),
          pw.SizedBox(height: 4),
          pw.Text('Basado en la suma de medias de cada dominio',
              style: st(sz: 9, color: PdfColors.grey600)),
          pw.SizedBox(height: 8),
          domainPie(data),
          pw.SizedBox(height: 20),

          // intepretación de dimensiones
          pw.Text('Interpretacion por Dominio',
              style: st(sz: 13, bold: true)),
          pw.SizedBox(height: 8),
          ...([
            ('Salud Fisica',      data.dom1, dom1Color),
            ('Salud Psicologica', data.dom2, dom2Color),
            ('Relaciones Soc.',   data.dom3, dom3Color),
            ('Ambiente',          data.dom4, dom4Color),
          ].map((t) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border(left: pw.BorderSide(color: t.$3, width: 3)),
                color: PdfColors.grey50,
              ),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text(t.$1, style: st(sz: 10, bold: true, color: t.$3)),
                pw.SizedBox(height: 3),
                pw.Text(ReportsController.whoqolDomainInterpretation(t.$2),
                    style: st(sz: 9, color: PdfColors.grey800)),
              ]),
            ),
          ))),
          pw.SizedBox(height: 20),

          // ── Global timeline ──
          if (data.globalTimeline.length >= 2) ...[
            timelineChart(
              'Grafica 3: Tendencia Temporal — Puntaje Global',
              data.globalTimeline,
              whoqolColor,
              130,
            ),
            pw.SizedBox(height: 20),
          ],

          // ── Domain timelines ──
          if (data.dom1Timeline.length >= 2) ...[
            timelineChart('Grafica 4: Tendencia — Salud Fisica',
                data.dom1Timeline, dom1Color, data.dom1.maxPossible.toDouble()),
            pw.SizedBox(height: 14),
          ],
          if (data.dom2Timeline.length >= 2) ...[
            timelineChart('Grafica 5: Tendencia — Salud Psicologica',
                data.dom2Timeline, dom2Color, data.dom2.maxPossible.toDouble()),
            pw.SizedBox(height: 14),
          ],
          if (data.dom3Timeline.length >= 2) ...[
            timelineChart('Grafica 6: Tendencia — Relaciones Sociales',
                data.dom3Timeline, dom3Color, data.dom3.maxPossible.toDouble()),
            pw.SizedBox(height: 14),
          ],
          if (data.dom4Timeline.length >= 2) ...[
            timelineChart('Grafica 7: Tendencia — Ambiente',
                data.dom4Timeline, dom4Color, data.dom4.maxPossible.toDouble()),
            pw.SizedBox(height: 20),
          ],

          // ── Footer note ──
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: const pw.BoxDecoration(color: PdfColors.grey100),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Nota Importante:', style: st(sz: 10, bold: true)),
              pw.SizedBox(height: 4),
              pw.Text(
                'Este reporte es generado automaticamente con fines estadisticos. '
                'Los resultados deben ser interpretados por un profesional de la salud calificado. '
                'El WHOQOL-BREF es un instrumento de la Organizacion Mundial de la Salud.',
                style: st(sz: 9)),
            ]),
          ),
        ],
      ));

      final pdfBytes = await pdf.save();
      final fileName = 'reporte_WHOQOL_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (kIsWeb) {
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(pdfBytes);
        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], text: 'Reporte PDF WHOQOL-BREF'),
        );
      }

      if (context.mounted) {
        showCenteredToast(context,
          title: 'Reporte generado',
          subtitle: 'PDF WHOQOL-BREF descargado',
          icon: material.Icons.check_circle,
          iconColor: const Color(0xFF10B981),
          location: ToastLocation.bottomCenter);
      }
    } catch (e) {
      if (context.mounted) {
        showCenteredToast(context,
          title: 'Error al generar PDF',
          subtitle: 'No se pudo crear el reporte: $e',
          icon: material.Icons.error,
          iconColor: const Color(0xFFEF4444),
          location: ToastLocation.bottomCenter);
      }
    }
  }

  // ignore: unused_element
  Future<void> _exportAllToCSV(BuildContext context, List<Map<String, dynamic>> allSurveys, SurveyService surveyService) async {
    try {
      List<List<dynamic>> rows = [
        ['ID_Encuesta', 'ID_Paciente', 'Fecha', 'Tipo_Encuesta', 'Puntaje_Total', 'Nivel_Severidad']
      ];

      for (var survey in allSurveys) {
        final surveyType = survey['survey_type'] as int? ?? 1;
        final surveyTypeName = surveyType == 1 ? 'BDI-II' : 'BAI';
        final surveyId = survey['survey_id'];
        final patientId = survey['patient_id'] ?? 'N/A';
        final date = DateTime.parse(survey['created_at']).toString().split(' ')[0];
        final score = ReportsController.calculateSurveyScore(survey);
        final level = _getLevelText(score, surveyType);
        rows.add([surveyId, patientId, date, surveyTypeName, score, level]);
      }

      String csvString = '';
      for (var row in rows) {
        csvString += '${row.map((cell) {
          final cellStr = cell.toString();
          if (cellStr.contains(',') || cellStr.contains('"') || cellStr.contains('\n')) {
            return '"${cellStr.replaceAll('"', '""')}"';
          }
          return cellStr;
        }).join(',')}\n';
      }

      final bom = [0xEF, 0xBB, 0xBF];
      final csvBytes = utf8.encode(csvString);
      final bytes = Uint8List.fromList(bom + csvBytes);
      final fileName = 'datos_todos_${DateTime.now().millisecondsSinceEpoch}.csv';

      if (kIsWeb) {
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], text: 'Exportar datos CSV completos'),
        );
      }

      if (context.mounted) {
        showCenteredToast(
          context,
          title: 'Datos exportados',
          subtitle: 'CSV con ${allSurveys.length} encuestas descargado',
          icon: material.Icons.check_circle,
          iconColor: const Color(0xFF10B981),
          location: ToastLocation.bottomCenter,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showCenteredToast(
          context,
          title: 'Error al exportar',
          subtitle: 'No se pudo generar el archivo: $e',
          icon: material.Icons.error,
          iconColor: const Color(0xFFEF4444),
          location: ToastLocation.bottomCenter,
        );
      }
    }
  }

  // ignore: unused_element
  Future<void> _generateFullPDFReport(
    BuildContext context,
    List<Map<String, dynamic>> allSurveys,
    SurveyService surveyService,
  ) async {
    try {
      final bdSurveys = allSurveys.where((s) => (s['survey_type'] as int? ?? 1) == 1).toList();
      final baiSurveys = allSurveys.where((s) => (s['survey_type'] as int? ?? 1) == 2).toList();
      final bdStats = _calculateStatistics(bdSurveys, surveyService);
      final baiStats = _calculateStatistics(baiSurveys, surveyService);

      final pdf = pw.Document();
      final fontRegular = await PdfGoogleFonts.notoSansRegular();
      final fontBold = await PdfGoogleFonts.notoSansBold();

      pw.Widget buildSection(
        String title,
        String fullName,
        List<Map<String, dynamic>> secSurveys,
        Map<String, double> stats,
        int surveyType,
      ) {
        final dist = <String, int>{'Mínima': 0, 'Leve': 0, 'Moderada': 0, 'Severa': 0};
        for (var s in secSurveys) {
          final score = ReportsController.calculateSurveyScore(s);
          final level = _getLevelText(score, surveyType);
          if (dist.containsKey(level)) dist[level] = dist[level]! + 1;
        }
        final maxDist = dist.values.isEmpty ? 1 : dist.values.reduce((a, b) => a > b ? a : b);
        final total = dist.values.fold(0, (a, b) => a + b);

        final sortedS = List<Map<String, dynamic>>.from(secSurveys)
          ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
        final tScores = sortedS.map((s) => ReportsController.calculateSurveyScore(s)).toList();
        final maxTS = tScores.isEmpty ? 5.0 : tScores.reduce((a, b) => a > b ? a : b).toDouble();

        final sRanges = surveyType == 1
            ? {'Mínima': '0-13', 'Leve': '14-19', 'Moderada': '20-28', 'Severa': '29-63'}
            : {'Mínima': '0-7', 'Leve': '8-15', 'Moderada': '16-25', 'Severa': '26-63'};
        final pieColors = [PdfColors.green400, PdfColors.yellow600, PdfColors.orange400, PdfColors.red400];

        pw.TextStyle st({double sz = 10, bool bold = false, PdfColor? color}) =>
            pw.TextStyle(font: bold ? fontBold : fontRegular, fontSize: sz, color: color);

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: st(sz: 20, bold: true, color: PdfColors.blue800)),
            pw.SizedBox(height: 4),
            pw.Text(fullName, style: st(sz: 13, color: PdfColors.grey700)),
            pw.Divider(thickness: 1.5, color: PdfColors.blue300),
            pw.SizedBox(height: 12),
            if (secSurveys.isEmpty)
              pw.Text('Sin encuestas registradas.', style: st(sz: 11, color: PdfColors.grey600))
            else ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(color: PdfColors.blue50, borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItemF('Total', secSurveys.length.toString(), fontRegular, fontBold),
                    _buildStatItemF('Minimo', (stats['min'] ?? 0).toInt().toString(), fontRegular, fontBold),
                    _buildStatItemF('Maximo', (stats['max'] ?? 0).toInt().toString(), fontRegular, fontBold),
                    _buildStatItemF('Media', (stats['mean'] ?? 0).toStringAsFixed(1), fontRegular, fontBold),
                    _buildStatItemF('Mediana', (stats['median'] ?? 0).toStringAsFixed(1), fontRegular, fontBold),
                    _buildStatItemF('Desv.Est', (stats['stdDev'] ?? 0).toStringAsFixed(2), fontRegular, fontBold),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Text('Distribucion por Severidad', style: st(sz: 13, bold: true)),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableHeaderF('Nivel', fontBold),
                      _buildTableHeaderF('Rango', fontBold),
                      _buildTableHeaderF('Cantidad', fontBold),
                      _buildTableHeaderF('Porcentaje', fontBold),
                    ],
                  ),
                  ...dist.entries.map((e) {
                    final pct = total == 0 ? '0.0%' : '${(e.value / total * 100).toStringAsFixed(1)}%';
                    return pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(e.key, style: st())),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(sRanges[e.key] ?? '', style: st())),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(e.value.toString(), style: st())),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(pct, style: st())),
                    ]);
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 14),
              pw.Text('Grafica 1: Distribucion por Nivel', style: st(sz: 13, bold: true)),
              pw.SizedBox(height: 6),
              pw.SizedBox(
                height: 170,
                child: pw.Chart(
                  grid: pw.CartesianGrid(
                    xAxis: pw.FixedAxis.fromStrings(['Minima', 'Leve', 'Moderada', 'Severa'], marginStart: 10, marginEnd: 10, ticks: true),
                    yAxis: pw.FixedAxis([0, (maxDist + 1).toDouble()], divisions: true),
                  ),
                  datasets: [
                    pw.BarDataSet(
                      color: surveyType == 1 ? PdfColors.blue400 : PdfColors.teal400,
                      width: 28, offset: 0,
                      borderColor: surveyType == 1 ? PdfColors.blue700 : PdfColors.teal700,
                      data: [
                        pw.PointChartValue(0, (dist['Mínima'] ?? 0).toDouble()),
                        pw.PointChartValue(1, (dist['Leve'] ?? 0).toDouble()),
                        pw.PointChartValue(2, (dist['Moderada'] ?? 0).toDouble()),
                        pw.PointChartValue(3, (dist['Severa'] ?? 0).toDouble()),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
              pw.Text('Grafica 2: Proporcion por Nivel de Severidad', style: st(sz: 13, bold: true)),
              pw.SizedBox(height: 8),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.SizedBox(
                    width: 140, height: 140,
                    child: pw.CustomPaint(
                      painter: (canvas, size) {
                        final cx = size.x / 2;
                        final cy = size.y / 2;
                        final r = size.x / 2 - 4;
                        final vals = [
                          (dist['Mínima'] ?? 0).toDouble(),
                          (dist['Leve'] ?? 0).toDouble(),
                          (dist['Moderada'] ?? 0).toDouble(),
                          (dist['Severa'] ?? 0).toDouble(),
                        ];
                        final tv = vals.fold<double>(0.0, (a, b) => a + b);
                        if (tv == 0) return;
                        double startAng = -math.pi / 2;
                        for (int i = 0; i < vals.length; i++) {
                          if (vals[i] == 0) continue;
                          final sweepAng = vals[i] / tv * 2 * math.pi;
                          canvas.setFillColor(pieColors[i]);
                          _drawPdfSector(canvas, cx, cy, r, startAng, sweepAng);
                          startAng += sweepAng;
                        }
                        // donita
                        canvas.setFillColor(PdfColors.white);
                        _drawPdfCircle(canvas, cx, cy, r * 0.38);
                      },
                    ),
                  ),
                  pw.SizedBox(width: 14),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: dist.entries.toList().asMap().entries.map((e) {
                        final pct2 = total == 0 ? 0.0 : e.value.value / total * 100;
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 5),
                          child: pw.Row(
                            children: [
                              pw.Container(width: 10, height: 10,
                                decoration: pw.BoxDecoration(color: pieColors[e.key], borderRadius: pw.BorderRadius.circular(2))),
                              pw.SizedBox(width: 5),
                              pw.Expanded(child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(e.value.key, style: st(sz: 9, bold: true)),
                                  pw.Text('${e.value.value} (${pct2.toStringAsFixed(1)}%)  ${sRanges[e.value.key] ?? ''}',
                                    style: st(sz: 8, color: PdfColors.grey700)),
                                ],
                              )),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 14),
              if (tScores.length > 1) ...[
                pw.Text('Grafica 3: Tendencia Temporal', style: st(sz: 13, bold: true)),
                pw.SizedBox(height: 6),
                pw.SizedBox(
                  height: 170,
                  child: pw.Chart(
                    grid: pw.CartesianGrid(
                      xAxis: pw.FixedAxis(
                        () {
                          final n = tScores.length;
                          final maxLabels = 8;
                          final step = (n / maxLabels).ceil().clamp(1, n);
                          return [
                            for (int i = 0; i < n; i += step) i.toDouble(),
                            if ((n - 1) % step != 0) (n - 1).toDouble(),
                          ];
                        }(),
                        divisions: false,
                        ticks: true,
                      ),
                      yAxis: pw.FixedAxis([0, maxTS + 5], divisions: true),
                    ),
                    datasets: [
                      pw.LineDataSet(
                        color: surveyType == 1 ? PdfColors.blue600 : PdfColors.teal600,
                        lineWidth: 2, drawPoints: true,
                        pointColor: surveyType == 1 ? PdfColors.blue900 : PdfColors.teal900,
                        data: tScores.asMap().entries
                            .map((e) => pw.PointChartValue(e.key.toDouble(), e.value.toDouble()))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 14),
              ],
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue300, width: 1.5), borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Interpretacion', style: st(sz: 11, bold: true, color: PdfColors.blue900)),
                    pw.SizedBox(height: 4),
                    pw.Text(_getInterpretation(stats['mean'] ?? 0, surveyType), style: st(sz: 9)),
                  ],
                ),
              ),
            ],
            pw.SizedBox(height: 28),
          ],
        );
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
          build: (pw.Context ctx) {
            return [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Reporte Completo de Analisis Estadistico',
                  style: pw.TextStyle(font: fontBold, fontSize: 22, color: PdfColors.blue800)),
                pw.SizedBox(height: 4),
                pw.Text('BDI-II (Depresion) y BAI (Ansiedad)',
                  style: pw.TextStyle(font: fontRegular, fontSize: 14, color: PdfColors.grey700)),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Generado el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}  |  Total: ${allSurveys.length} encuestas',
                  style: pw.TextStyle(font: fontRegular, fontSize: 11, color: PdfColors.grey600)),
                pw.Divider(thickness: 2.5, color: PdfColors.blue800),
                pw.SizedBox(height: 20),
              ]),
              buildSection('BDI-II', 'Inventario de Depresion de Beck II', bdSurveys, bdStats, 1),
              buildSection('BAI', 'Inventario de Ansiedad de Beck', baiSurveys, baiStats, 2),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('Nota Importante:', style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Este reporte es generado automaticamente con fines estadisticos. Los resultados deben ser interpretados por un profesional de la salud mental calificado.',
                    style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                ]),
              ),
            ];
          },
        ),
      );

      final pdfBytes = await pdf.save();
      final fileName = 'reporte_completo_${DateTime.now().millisecondsSinceEpoch}.pdf';
      if (kIsWeb) {
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(pdfBytes);
        await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Reporte PDF Completo'));
      }

      if (context.mounted) {
        showCenteredToast(
          context,
          title: 'Reporte generado',
          subtitle: 'PDF completo (BDI-II + BAI) descargado',
          icon: material.Icons.check_circle,
          iconColor: const Color(0xFF10B981),
          location: ToastLocation.bottomCenter,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showCenteredToast(
          context,
          title: 'Error al generar PDF',
          subtitle: 'No se pudo crear el reporte: $e',
          icon: material.Icons.error,
          iconColor: const Color(0xFFEF4444),
          location: ToastLocation.bottomCenter,
        );
      }
    }
  }

  Future<void> _generatePDFReport(
    BuildContext context,
    List<Map<String, dynamic>> surveys,
    SurveyService surveyService,
    Map<String, double> stats,
  ) async {
    try {
      final pdf = pw.Document();
      final surveyTypeName = _selectedSurveyType == 1 ? 'BDI-II' : 'BAI';
      final surveyFullName = _selectedSurveyType == 1
          ? 'Inventario de Depresión de Beck II'
          : 'Inventario de Ansiedad de Beck';

      final fontRegular = await PdfGoogleFonts.notoSansRegular();
      final fontBold = await PdfGoogleFonts.notoSansBold();

      pw.TextStyle pdfStyle({double fontSize = 10, bool bold = false, PdfColor? color}) =>
          pw.TextStyle(font: bold ? fontBold : fontRegular, fontSize: fontSize, color: color);

      final distribution = <String, int>{
        'Mínima': 0,
        'Leve': 0,
        'Moderada': 0,
        'Severa': 0,
      };

      for (var survey in surveys) {
        final score = ReportsController.calculateSurveyScore(survey);
        final level = _getLevelText(score, _selectedSurveyType);
        if (distribution.containsKey(level)) {
          distribution[level] = distribution[level]! + 1;
        }
      }

      final scoreRanges = _selectedSurveyType == 1
          ? {'Mínima': '0-13', 'Leve': '14-19', 'Moderada': '20-28', 'Severa': '29-63'}
          : {'Mínima': '0-7', 'Leve': '8-15', 'Moderada': '16-25', 'Severa': '26-63'};

      final pieColors = [PdfColors.green400, PdfColors.yellow600, PdfColors.orange400, PdfColors.red400];

      final total = distribution.values.fold(0, (a, b) => a + b);
      final maxDist = distribution.values.isEmpty
          ? 1
          : distribution.values.reduce((a, b) => a > b ? a : b);

      final sortedSurveys = List<Map<String, dynamic>>.from(surveys)
        ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
      final timelineScores = sortedSurveys
          .map((s) => ReportsController.calculateSurveyScore(s))
          .toList();
      final maxTS = timelineScores.isEmpty
          ? 5.0
          : timelineScores.reduce((a, b) => a > b ? a : b).toDouble();

      final statMin = (stats['min'] ?? 0).toInt();
      final statMax = (stats['max'] ?? 0).toInt();
      final statMean = stats['mean'] ?? 0.0;
      final statMedian = stats['median'] ?? 0.0;
      final statMode = stats['mode'] ?? 0.0;
      final statStdDev = stats['stdDev'] ?? 0.0;
      final statRange = statMax - statMin;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
          build: (pw.Context ctx) => [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Reporte de Analisis Estadistico',
                style: pw.TextStyle(font: fontBold, fontSize: 22, color: PdfColors.blue800)),
              pw.SizedBox(height: 4),
              pw.Text(surveyFullName,
                style: pw.TextStyle(font: fontRegular, fontSize: 14, color: PdfColors.grey700)),
              pw.SizedBox(height: 4),
              pw.Text(
                'Generado el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}  |  Total: ${surveys.length} encuestas',
                style: pw.TextStyle(font: fontRegular, fontSize: 11, color: PdfColors.grey600)),
              pw.Divider(thickness: 2, color: PdfColors.blue800),
            ]),
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(color: PdfColors.blue50, borderRadius: pw.BorderRadius.circular(8)),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Resumen Ejecutivo', style: pdfStyle(fontSize: 14, bold: true, color: PdfColors.blue900)),
                pw.SizedBox(height: 8),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  _buildStatItemF('Total', surveys.length.toString(), fontRegular, fontBold),
                  _buildStatItemF('Minimo', statMin.toString(), fontRegular, fontBold),
                  _buildStatItemF('Maximo', statMax.toString(), fontRegular, fontBold),
                  _buildStatItemF('Rango', statRange.toString(), fontRegular, fontBold),
                ]),
              ]),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Medidas de Tendencia Central', style: pdfStyle(fontSize: 16, bold: true)),
            pw.SizedBox(height: 8),
            pw.Table(border: pw.TableBorder.all(color: PdfColors.grey400), children: [
              pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey200), children: [
                _buildTableHeaderF('Medida', fontBold),
                _buildTableHeaderF('Valor', fontBold),
                _buildTableHeaderF('Interpretacion', fontBold),
              ]),
              _buildTableRowF('Media', statMean.toStringAsFixed(2), 'Promedio aritmetico', fontRegular),
              _buildTableRowF('Mediana', statMedian.toStringAsFixed(2), 'Valor central', fontRegular),
              _buildTableRowF('Moda', statMode.toStringAsFixed(0), 'Puntaje mas frecuente', fontRegular),
              _buildTableRowF('Desv. Estandar', statStdDev.toStringAsFixed(2), 'Medida de dispersion', fontRegular),
            ]),
            pw.SizedBox(height: 20),
            pw.Text('Distribucion por Nivel de Severidad', style: pdfStyle(fontSize: 16, bold: true)),
            pw.SizedBox(height: 8),
            pw.Table(border: pw.TableBorder.all(color: PdfColors.grey400), children: [
              pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey200), children: [
                _buildTableHeaderF('Nivel', fontBold),
                _buildTableHeaderF('Rango', fontBold),
                _buildTableHeaderF('Cantidad', fontBold),
                _buildTableHeaderF('Porcentaje', fontBold),
              ]),
              ...distribution.entries.map((entry) {
                final pct = total == 0 ? '0.0%' : '${(entry.value / total * 100).toStringAsFixed(1)}%';
                return pw.TableRow(children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(entry.key, style: pdfStyle())),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(scoreRanges[entry.key] ?? '', style: pdfStyle())),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(entry.value.toString(), style: pdfStyle())),
                  pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(pct, style: pdfStyle())),
                ]);
              }).toList(),
            ]),
            pw.SizedBox(height: 20),
            pw.Text('Grafica 1: Distribucion por Nivel de Severidad', style: pdfStyle(fontSize: 16, bold: true)),
            pw.SizedBox(height: 4),
            pw.Text('Eje X: Nivel  |  Eje Y: Numero de encuestados', style: pdfStyle(fontSize: 9, color: PdfColors.grey600)),
            pw.SizedBox(height: 8),
            pw.SizedBox(
              height: 200,
              child: pw.Chart(
                grid: pw.CartesianGrid(
                  xAxis: pw.FixedAxis.fromStrings(['Minima', 'Leve', 'Moderada', 'Severa'], marginStart: 10, marginEnd: 10, ticks: true),
                  yAxis: pw.FixedAxis([0, (maxDist + 1).toDouble()], divisions: true),
                ),
                datasets: [
                  pw.BarDataSet(
                    color: _selectedSurveyType == 1 ? PdfColors.blue400 : PdfColors.teal400,
                    width: 30, offset: 0,
                    borderColor: _selectedSurveyType == 1 ? PdfColors.blue700 : PdfColors.teal700,
                    data: [
                      pw.PointChartValue(0, (distribution['Mínima'] ?? 0).toDouble()),
                      pw.PointChartValue(1, (distribution['Leve'] ?? 0).toDouble()),
                      pw.PointChartValue(2, (distribution['Moderada'] ?? 0).toDouble()),
                      pw.PointChartValue(3, (distribution['Severa'] ?? 0).toDouble()),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Grafica 2: Proporcion por Nivel de Severidad', style: pdfStyle(fontSize: 16, bold: true)),
            pw.SizedBox(height: 4),
            pw.Text('Distribucion porcentual de encuestados por nivel', style: pdfStyle(fontSize: 9, color: PdfColors.grey600)),
            pw.SizedBox(height: 12),
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
              pw.SizedBox(
                width: 180, height: 180,
                child: pw.CustomPaint(
                  painter: (canvas, size) {
                    final cx = size.x / 2;
                    final cy = size.y / 2;
                    final r = size.x / 2 - 4;
                    final vals = [
                      (distribution['Mínima'] ?? 0).toDouble(),
                      (distribution['Leve'] ?? 0).toDouble(),
                      (distribution['Moderada'] ?? 0).toDouble(),
                      (distribution['Severa'] ?? 0).toDouble(),
                    ];
                    final tv = vals.fold<double>(0.0, (a, b) => a + b);
                    if (tv == 0) return;
                    double startAng = -math.pi / 2;
                    for (int i = 0; i < vals.length; i++) {
                      if (vals[i] == 0) continue;
                      final sweepAng = vals[i] / tv * 2 * math.pi;
                      canvas.setFillColor(pieColors[i]);
                      _drawPdfSector(canvas, cx, cy, r, startAng, sweepAng);
                      startAng += sweepAng;
                    }
                    // Agujero central (donut)
                    canvas.setFillColor(PdfColors.white);
                    _drawPdfCircle(canvas, cx, cy, r * 0.38);
                  },
                ),
              ),
              pw.SizedBox(width: 24),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text('Total: $total encuestados', style: pdfStyle(fontSize: 11, bold: true)),
                    pw.SizedBox(height: 10),
                    ...distribution.entries.toList().asMap().entries.map((e) {
                      final pct2 = total == 0 ? 0.0 : e.value.value / total * 100;
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Row(children: [
                          pw.Container(width: 12, height: 12,
                            decoration: pw.BoxDecoration(color: pieColors[e.key], borderRadius: pw.BorderRadius.circular(2))),
                          pw.SizedBox(width: 6),
                          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                            pw.Text(e.value.key, style: pdfStyle(fontSize: 10, bold: true)),
                            pw.Text('${e.value.value} (${pct2.toStringAsFixed(1)}%)  Rango: ${scoreRanges[e.value.key] ?? ''}',
                              style: pdfStyle(fontSize: 9, color: PdfColors.grey700)),
                          ])),
                        ]),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ]),
            pw.SizedBox(height: 20),
            if (timelineScores.length > 1) ...[
              pw.Text('Grafica 3: Tendencia Temporal de Puntajes', style: pdfStyle(fontSize: 16, bold: true)),
              pw.SizedBox(height: 4),
              pw.Text('Eje X: N de encuesta (cronologico)  |  Eje Y: Puntaje', style: pdfStyle(fontSize: 9, color: PdfColors.grey600)),
              pw.SizedBox(height: 8),
              pw.SizedBox(
                height: 200,
                child: pw.Chart(
                  grid: pw.CartesianGrid(
                    xAxis: pw.FixedAxis(
                      () {
                        final n = timelineScores.length;
                        const maxLabels = 8;
                        final step = (n / maxLabels).ceil().clamp(1, n);
                        return [
                          for (int i = 0; i < n; i += step) i.toDouble(),
                          if ((n - 1) % step != 0) (n - 1).toDouble(),
                        ];
                      }(),
                      divisions: false,
                      ticks: true,
                    ),
                    yAxis: pw.FixedAxis([0, maxTS + 5], divisions: true),
                  ),
                  datasets: [
                    pw.LineDataSet(
                      color: _selectedSurveyType == 1 ? PdfColors.blue600 : PdfColors.teal600,
                      lineWidth: 2, drawPoints: true,
                      pointColor: _selectedSurveyType == 1 ? PdfColors.blue900 : PdfColors.teal900,
                      data: timelineScores.asMap().entries
                          .map((e) => pw.PointChartValue(e.key.toDouble(), e.value.toDouble())).toList(),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
            ],
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.blue300, width: 1.5), borderRadius: pw.BorderRadius.circular(6)),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Interpretacion de Resultados', style: pdfStyle(fontSize: 13, bold: true, color: PdfColors.blue900)),
                pw.SizedBox(height: 6),
                pw.Text(_getInterpretation(statMean, _selectedSurveyType), style: pdfStyle(fontSize: 10)),
              ]),
            ),
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Nota Importante:', style: pdfStyle(fontSize: 10, bold: true)),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Este reporte es generado automaticamente con fines estadisticos. Los resultados deben ser interpretados por un profesional de la salud mental calificado.',
                  style: pw.TextStyle(font: fontRegular, fontSize: 9)),
              ]),
            ),
          ],
        ),
      );

      final pdfBytes = await pdf.save();
      final fileName = 'reporte_${surveyTypeName}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      if (kIsWeb) {
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(pdfBytes);
        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], text: 'Reporte PDF $surveyTypeName'),
        );
      }

      if (context.mounted) {
        showCenteredToast(
          context,
          title: 'Reporte generado',
          subtitle: 'PDF $surveyTypeName descargado exitosamente',
          icon: material.Icons.check_circle,
          iconColor: const Color(0xFF10B981),
          location: ToastLocation.bottomCenter,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showCenteredToast(
          context,
          title: 'Error al generar PDF',
          subtitle: 'No se pudo crear el reporte: $e',
          icon: material.Icons.error,
          iconColor: const Color(0xFFEF4444),
          location: ToastLocation.bottomCenter,
        );
      }
    }
  }

  void _drawPdfSector(
    PdfGraphics canvas,
    double cx,
    double cy,
    double r,
    double startAngle,
    double sweepAngle,
  ) {
    const maxStep = math.pi / 2;
    canvas.moveTo(cx, cy);
    double a = startAngle;
    double remaining = sweepAngle;
    while (remaining > 0) {
      final step = remaining > maxStep ? maxStep : remaining;
      _addArcSegment(canvas, cx, cy, r, a, step);
      a += step;
      remaining -= step;
    }
    canvas.lineTo(cx, cy);
    canvas.fillPath();
  }

  void _addArcSegment(
    PdfGraphics canvas,
    double cx,
    double cy,
    double r,
    double startAngle,
    double sweepAngle,
  ) {
    final endAngle = startAngle + sweepAngle;
    final k = (4.0 / 3.0) * math.tan(sweepAngle / 4);
    final x0 = cx + r * math.cos(startAngle);
    final y0 = cy + r * math.sin(startAngle);
    final x1 = x0 - k * r * math.sin(startAngle);
    final y1 = y0 + k * r * math.cos(startAngle);
    final x3 = cx + r * math.cos(endAngle);
    final y3 = cy + r * math.sin(endAngle);
    final x2 = x3 + k * r * math.sin(endAngle);
    final y2 = y3 - k * r * math.cos(endAngle);
    canvas.lineTo(x0, y0);
    canvas.curveTo(x1, y1, x2, y2, x3, y3);
  }

  void _drawPdfCircle(PdfGraphics canvas, double cx, double cy, double r) {
    _drawPdfSector(canvas, cx, cy, r, 0, 2 * math.pi);
  }

  pw.Widget _buildStatItemF(String label, String value, pw.Font fontRegular, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 16, color: PdfColors.blue900)),
        pw.SizedBox(height: 2),
        pw.Text(label, style: pw.TextStyle(font: fontRegular, fontSize: 9, color: PdfColors.grey700)),
      ],
    );
  }

  pw.Widget _buildTableHeaderF(String text, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: pw.TextStyle(font: fontBold, fontSize: 10)),
    );
  }

  pw.TableRow _buildTableRowF(String col1, String col2, String col3, pw.Font fontRegular) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(col1, style: pw.TextStyle(font: fontRegular, fontSize: 10))),
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(col2, style: pw.TextStyle(font: fontRegular, fontSize: 10))),
        pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(col3, style: pw.TextStyle(font: fontRegular, fontSize: 10))),
      ],
    );
  }

  String _getInterpretation(double mean, int surveyType) {
    if (surveyType == 1) return ReportsController.bdiInterpretation(mean);
    return ReportsController.baiInterpretation(mean);
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final material.IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.foreground,
                      ),
                    ),
                  ),
                  Text(title,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.foreground,
              ),
            ),
          ),
          const Gap(2),
          Text(title,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _LevelDistributionChart extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  final SurveyService surveyService;
  final int surveyType;

  const _LevelDistributionChart({
    required this.surveys,
    required this.surveyService,
    required this.surveyType,
  });

  String _getLevel(int score, int surveyType) {
    if (surveyType == 1) {
      if (score <= 13) return 'minimal';
      if (score <= 19) return 'mild';
      if (score <= 28) return 'moderate';
      return 'severe';
    } else {
      if (score <= 7) return 'minimal';
      if (score <= 15) return 'mild';
      if (score <= 25) return 'moderate';
      return 'severe';
    }
  }

  @override
  Widget build(BuildContext context) {
    final distribution = <String, int>{
      'minimal': 0,
      'mild': 0,
      'moderate': 0,
      'severe': 0,
    };

    for (var survey in surveys) {
      final score = ReportsController.calculateSurveyScore(survey);
      final level = _getLevel(score, surveyType);
      distribution[level] = distribution[level]! + 1;
    }

    final levels = ['minimal', 'mild', 'moderate', 'severe'];

    final barGroups = levels.asMap().entries.map((entry) {
      final index = entry.key;
      final level = entry.value;
      final count = distribution[level] ?? 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: _getLevelColor(level),
            width: 40,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (distribution.values.isEmpty ? 10 : distribution.values.reduce(math.max)).toDouble() + 2,
              barGroups: barGroups,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameWidget: Text(
                    'Número de encuestados',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.mutedForeground,
                      fontSize: 11,
                    ),
                  ),
                  axisNameSize: 22,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.mutedForeground,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: Text(
                    'Nivel de severidad',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.mutedForeground,
                      fontSize: 11,
                    ),
                  ),
                  axisNameSize: 22,
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final labels = ['Mínima', 'Leve', 'Moderada', 'Severa'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          labels[value.toInt()],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.mutedForeground,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Theme.of(context).colorScheme.border,
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final labels = ['Mínima', 'Leve', 'Moderada', 'Severa'];
                    final count = rod.toY.toInt();
                    final total = distribution.values.reduce((a, b) => a + b);
                    final pct = total == 0 ? '0.0' : (count / total * 100).toStringAsFixed(1);
                    return BarTooltipItem(
                      '${labels[group.x]}\n$count encuestados\n$pct%',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Leyenda de colores
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _LegendItem(color: const Color(0xFF10B981), label: 'Mínima'),
            _LegendItem(color: const Color(0xFFFBBF24), label: 'Leve'),
            _LegendItem(color: const Color(0xFFF97316), label: 'Moderada'),
            _LegendItem(color: const Color(0xFFEF4444), label: 'Severa'),
          ],
        ),
      ],
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'minimal':
        return const Color(0xFF10B981);
      case 'mild':
        return const Color(0xFFFBBF24);
      case 'moderate':
        return const Color(0xFFF97316);
      case 'severe':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

class _TimelineChart extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  final SurveyService surveyService;

  const _TimelineChart({
    required this.surveys,
    required this.surveyService,
  });

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) {
      return const Center(child: Text('No hay datos para mostrar'));
    }

    final sortedSurveys = List<Map<String, dynamic>>.from(surveys)
      ..sort((a, b) {
        final aTime = DateTime.parse(a['created_at']);
        final bTime = DateTime.parse(b['created_at']);
        return aTime.compareTo(bTime);
      });

    final spots = sortedSurveys.asMap().entries.map((entry) {
      final score = ReportsController.calculateSurveyScore(entry.value);
      return FlSpot(entry.key.toDouble(), score.toDouble());
    }).toList();

    final maxScore = spots.map((s) => s.y).reduce(math.max);

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF3B82F6),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF3B82F6),
                  strokeWidth: 2,
                  strokeColor: Theme.of(context).colorScheme.background,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              'Puntaje',
              style: TextStyle(
                color: Theme.of(context).colorScheme.mutedForeground,
                fontSize: 11,
              ),
            ),
            axisNameSize: 22,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.mutedForeground,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: Text(
              'N.° de encuesta (orden cronológico)',
              style: TextStyle(
                color: Theme.of(context).colorScheme.mutedForeground,
                fontSize: 11,
              ),
            ),
            axisNameSize: 22,
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= sortedSurveys.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '#${value.toInt() + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.mutedForeground,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) {
              final idx = s.x.toInt();
              final date = idx < sortedSurveys.length
                  ? DateTime.parse(sortedSurveys[idx]['created_at'])
                  : null;
              final dateStr = date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : '';
              return LineTooltipItem(
                'Encuesta #${idx + 1}\nPuntaje: ${s.y.toInt()}\n$dateStr',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            }).toList(),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).colorScheme.border,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: maxScore + 5,
      ),
    );
  }
}

class _SeverityPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  final SurveyService surveyService;
  final int surveyType;

  const _SeverityPieChart({
    required this.surveys,
    required this.surveyService,
    required this.surveyType,
  });

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) {
      return const Center(child: Text('No hay datos para mostrar'));
    }

    final distribution = <String, int>{
      'Mínima': 0,
      'Leve': 0,
      'Moderada': 0,
      'Severa': 0,
    };
    final scoreRanges = <String, String>{};

    for (var survey in surveys) {
      final score = ReportsController.calculateSurveyScore(survey);
      final level = _getLevel(score, surveyType);
      final labelMap = {
        'minimal': 'Mínima',
        'mild': 'Leve',
        'moderate': 'Moderada',
        'severe': 'Severa',
      };
      final label = labelMap[level]!;
      distribution[label] = distribution[label]! + 1;
    }

    if (surveyType == 1) {
      scoreRanges['Mínima'] = '0–13';
      scoreRanges['Leve'] = '14–19';
      scoreRanges['Moderada'] = '20–28';
      scoreRanges['Severa'] = '29–63';
    } else {
      scoreRanges['Mínima'] = '0–7';
      scoreRanges['Leve'] = '8–15';
      scoreRanges['Moderada'] = '16–25';
      scoreRanges['Severa'] = '26–63';
    }

    final total = distribution.values.fold(0, (a, b) => a + b);
    final colors = {
      'Mínima': const Color(0xFF10B981),
      'Leve': const Color(0xFFFBBF24),
      'Moderada': const Color(0xFFF97316),
      'Severa': const Color(0xFFEF4444),
    };

    int touchedIndex = -1;

    return StatefulBuilder(
      builder: (context, setState) {
        final sections = distribution.entries.toList().asMap().entries.map((e) {
          final idx = e.key;
          final entry = e.value;
          final pct = total == 0 ? 0.0 : entry.value / total * 100;
          final isTouched = idx == touchedIndex;
          return PieChartSectionData(
            value: entry.value.toDouble() == 0 ? 0.001 : entry.value.toDouble(),
            color: colors[entry.key]!,
            title: pct < 5 ? '' : '${pct.toStringAsFixed(1)}%',
            radius: isTouched ? 90 : 75,
            titleStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: material.Colors.white,
              shadows: const [Shadow(blurRadius: 2, color: material.Color(0x88000000))],
            ),
            badgeWidget: entry.value == 0 ? null : null,
          );
        }).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 400;

            final legend = Column(
              mainAxisAlignment: isNarrow ? MainAxisAlignment.start : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: $total',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                for (final entry in distribution.entries)
                  Builder(builder: (context) {
                    final pct = total == 0 ? 0.0 : entry.value / total * 100;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: colors[entry.key],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${entry.value} (${pct.toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.mutedForeground,
                                  ),
                                ),
                                Text(
                                  'Puntaje: ${scoreRanges[entry.key]}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context).colorScheme.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            );

            final pieWidget = PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: isNarrow ? 40 : 50,
                sectionsSpace: 3,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
              ),
            );

            return Column(
              children: [
                if (isNarrow) ...[
                  SizedBox(height: 200, child: pieWidget),
                  const SizedBox(height: 16),
                  legend,
                ] else ...[
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: pieWidget),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: legend),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Toca un segmento para resaltarlo',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.mutedForeground,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getLevel(int score, int surveyType) {
    if (surveyType == 1) {
      if (score <= 13) return 'minimal';
      if (score <= 19) return 'mild';
      if (score <= 28) return 'moderate';
      return 'severe';
    } else {
      if (score <= 7) return 'minimal';
      if (score <= 15) return 'mild';
      if (score <= 25) return 'moderate';
      return 'severe';
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WHOQOL Report Section
// ─────────────────────────────────────────────────────────────

const _kWhoqolColor = Color(0xFF7C3AED);
const _kDom1Color = Color(0xFF0EA5E9); // salud física
const _kDom2Color = Color(0xFF8B5CF6); // psicológica
const _kDom3Color = Color(0xFF10B981); // relaciones
const _kDom4Color = Color(0xFFF59E0B); // ambiente

class _WhoqolReportSection extends StatelessWidget {
  final WhoqolReportData data;
  const _WhoqolReportSection({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Global stats ──────────────────────────────────
        const Text('Estadísticas Globales',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Gap(12),
        LayoutBuilder(builder: (context, constraints) {
          final cardW = (constraints.maxWidth - 12) / 2;
          final statH = (cardW * 0.48).clamp(72.0, 110.0);
          final infoH = (cardW * 0.32).clamp(56.0, 80.0);
          return Column(children: [
            GridView.count(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: cardW / statH,
              children: [
                _StatCard(title: 'Media Global', value: data.globalStats.mean.toStringAsFixed(1),
                    icon: material.Icons.analytics, color: _kWhoqolColor),
                _StatCard(title: 'Mediana', value: data.globalStats.median.toStringAsFixed(1),
                    icon: material.Icons.show_chart, color: const Color(0xFF3B82F6)),
                _StatCard(title: 'Desv. Estándar', value: data.globalStats.stdDev.toStringAsFixed(2),
                    icon: material.Icons.scatter_plot, color: const Color(0xFFF59E0B)),
                _StatCard(title: 'Encuestas', value: data.surveyCount.toString(),
                    icon: material.Icons.assignment, color: const Color(0xFF10B981)),
              ],
            ),
            const Gap(12),
            GridView.count(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: cardW / infoH,
              children: [
                _InfoCard(title: 'Puntaje Mínimo', value: data.globalStats.min.toInt().toString()),
                _InfoCard(title: 'Puntaje Máximo', value: data.globalStats.max.toInt().toString()),
                _InfoCard(title: 'Rango', value: data.globalStats.range.toInt().toString()),
                _InfoCard(title: 'Max. posible', value: '130'),
              ],
            ),
          ]);
        }),
        const Gap(24),

        // ── Q1 / Q2 ──────────────────────────────────────
        const Text('Ítems Globales (Q1 y Q2)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Gap(12),
        Row(children: [
          Expanded(child: _WhoqolItemBarChart(
            title: 'Q1 — Calidad de vida',
            distribution: data.globalItems.q1Distribution,
            color: _kWhoqolColor,
            labels: const ['Muy mala','Poco','Lo normal','Bastante buena','Muy buena'],
          )),
          const Gap(12),
          Expanded(child: _WhoqolItemBarChart(
            title: 'Q2 — Satisfacción con salud',
            distribution: data.globalItems.q2Distribution,
            color: const Color(0xFF3B82F6),
            labels: const ['Muy insatisfecho','Insatisfecho','Lo normal','Bastante satisfecho','Muy satisfecho'],
          )),
        ]),
        const Gap(24),

        // ── Domain stats cards ───────────────────────────
        const Text('Estadísticas por Dominio',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Gap(12),
        _WhoqolDomainCards(data: data),
        const Gap(24),

        // ── Domain bar chart ─────────────────────────────
        SurfaceCard(
          child: Padding(padding: const EdgeInsets.all(24), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Distribución por Dominio (media)').semiBold().large(),
              const Gap(4),
              Text('Mayor puntaje = mejor calidad de vida',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.mutedForeground)),
              const Gap(24),
              SizedBox(height: 280, child: _WhoqolDomainBarChart(data: data)),
            ],
          )),
        ),
        const Gap(24),

        // ── Timeline: global ────────────────────────────
        SurfaceCard(
          child: Padding(padding: const EdgeInsets.all(24), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tendencia Temporal — Puntaje Global').semiBold().large(),
              const Gap(24),
              SizedBox(height: 280, child: _WhoqolTimelineChart(
                scores: data.globalTimeline,
                color: _kWhoqolColor,
                maxY: 130,
              )),
            ],
          )),
        ),
        const Gap(24),

        // ── Timeline: domains ────────────────────────────
        SurfaceCard(
          child: Padding(padding: const EdgeInsets.all(24), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tendencia Temporal por Dominio').semiBold().large(),
              const Gap(24),
              SizedBox(height: 280, child: _WhoqolMultiTimelineChart(data: data)),
            ],
          )),
        ),
        const Gap(24),

        // ── Pie: domain proportion ───────────────────────
        SurfaceCard(
          child: Padding(padding: const EdgeInsets.all(24), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Proporción por Dominio (suma total)').semiBold().large(),
              const Gap(4),
              Text('Basado en la suma de medias de cada dominio',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.mutedForeground)),
              const Gap(24),
              LayoutBuilder(builder: (ctx, c) {
                final isNarrow = c.maxWidth < 400;
                return SizedBox(
                  height: isNarrow ? 460 : 300,
                  child: _WhoqolDomainPieChart(data: data, isNarrow: isNarrow),
                );
              }),
            ],
          )),
        ),
      ],
    );
  }
}

// ── Q1/Q2 mini bar chart ─────────────────────────────────────

class _WhoqolItemBarChart extends StatelessWidget {
  final String title;
  final Map<String, int> distribution;
  final Color color;
  final List<String> labels;

  const _WhoqolItemBarChart({
    required this.title,
    required this.distribution,
    required this.color,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = distribution.values.isEmpty ? 1
        : distribution.values.reduce(math.max).toDouble();
    return SurfaceCard(
      child: Padding(padding: const EdgeInsets.all(12), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const Gap(12),
          SizedBox(
            height: 160,
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxVal + 1,
              barGroups: distribution.entries.toList().asMap().entries.map((e) {
                return BarChartGroupData(x: e.key, barRods: [
                  BarChartRodData(
                    toY: e.value.value.toDouble(),
                    color: color,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ]);
              }).toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${v.toInt() + 1}',
                        style: TextStyle(fontSize: 10,
                            color: Theme.of(context).colorScheme.mutedForeground)),
                  ),
                )),
                leftTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true, reservedSize: 24,
                  getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                      style: TextStyle(fontSize: 9,
                          color: Theme.of(context).colorScheme.mutedForeground)),
                )),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                    '${labels[group.x]}\n${rod.toY.toInt()} respuestas',
                    const TextStyle(color: material.Colors.white, fontSize: 11),
                  ),
                ),
              ),
            )),
          ),
          const Gap(6),
          Wrap(spacing: 8, runSpacing: 4, children: labels.asMap().entries.map((e) =>
            Text('${e.key + 1}: ${e.value}',
                style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.mutedForeground)),
          ).toList()),
        ],
      )),
    );
  }
}

// ── Domain summary cards ─────────────────────────────────────

class _WhoqolDomainCards extends StatelessWidget {
  final WhoqolReportData data;
  const _WhoqolDomainCards({required this.data});

  @override
  Widget build(BuildContext context) {
    final doms = [
      (data.dom1, _kDom1Color),
      (data.dom2, _kDom2Color),
      (data.dom3, _kDom3Color),
      (data.dom4, _kDom4Color),
    ];
    return Column(
      children: doms.map((pair) {
        final dom = pair.$1;
        final color = pair.$2;
        final pct = dom.maxPossible == 0 ? 0.0 : dom.mean / dom.maxPossible * 100;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OutlinedContainer(
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.all(14),
            borderColor: color.withValues(alpha: 0.3),
            borderWidth: 1.5,
            backgroundColor: color.withValues(alpha: 0.04),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 10, height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const Gap(8),
                Expanded(child: Text(dom.label,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                Text('${dom.mean.toStringAsFixed(1)} / ${dom.maxPossible}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
              ]),
              const Gap(8),
              // progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: material.LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 8,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const Gap(6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Media: ${dom.mean.toStringAsFixed(1)}  |  '
                    'σ: ${dom.stdDev.toStringAsFixed(1)}  |  '
                    'n: ${dom.count}',
                    style: TextStyle(fontSize: 11,
                        color: Theme.of(context).colorScheme.mutedForeground)),
                Text('${pct.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              ]),
              const Gap(4),
              Text(ReportsController.whoqolDomainInterpretation(dom),
                  style: TextStyle(fontSize: 11,
                      color: Theme.of(context).colorScheme.mutedForeground)),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ── Domain grouped bar chart ─────────────────────────────────

class _WhoqolDomainBarChart extends StatelessWidget {
  final WhoqolReportData data;
  const _WhoqolDomainBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final domData = [
      (data.dom1, _kDom1Color, 'F'),
      (data.dom2, _kDom2Color, 'P'),
      (data.dom3, _kDom3Color, 'R'),
      (data.dom4, _kDom4Color, 'A'),
    ];
    final barGroups = domData.asMap().entries.map((e) {
      return BarChartGroupData(x: e.key, barRods: [
        BarChartRodData(
          toY: e.value.$1.mean,
          color: e.value.$2,
          width: 36,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ]);
    }).toList();

    return Column(children: [
      Expanded(child: BarChart(BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 40,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final labels = ['Física', 'Psicológica', 'Relaciones', 'Ambiente'];
              return Padding(padding: const EdgeInsets.only(top: 6),
                child: Text(labels[v.toInt()],
                    style: TextStyle(fontSize: 11,
                        color: Theme.of(context).colorScheme.mutedForeground)));
            },
          )),
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 36,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                style: TextStyle(fontSize: 10,
                    color: Theme.of(context).colorScheme.mutedForeground)),
          )),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false,
            getDrawingHorizontalLine: (v) =>
                FlLine(color: Theme.of(context).colorScheme.border, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, __) {
              final labels = ['Salud Física','Salud Psicológica','Relaciones Sociales','Ambiente'];
              final dom = [data.dom1, data.dom2, data.dom3, data.dom4][group.x];
              return BarTooltipItem(
                '${labels[group.x]}\nMedia: ${rod.toY.toStringAsFixed(1)} / ${dom.maxPossible}',
                const TextStyle(color: material.Colors.white, fontSize: 11),
              );
            },
          ),
        ),
      ))),
      const Gap(8),
      Wrap(spacing: 16, runSpacing: 4, alignment: WrapAlignment.center, children: [
        _LegendItem(color: _kDom1Color, label: 'Salud Física'),
        _LegendItem(color: _kDom2Color, label: 'Psicológica'),
        _LegendItem(color: _kDom3Color, label: 'Relaciones'),
        _LegendItem(color: _kDom4Color, label: 'Ambiente'),
      ]),
    ]);
  }
}

// ── Single-series timeline ───────────────────────────────────

class _WhoqolTimelineChart extends StatelessWidget {
  final List<double> scores;
  final Color color;
  final double maxY;

  const _WhoqolTimelineChart({
    required this.scores,
    required this.color,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    if (scores.length < 2) {
      return Center(child: Text('Se necesitan al menos 2 encuestas para mostrar tendencia',
          style: TextStyle(color: Theme.of(context).colorScheme.mutedForeground)));
    }
    final spots = scores.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots, isCurved: true, color: color, barWidth: 3,
          dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) =>
              FlDotCirclePainter(radius: 4, color: color, strokeWidth: 2,
                  strokeColor: Theme.of(context).colorScheme.background)),
          belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.1)),
        ),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          axisNameWidget: Text('Puntaje', style: TextStyle(
              fontSize: 11, color: Theme.of(context).colorScheme.mutedForeground)),
          axisNameSize: 22,
          sideTitles: SideTitles(showTitles: true, reservedSize: 40,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.mutedForeground)),
          ),
        ),
        bottomTitles: AxisTitles(
          axisNameWidget: Text('N.° de encuesta (cronológico)', style: TextStyle(
              fontSize: 11, color: Theme.of(context).colorScheme.mutedForeground)),
          axisNameSize: 22,
          sideTitles: SideTitles(showTitles: true,
            getTitlesWidget: (v, _) => Padding(padding: const EdgeInsets.only(top: 6),
              child: Text('#${v.toInt() + 1}', style: TextStyle(fontSize: 11,
                  color: Theme.of(context).colorScheme.mutedForeground))),
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: true, drawVerticalLine: false,
          getDrawingHorizontalLine: (v) =>
              FlLine(color: Theme.of(context).colorScheme.border, strokeWidth: 1)),
      borderData: FlBorderData(show: false),
      minY: 0, maxY: maxY,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) => touchedSpots.map((s) => LineTooltipItem(
            'Encuesta #${s.x.toInt() + 1}\nPuntaje: ${s.y.toInt()}',
            const TextStyle(color: material.Colors.white, fontSize: 12),
          )).toList(),
        ),
      ),
    ));
  }
}

// ── Multi-series domain timeline ─────────────────────────────

class _WhoqolMultiTimelineChart extends StatelessWidget {
  final WhoqolReportData data;
  const _WhoqolMultiTimelineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final series = [
      (data.dom1Timeline, _kDom1Color, 'Física'),
      (data.dom2Timeline, _kDom2Color, 'Psicológica'),
      (data.dom3Timeline, _kDom3Color, 'Relaciones'),
      (data.dom4Timeline, _kDom4Color, 'Ambiente'),
    ].where((s) => s.$1.length >= 2).toList();

    if (series.isEmpty) {
      return Center(child: Text('Se necesitan al menos 2 encuestas',
          style: TextStyle(color: Theme.of(context).colorScheme.mutedForeground)));
    }

    return Column(children: [
      Expanded(child: LineChart(LineChartData(
        lineBarsData: series.map((s) => LineChartBarData(
          spots: s.$1.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
          isCurved: true, color: s.$2, barWidth: 2,
          dotData: FlDotData(show: s.$1.length <= 10),
          belowBarData: BarAreaData(show: false),
        )).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(fontSize: 10,
                color: Theme.of(context).colorScheme.mutedForeground)),
          )),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
            getTitlesWidget: (v, _) => Padding(padding: const EdgeInsets.only(top: 6),
              child: Text('#${v.toInt() + 1}', style: TextStyle(fontSize: 10,
                  color: Theme.of(context).colorScheme.mutedForeground))),
          )),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false,
            getDrawingHorizontalLine: (v) =>
                FlLine(color: Theme.of(context).colorScheme.border, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        minY: 0,
      ))),
      const Gap(8),
      Wrap(spacing: 16, runSpacing: 4, alignment: WrapAlignment.center,
        children: series.map((s) => _LegendItem(color: s.$2, label: s.$3)).toList()),
    ]);
  }
}

// ── Domain proportion pie chart ──────────────────────────────

class _WhoqolDomainPieChart extends StatefulWidget {
  final WhoqolReportData data;
  final bool isNarrow;
  const _WhoqolDomainPieChart({required this.data, required this.isNarrow});

  @override
  State<_WhoqolDomainPieChart> createState() => _WhoqolDomainPieChartState();
}

class _WhoqolDomainPieChartState extends State<_WhoqolDomainPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final doms = [
      (widget.data.dom1, _kDom1Color, 'Salud Física'),
      (widget.data.dom2, _kDom2Color, 'Salud Psicológica'),
      (widget.data.dom3, _kDom3Color, 'Relaciones Sociales'),
      (widget.data.dom4, _kDom4Color, 'Ambiente'),
    ];
    final total = doms.fold<double>(0, (s, d) => s + d.$1.mean);

    final sections = doms.asMap().entries.map((e) {
      final idx = e.key;
      final dom = e.value.$1;
      final color = e.value.$2;
      final pct = total == 0 ? 0.0 : dom.mean / total * 100;
      final isTouched = idx == _touchedIndex;
      return PieChartSectionData(
        value: dom.mean == 0 ? 0.001 : dom.mean,
        color: color,
        title: pct < 8 ? '' : '${pct.toStringAsFixed(1)}%',
        radius: isTouched ? 90 : 72,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
            color: material.Colors.white,
            shadows: [Shadow(blurRadius: 2, color: material.Color(0x88000000))]),
      );
    }).toList();

    final legend = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: doms.asMap().entries.map((e) {
        final dom = e.value.$1;
        final color = e.value.$2;
        final name = e.value.$3;
        final pct = total == 0 ? 0.0 : dom.mean / total * 100;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 12, height: 12, margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const Gap(8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Media: ${dom.mean.toStringAsFixed(1)} (${pct.toStringAsFixed(1)}%)',
                  style: TextStyle(fontSize: 11,
                      color: Theme.of(context).colorScheme.mutedForeground)),
            ])),
          ]),
        );
      }).toList(),
    );

    final pieWidget = PieChart(PieChartData(
      sections: sections,
      centerSpaceRadius: widget.isNarrow ? 40 : 50,
      sectionsSpace: 3,
      pieTouchData: PieTouchData(
        touchCallback: (FlTouchEvent event, resp) {
          setState(() {
            if (!event.isInterestedForInteractions || resp == null ||
                resp.touchedSection == null) {
              _touchedIndex = -1;
              return;
            }
            _touchedIndex = resp.touchedSection!.touchedSectionIndex;
          });
        },
      ),
    ));

    if (widget.isNarrow) {
      return Column(children: [
        SizedBox(height: 220, child: pieWidget),
        const Gap(16),
        legend,
      ]);
    }
    return Row(children: [
      Expanded(flex: 3, child: pieWidget),
      const Gap(12),
      Expanded(flex: 2, child: legend),
    ]);
  }
}

