import 'dart:js_interop';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' as material;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:web/web.dart' as web;
import 'dart:convert';
import 'dart:typed_data';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedSurveyType = 1; // 1 = BDI-II, 2 = BAI

  @override
  Widget build(BuildContext context) {
    final surveyService = context.watch<SurveyService>();
    final allSurveys = surveyService.getCompletedSurveys();

    // Filtrar por tipo de encuesta
    final surveys = allSurveys.where((s) {
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de tipo de encuesta
                  SurfaceCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text('Tipo de Encuesta:').semiBold(),
                          const Gap(16),
                          Row(
                            children: [
                              _selectedSurveyType == 1
                                  ? PrimaryButton(
                                      onPressed: () {
                                        setState(() => _selectedSurveyType = 1);
                                      },
                                      child: const Text('BDI-II'),
                                    )
                                  : OutlineButton(
                                      onPressed: () {
                                        setState(() => _selectedSurveyType = 1);
                                      },
                                      child: const Text('BDI-II'),
                                    ),
                              const Gap(8),
                              _selectedSurveyType == 2
                                  ? PrimaryButton(
                                      onPressed: () {
                                        setState(() => _selectedSurveyType = 2);
                                      },
                                      child: const Text('BAI'),
                                    )
                                  : OutlineButton(
                                      onPressed: () {
                                        setState(() => _selectedSurveyType = 2);
                                      },
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlineButton(
                          onPressed: surveys.isEmpty ? null : () => _exportToSPSS(context, surveys, surveyService),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(material.Icons.table_chart, size: 20),
                              const Gap(8),
                              const Text('Descargar datos SPSS (.csv)'),
                            ],
                          ),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: surveys.isEmpty ? null : () => _generatePDFReport(context, surveys, surveyService, stats),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(material.Icons.picture_as_pdf, size: 20),
                              const Gap(8),
                              const Text('Generar Reporte PDF'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),

                  // Medidas de tendencia central
                  Text('Medidas de Tendencia Central',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Media',
                          value: stats['mean']!.toStringAsFixed(1),
                          icon: material.Icons.analytics,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: _StatCard(
                          title: 'Mediana',
                          value: stats['median']!.toStringAsFixed(1),
                          icon: material.Icons.show_chart,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: _StatCard(
                          title: 'Moda',
                          value: stats['mode']!.toStringAsFixed(0),
                          icon: material.Icons.timeline,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: _StatCard(
                          title: 'Desv. Estándar',
                          value: stats['stdDev']!.toStringAsFixed(2),
                          icon: material.Icons.scatter_plot,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),

                  // Rango y otros datos
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          title: 'Total de Encuestas',
                          value: surveys.length.toString(),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: _InfoCard(
                          title: 'Puntaje Mínimo',
                          value: stats['min']!.toInt().toString(),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: _InfoCard(
                          title: 'Puntaje Máximo',
                          value: stats['max']!.toInt().toString(),
                        ),
                      ),
                      const Gap(16),
                      Expanded(
                        child: _InfoCard(
                          title: 'Rango',
                          value: (stats['max']! - stats['min']!).toInt().toString(),
                        ),
                      ),
                    ],
                  ),
                  const Gap(32),

                  // Gráficas
                  Text('Distribución de Resultados',
                    style: TextStyle(
                      fontSize: 28,
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
                              surveyType: _selectedSurveyType,
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

                  // Gráfica de distribución de frecuencias
                  SurfaceCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Histograma de Puntajes').semiBold().large(),
                          const Gap(24),
                          SizedBox(
                            height: 300,
                            child: _HistogramChart(
                              surveys: surveys,
                              surveyService: surveyService,
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
  void _exportToSPSS(BuildContext context, List<Map<String, dynamic>> surveys, SurveyService surveyService) {
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

      // Convertir a CSV
      String csv = const ListToCsvConverter().convert(rows);

      // Descargar archivo con BOM para UTF-8 (para que Excel/SPSS reconozca los acentos)
      final bom = [0xEF, 0xBB, 0xBF]; // UTF-8 BOM
      final csvBytes = utf8.encode(csv);
      final bytes = Uint8List.fromList(bom + csvBytes);

      // Crear blob y descargar con package:web
      final blob = web.Blob([bytes.toJS].toJS);
      final url = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.download = 'datos_${surveyTypeName}_${DateTime.now().millisecondsSinceEpoch}.csv';
      anchor.click();
      web.URL.revokeObjectURL(url);

      // Mostrar confirmación
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Basic(
            title: const Text('Datos exportados'),
            subtitle: Text('Archivo CSV descargado exitosamente'),
            leading: Icon(material.Icons.check_circle, color: const Color(0xFF10B981)),
          ),
        ),
        location: ToastLocation.bottomCenter,
      );
    } catch (e) {
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Basic(
            title: const Text('Error al exportar'),
            subtitle: Text('No se pudo generar el archivo: $e'),
            leading: Icon(material.Icons.error, color: const Color(0xFFEF4444)),
          ),
        ),
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
        distribution[level] = distribution[level]! + 1;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Encabezado
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Reporte de Análisis Estadístico',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      surveyFullName,
                      style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generado el ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                    ),
                    pw.Divider(thickness: 2, color: PdfColors.blue800),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Resumen ejecutivo
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Resumen Ejecutivo',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem('Total de Encuestas', surveys.length.toString()),
                        _buildStatItem('Puntaje Mínimo', stats['min']!.toInt().toString()),
                        _buildStatItem('Puntaje Máximo', stats['max']!.toInt().toString()),
                        _buildStatItem('Rango', (stats['max']! - stats['min']!).toInt().toString()),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Medidas de tendencia central
              pw.Text(
                'Medidas de Tendencia Central',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableHeader('Medida'),
                      _buildTableHeader('Valor'),
                      _buildTableHeader('Interpretación'),
                    ],
                  ),
                  _buildTableRow('Media', stats['mean']!.toStringAsFixed(2),
                      'Promedio aritmético de los puntajes'),
                  _buildTableRow('Mediana', stats['median']!.toStringAsFixed(2),
                      'Valor central de la distribución'),
                  _buildTableRow('Moda', stats['mode']!.toStringAsFixed(0),
                      'Puntaje más frecuente'),
                  _buildTableRow('Desviación Estándar', stats['stdDev']!.toStringAsFixed(2),
                      'Medida de dispersión de los datos'),
                ],
              ),

              pw.SizedBox(height: 24),

              // Distribución por niveles
              pw.Text(
                'Distribución por Nivel de Severidad',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableHeader('Nivel'),
                      _buildTableHeader('Cantidad'),
                      _buildTableHeader('Porcentaje'),
                    ],
                  ),
                  ...distribution.entries.map((entry) {
                    final percentage = (entry.value / surveys.length * 100).toStringAsFixed(1);
                    return _buildTableRow(entry.key, entry.value.toString(), '$percentage%');
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 24),

              // Interpretación
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue300, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Interpretación de Resultados',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      _getInterpretation(stats['mean']!, _selectedSurveyType),
                      style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              // Pie de página con información adicional
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Nota Importante:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Este reporte es generado automáticamente con fines estadísticos. '
                      'Los resultados deben ser interpretados por un profesional de la salud mental calificado.',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Guardar y descargar PDF (compatible con web)
      final pdfBytes = await pdf.save();

      // Crear blob y descargar con package:web
      final blob = web.Blob([pdfBytes.toJS].toJS, web.BlobPropertyBag(type: 'application/pdf'));
      final url = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.download = 'reporte_${surveyTypeName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      anchor.click();
      web.URL.revokeObjectURL(url);

      // Mostrar confirmación
      if (context.mounted) {
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Reporte generado'),
              subtitle: const Text('PDF descargado exitosamente'),
              leading: Icon(material.Icons.check_circle, color: const Color(0xFF10B981)),
            ),
          ),
          location: ToastLocation.bottomCenter,
        );
      }
    } catch (e) {
      if (context.mounted) {
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Error al generar PDF'),
              subtitle: Text('No se pudo crear el reporte: $e'),
              leading: Icon(material.Icons.error, color: const Color(0xFFEF4444)),
            ),
          ),
          location: ToastLocation.bottomCenter,
        );
      }
    }
  }

  pw.Widget _buildStatItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
        ),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
      ),
    );
  }

  pw.TableRow _buildTableRow(String col1, String col2, String col3) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(col1, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(col2, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(col3, style: const pw.TextStyle(fontSize: 10)),
        ),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
              ],
            ),
            const Gap(16),
            Text(value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.foreground,
              ),
            ),
            const Gap(4),
            Text(title).muted(),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.foreground,
            ),
          ),
          const Gap(4),
          Text(title).muted().small(),
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

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (distribution.values.isEmpty ? 10 : distribution.values.reduce(math.max)).toDouble() + 2,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
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
      ),
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

class _HistogramChart extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  final SurveyService surveyService;

  const _HistogramChart({
    required this.surveys,
    required this.surveyService,
  });

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) {
      return const Center(child: Text('No hay datos para mostrar'));
    }

    // Crear bins (intervalos) para el histograma
    final scores = surveys.map((s) => surveyService.calculateSurveyScore(s)).toList();
    final minScore = scores.reduce(math.min);
    final maxScore = scores.reduce(math.max);
    final binSize = math.max(1, ((maxScore - minScore) / 10).ceil());

    final bins = <int, int>{};
    for (var score in scores) {
      final binIndex = (score / binSize).floor();
      bins[binIndex] = (bins[binIndex] ?? 0) + 1;
    }

    final barGroups = bins.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: const Color(0xFF8B5CF6),
            width: 30,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (bins.values.isEmpty ? 10 : bins.values.reduce(math.max)).toDouble() + 1,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
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
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final rangeStart = (value * binSize).toInt();
                final rangeEnd = ((value + 1) * binSize - 1).toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '$rangeStart-$rangeEnd',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.mutedForeground,
                      fontSize: 10,
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
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).colorScheme.border,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

