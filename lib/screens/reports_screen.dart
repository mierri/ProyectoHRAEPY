import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' as material;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/Services/survey_service.dart';
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
  int _selectedSurveyType = 0; // 0 = Todas, 1 = BDI-II, 2 = BAI

  @override
  Widget build(BuildContext context) {
    final surveyService = context.watch<SurveyService>();
    final allSurveys = surveyService.getCompletedSurveys();

    // Filtrar por tipo de encuesta (0 = Todas)
    final surveys = _selectedSurveyType == 0
        ? allSurveys
        : allSurveys.where((s) {
            final surveyType = s['survey_type'] as int? ?? 1;
            return surveyType == _selectedSurveyType;
          }).toList();

    final stats = _calculateStatistics(surveys, surveyService);

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
                  Icon(
                    material.Icons.bar_chart,
                    size: 80,
                    color: Theme.of(context).colorScheme.mutedForeground,
                  ),
                  const Gap(16),
                  Text('No hay encuestas completadas',
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                  const Gap(8),
                  const Text('Completa algunas encuestas para ver estadísticas').muted().small(),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de tipo de encuesta
                  SurfaceCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          const Text('Tipo:').semiBold(),
                          const Gap(10),
                          Wrap(
                            spacing: 6,
                            children: [
                              _selectedSurveyType == 0
                                  ? PrimaryButton(
                                      onPressed: () => setState(() => _selectedSurveyType = 0),
                                      child: const Text('Todas'),
                                    )
                                  : OutlineButton(
                                      onPressed: () => setState(() => _selectedSurveyType = 0),
                                      child: const Text('Todas'),
                                    ),
                              _selectedSurveyType == 1
                                  ? PrimaryButton(
                                        onPressed: () => setState(() => _selectedSurveyType = 1),
                                      child: const Text('BDI-II'),
                                    )
                                  : OutlineButton(
                                      onPressed: () => setState(() => _selectedSurveyType = 1),
                                      child: const Text('BDI-II'),
                                    ),
                              _selectedSurveyType == 2
                                  ? PrimaryButton(
                                      onPressed: () => setState(() => _selectedSurveyType = 2),
                                      child: const Text('BAI'),
                                    )
                                  : OutlineButton(
                                      onPressed: () => setState(() => _selectedSurveyType = 2),
                                      child: const Text('BAI'),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(24),

                  // Botones de exportación
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlineButton(
                        onPressed: surveys.isEmpty ? null : () {
                          if (_selectedSurveyType == 0) {
                            _exportAllToCSV(context, allSurveys, surveyService);
                          } else {
                            _exportToSPSS(context, surveys, surveyService);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(material.Icons.table_chart, size: 14),
                            const Gap(4),
                            const Text('Exportar CSV'),
                          ],
                        ),
                      ),
                      PrimaryButton(
                        onPressed: surveys.isEmpty ? null : () {
                          if (_selectedSurveyType == 0) {
                            _generateFullPDFReport(context, allSurveys, surveyService);
                          } else {
                            _generatePDFReport(context, surveys, surveyService, stats);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(material.Icons.picture_as_pdf, size: 14),
                            const Gap(4),
                            const Text('Exportar PDF'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),

                  // Medidas de tendencia central
                  Text('Medidas de Tendencia Central',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // En tablet 8" (800px aprox), las tarjetas necesitan más altura
                      final cardW = (constraints.maxWidth - 12) / 2;
                      final statH = (cardW * 0.48).clamp(72.0, 110.0);
                      final infoH = (cardW * 0.32).clamp(56.0, 80.0);
                      return Column(
                        children: [
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: cardW / statH,
                            children: [
                              _StatCard(
                                title: 'Media',
                                value: stats['mean']!.toStringAsFixed(1),
                                icon: material.Icons.analytics,
                                color: const Color(0xFF3B82F6),
                              ),
                              _StatCard(
                                title: 'Mediana',
                                value: stats['median']!.toStringAsFixed(1),
                                icon: material.Icons.show_chart,
                                color: const Color(0xFF10B981),
                              ),
                              _StatCard(
                                title: 'Moda',
                                value: stats['mode']!.toStringAsFixed(0),
                                icon: material.Icons.timeline,
                                color: const Color(0xFF8B5CF6),
                              ),
                              _StatCard(
                                title: 'Desv. Estándar',
                                value: stats['stdDev']!.toStringAsFixed(2),
                                icon: material.Icons.scatter_plot,
                                color: const Color(0xFFF59E0B),
                              ),
                            ],
                          ),
                          const Gap(12),
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: cardW / infoH,
                            children: [
                              _InfoCard(
                                title: 'Total de Encuestas',
                                value: surveys.length.toString(),
                              ),
                              _InfoCard(
                                title: 'Puntaje Mínimo',
                                value: stats['min']!.toInt().toString(),
                              ),
                              _InfoCard(
                                title: 'Puntaje Máximo',
                                value: stats['max']!.toInt().toString(),
                              ),
                              _InfoCard(
                                title: 'Rango',
                                value: (stats['max']! - stats['min']!).toInt().toString(),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const Gap(24),

                  // Gráficas
                  Text('Distribución de Resultados',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(16),

                  // Gráfica de barras por nivel
                  SurfaceCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Distribución por Nivel de Severidad').semiBold().large(),
                          const Gap(24),
                          SizedBox(
                            height: 300,
                            child: _LevelDistributionChart(
                              surveys: surveys,
                              surveyService: surveyService,
                              surveyType: _selectedSurveyType == 0 ? 1 : _selectedSurveyType,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(24),

                  // Gráfica de línea temporal
                  SurfaceCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tendencia Temporal de Puntajes').semiBold().large(),
                          const Gap(24),
                          SizedBox(
                            height: 300,
                            child: _TimelineChart(
                              surveys: surveys,
                              surveyService: surveyService,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(24),

                  // Gráfica de pastel
                  SurfaceCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Proporción por Nivel de Severidad').semiBold().large(),
                          const Gap(4),
                          Text(
                            'Distribución porcentual de encuestados por nivel',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.mutedForeground,
                            ),
                          ),
                          const Gap(24),
                          SizedBox(
                            height: 320,
                            child: _SeverityPieChart(
                              surveys: surveys,
                              surveyService: surveyService,
                              surveyType: _selectedSurveyType == 0 ? 1 : _selectedSurveyType,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Map<String, double> _calculateStatistics(
    List<Map<String, dynamic>> surveys,
    SurveyService surveyService,
  ) {
    if (surveys.isEmpty) {
      return {
        'mean': 0,
        'median': 0,
        'mode': 0,
        'stdDev': 0,
        'min': 0,
        'max': 0,
      };
    }

    final scores = surveys
        .map((s) => surveyService.calculateSurveyScore(s).toDouble())
        .toList()
      ..sort();

    // Media
    final mean = scores.reduce((a, b) => a + b) / scores.length;

    // Mediana
    final median = scores.length.isOdd
        ? scores[scores.length ~/ 2]
        : (scores[scores.length ~/ 2 - 1] + scores[scores.length ~/ 2]) / 2;

    // Moda
    final frequency = <double, int>{};
    for (var score in scores) {
      frequency[score] = (frequency[score] ?? 0) + 1;
    }
    final mode = frequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Desviación estándar
    final variance = scores.map((s) => math.pow(s - mean, 2)).reduce((a, b) => a + b) / scores.length;
    final stdDev = math.sqrt(variance);

    return {
      'mean': mean,
      'median': median,
      'mode': mode,
      'stdDev': stdDev,
      'min': scores.first,
      'max': scores.last,
    };
  }

  // Exportar datos a CSV (compatible con SPSS)
  Future<void> _exportToSPSS(BuildContext context, List<Map<String, dynamic>> surveys, SurveyService surveyService) async {
    try {
      final surveyTypeName = _selectedSurveyType == 1 ? 'BDI-II' : 'BAI';

      // Crear encabezados
      List<List<dynamic>> rows = [
        ['ID_Encuesta', 'ID_Paciente', 'Fecha', 'Tipo_Encuesta', 'Puntaje_Total', 'Nivel_Severidad']
      ];

      // Agregar datos
      for (var survey in surveys) {
        final surveyId = survey['survey_id'];
        final patientId = survey['patient_id'] ?? 'N/A';
        final date = DateTime.parse(survey['created_at']).toString().split(' ')[0];
        final score = surveyService.calculateSurveyScore(survey);
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

      // Convert to CSV format manually with proper escaping
      String csvString = '';
      for (var row in rows) {
        csvString += '${row.map((cell) {
          final cellStr = cell.toString();
          // Escape quotes and wrap in quotes if contains comma, quote, or newline
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
        // Descarga en web usando printing (universally available)
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      } else {
        // En móvil/desktop: guardar en temp y compartir
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], text: 'Exportar datos CSV'),
        );
      }

      // Mostrar confirmación
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
    if (surveyType == 1) {
      // BDI-II
      if (score <= 13) return 'Mínima';
      if (score <= 19) return 'Leve';
      if (score <= 28) return 'Moderada';
      return 'Severa';
    } else {
      // BAI
      if (score <= 7) return 'Mínima';
      if (score <= 15) return 'Leve';
      if (score <= 25) return 'Moderada';
      return 'Severa';
    }
  }


  // Exportar TODOS los datos a CSV (BDI-II + BAI juntos)
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
        final score = surveyService.calculateSurveyScore(survey);
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

  // Generar PDF completo con BDI-II + BAI
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

      // ── Función local para construir cada sección ──────────────────────
      pw.Widget buildSection(
        String title,
        String fullName,
        List<Map<String, dynamic>> secSurveys,
        Map<String, double> stats,
        int surveyType,
      ) {
        final dist = <String, int>{'Mínima': 0, 'Leve': 0, 'Moderada': 0, 'Severa': 0};
        for (var s in secSurveys) {
          final score = surveyService.calculateSurveyScore(s);
          final level = _getLevelText(score, surveyType);
          if (dist.containsKey(level)) dist[level] = dist[level]! + 1;
        }
        final maxDist = dist.values.isEmpty ? 1 : dist.values.reduce((a, b) => a > b ? a : b);
        final total = dist.values.fold(0, (a, b) => a + b);

        final sortedS = List<Map<String, dynamic>>.from(secSurveys)
          ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
        final tScores = sortedS.map((s) => surveyService.calculateSurveyScore(s)).toList();
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
                        // Agujero central (donut)
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

  // Generar reporte PDF
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

      // Fuente Unicode
      final fontRegular = await PdfGoogleFonts.notoSansRegular();
      final fontBold = await PdfGoogleFonts.notoSansBold();

      pw.TextStyle pdfStyle({double fontSize = 10, bool bold = false, PdfColor? color}) =>
          pw.TextStyle(font: bold ? fontBold : fontRegular, fontSize: fontSize, color: color);

      // Calcular distribución por niveles
      final distribution = <String, int>{
        'Mínima': 0,
        'Leve': 0,
        'Moderada': 0,
        'Severa': 0,
      };

      for (var survey in surveys) {
        final score = surveyService.calculateSurveyScore(survey);
        final level = _getLevelText(score, _selectedSurveyType);
        if (distribution.containsKey(level)) {
          distribution[level] = distribution[level]! + 1;
        }
      }

      // Rangos ASCII (sin guiones especiales)
      final scoreRanges = _selectedSurveyType == 1
          ? {'Mínima': '0-13', 'Leve': '14-19', 'Moderada': '20-28', 'Severa': '29-63'}
          : {'Mínima': '0-7', 'Leve': '8-15', 'Moderada': '16-25', 'Severa': '26-63'};

      final pieColors = [PdfColors.green400, PdfColors.yellow600, PdfColors.orange400, PdfColors.red400];

      final total = distribution.values.fold(0, (a, b) => a + b);
      final maxDist = distribution.values.isEmpty
          ? 1
          : distribution.values.reduce((a, b) => a > b ? a : b);

      // Tendencia temporal
      final sortedSurveys = List<Map<String, dynamic>>.from(surveys)
        ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
      final timelineScores = sortedSurveys
          .map((s) => surveyService.calculateSurveyScore(s))
          .toList();
      final maxTS = timelineScores.isEmpty
          ? 5.0
          : timelineScores.reduce((a, b) => a > b ? a : b).toDouble();

      // Acceso seguro a stats
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

  /// Dibuja un sector circular (rebanada de pastel) usando curvas de Bézier cúbicas.
  /// [startAngle] y [sweepAngle] en radianes.
  static void _drawPdfSector(
    PdfGraphics canvas,
    double cx,
    double cy,
    double r,
    double startAngle,
    double sweepAngle,
  ) {
    // Dividimos el arco en segmentos de máx. 90° para buena aproximación
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

  /// Agrega un segmento de arco (≤90°) al path actual usando Bézier cúbica.
  static void _addArcSegment(
    PdfGraphics canvas,
    double cx,
    double cy,
    double r,
    double startAngle,
    double sweepAngle,
  ) {
    final endAngle = startAngle + sweepAngle;
    // Factor de control Bézier para aproximar arco circular
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

  /// Dibuja un círculo completo relleno (para el agujero central del donut).
  static void _drawPdfCircle(PdfGraphics canvas, double cx, double cy, double r) {
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
    if (surveyType == 1) {
      // BDI-II
      if (mean <= 13) {
        return 'La media de los puntajes indica un nivel MÍNIMO de depresión en la población evaluada. '
            'Los participantes presentan síntomas mínimos o ausentes de depresión. '
            'Se recomienda continuar con el monitoreo preventivo.';
      } else if (mean <= 19) {
        return 'La media de los puntajes indica un nivel LEVE de depresión en la población evaluada. '
            'Los participantes presentan síntomas leves que pueden requerir atención. '
            'Se recomienda seguimiento y posible intervención psicoterapéutica.';
      } else if (mean <= 28) {
        return 'La media de los puntajes indica un nivel MODERADO de depresión en la población evaluada. '
            'Los participantes presentan síntomas significativos que requieren atención profesional. '
            'Se recomienda evaluación clínica y tratamiento psicoterapéutico.';
      } else {
        return 'La media de los puntajes indica un nivel SEVERO de depresión en la población evaluada. '
            'Los participantes presentan síntomas graves que requieren atención inmediata. '
            'Se recomienda evaluación clínica urgente y tratamiento especializado.';
      }
    } else {
      // BAI
      if (mean <= 7) {
        return 'La media de los puntajes indica un nivel MÍNIMO de ansiedad en la población evaluada. '
            'Los participantes presentan síntomas mínimos o ausentes de ansiedad. '
            'Se recomienda continuar con el monitoreo preventivo.';
      } else if (mean <= 15) {
        return 'La media de los puntajes indica un nivel LEVE de ansiedad en la población evaluada. '
            'Los participantes presentan síntomas leves que pueden requerir atención. '
            'Se recomienda seguimiento y posible intervención.';
      } else if (mean <= 25) {
        return 'La media de los puntajes indica un nivel MODERADO de ansiedad en la población evaluada. '
            'Los participantes presentan síntomas significativos que requieren atención profesional. '
            'Se recomienda evaluación clínica y tratamiento.';
      } else {
        return 'La media de los puntajes indica un nivel SEVERO de ansiedad en la población evaluada. '
            'Los participantes presentan síntomas graves que requieren atención inmediata. '
            'Se recomienda evaluación clínica urgente y tratamiento especializado.';
      }
    }
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
      // BDI-II
      if (score <= 13) return 'minimal';
      if (score <= 19) return 'mild';
      if (score <= 28) return 'moderate';
      return 'severe';
    } else {
      // BAI
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
      final score = surveyService.calculateSurveyScore(survey);
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
      final score = surveyService.calculateSurveyScore(entry.value);
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

    // Calcular distribución por nivel de severidad
    final distribution = <String, int>{
      'Mínima': 0,
      'Leve': 0,
      'Moderada': 0,
      'Severa': 0,
    };
    final scoreRanges = <String, String>{};

    for (var survey in surveys) {
      final score = surveyService.calculateSurveyScore(survey);
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

    // Rangos de puntaje según tipo de encuesta
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

        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 50,
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Panel lateral con detalles
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                    ),
                  ),
                ],
              ),
            ),
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

