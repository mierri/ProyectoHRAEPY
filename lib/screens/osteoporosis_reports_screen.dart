import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/Services/osteoporosis_report_service.dart';
import 'package:ssapp/models/osteoporosis_report_model.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:material_symbols_icons/symbols.dart';

class OsteoporosisReportsScreen extends StatefulWidget {
  const OsteoporosisReportsScreen({super.key});

  @override
  State<OsteoporosisReportsScreen> createState() => _OsteoporosisReportsScreenState();
}

class _OsteoporosisReportsScreenState extends State<OsteoporosisReportsScreen> {
  OsteoporosisCompleteReport? _report;
  bool _isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    try {
      final surveyService = context.read<SurveyService>();
      final allSurveys = surveyService.getCompletedSurveys();

      final osteoSurveys = allSurveys.where((s) {
        final surveyType = s['survey_type'] as int? ?? 1;
        return surveyType == 9;
      }).toList();

      final report = OsteoporosisReportService.generateCompleteReport(osteoSurveys);

      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Reportes - Osteoporosis'),
          leading: [
            IconButton(
              icon: const Icon(Symbols.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
              variance: ButtonVariance.ghost,
            ),
          ],
              trailing: _report != null
              ? [
                  IconButton(
                    icon: const Icon(Symbols.download),
                    onPressed: _showExportOptions,
                    variance: ButtonVariance.ghost,
                  ),
                ]
              : [],
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _report == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Symbols.bar_chart, size: 80),
                      const Gap(16),
                      const Text('No hay encuestas de osteoporosis'),
                      const Gap(8),
                      const Text('Completa algunas encuestas para ver reportes').muted().small(),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Tabs(
                        index: _selectedTab,
                        onChanged: (int value) {
                          setState(() => _selectedTab = value);
                        },
                        children: const [
                          TabItem(child: Text('Resumen')),
                          TabItem(child: Text('Edad')),
                          TabItem(child: Text('IMC')),
                          TabItem(child: Text('Sexo')),
                          TabItem(child: Text('Factores')),
                          TabItem(child: Text('NA')),
                          TabItem(child: Text('Distribución')),
                          TabItem(child: Text('Evolución')),
                        ],
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedTab,
                        children: [
                          _buildOverviewTab(),
                          _buildAgeGroupTab(),
                          _buildBMICategoryTab(),
                          _buildSexTab(),
                          _buildRiskFactorsTab(),
                          _buildNATab(),
                          _buildScoreDistributionTab(),
                          _buildTimeEvolutionTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildOverviewTab() {
    final overview = _report!.overview;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _MetricCard(
                label: 'Total Pacientes',
                value: overview.totalPatients.toString(),
                icon: Symbols.people,
              ),
              _MetricCard(
                label: 'Riesgo Bajo',
                value: '${overview.lowRiskPercentage.toStringAsFixed(1)}%',
                icon: Symbols.thumb_up,
                color: const Color(0xFF16A34A),
              ),
              _MetricCard(
                label: 'Riesgo Alto',
                value: '${overview.highRiskPercentage.toStringAsFixed(1)}%',
                icon: Symbols.warning,
                color: const Color(0xFFDC2626),
              ),
              _MetricCard(
                label: 'No Aplica',
                value: '${overview.naPercentage.toStringAsFixed(1)}%',
                icon: Symbols.help,
                color: const Color(0xFF0EA5E9),
              ),
              _MetricCard(
                label: 'IMC Promedio',
                value: overview.averageBMI.toStringAsFixed(2),
                icon: Symbols.scale,
              ),
              _MetricCard(
                label: 'Puntuación Promedio',
                value: overview.averageScore.toStringAsFixed(2),
                icon: Symbols.assessment,
              ),
            ],
          ),
          const Gap(24),
          const Text('Distribución de Riesgo'),
          const Gap(12),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: overview.lowRiskCount.toDouble(),
                    title: 'Bajo\n${overview.lowRiskCount}',
                    color: const Color(0xFF16A34A),
                    radius: 100,
                  ),
                  PieChartSectionData(
                    value: overview.highRiskCount.toDouble(),
                    title: 'Alto\n${overview.highRiskCount}',
                    color: const Color(0xFFDC2626),
                    radius: 100,
                  ),
                  if (overview.naCount > 0)
                    PieChartSectionData(
                      value: overview.naCount.toDouble(),
                      title: 'NA\n${overview.naCount}',
                      color: const Color(0xFF0EA5E9),
                      radius: 100,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeGroupTab() {
    final ageGroupData = _report!.ageGroupData;
    if (ageGroupData.isEmpty) return const Center(child: Text('Sin datos'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Riesgo por Grupo de Edad'),
          const Gap(16),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(
                  ageGroupData.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: ageGroupData[index].highRiskPercentage,
                        color: const Color(0xFFDC2626),
                        width: 12,
                      ),
                    ],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        return index >= 0 && index < ageGroupData.length
                            ? Text(ageGroupData[index].ageGroup)
                            : const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text('${value.toInt()}%'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMICategoryTab() {
    final bmiData = _report!.bmiCategoryData;
    if (bmiData.isEmpty) return const Center(child: Text('Sin datos'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Riesgo por Categoría IMC'),
          const Gap(16),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(
                  bmiData.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: bmiData[index].lowRiskPercentage,
                        color: const Color(0xFF16A34A),
                        width: 8,
                      ),
                      BarChartRodData(
                        toY: bmiData[index].highRiskPercentage,
                        color: const Color(0xFFDC2626),
                        width: 8,
                      ),
                      BarChartRodData(
                        toY: bmiData[index].naPercentage,
                        color: const Color(0xFF0EA5E9),
                        width: 8,
                      ),
                    ],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        return index >= 0 && index < bmiData.length ? Text(bmiData[index].bmiCategory) : const Text('');
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSexTab() {
    final sexData = _report!.sexData;
    if (sexData.isEmpty) return const Center(child: Text('Sin datos'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Riesgo por Sexo'),
          const Gap(16),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(
                  sexData.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: sexData[index].highRiskPercentage,
                        color: const Color(0xFFDC2626),
                        width: 20,
                      ),
                    ],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        return index >= 0 && index < sexData.length ? Text(sexData[index].sex) : const Text('');
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFactorsTab() {
    final factors = _report!.riskFactors;
    if (factors.isEmpty) return const Center(child: Text('Sin datos'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Análisis de Factores de Riesgo'),
          const Gap(16),
          SizedBox(
            height: factors.length * 60.0,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(
                  factors.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: factors[index].yesPercentage,
                        color: const Color(0xFFDC2626),
                        width: 12,
                      ),
                    ],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        return index >= 0 && index < factors.length ? Text('P${factors[index].questionNumber}') : const Text('');
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Gap(24),
          ...factors.map((factor) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('P${factor.questionNumber}: ${factor.yesPercentage.toStringAsFixed(1)}% (${factor.yesCount}/${factor.totalCount})'),
          )),
        ],
      ),
    );
  }

  Widget _buildNATab() {
    final naBreakdown = _report!.naBreakdown;
    if (naBreakdown.isEmpty) return const Center(child: Text('Sin casos NA'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Casos No Aplicable (NA)'),
          const Gap(16),
          Text(
            'Total: ${naBreakdown.fold<int>(0, (sum, item) => sum + item.count)} casos',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Gap(16),
          ...naBreakdown.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${item.ageGroup} - IMC ${item.bmiCategory} - ${item.sex}: ${item.count}',
              style: const TextStyle(fontSize: 14),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildScoreDistributionTab() {
    final distribution = _report!.scoreDistribution;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Distribución de Puntuaciones'),
          const Gap(16),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(
                  7,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: distribution[index].count.toDouble(),
                        color: const Color(0xFF145374),
                        width: 12,
                      ),
                    ],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeEvolutionTab() {
    final timeData = _report!.timeEvolution;
    if (timeData.isEmpty || timeData.length < 2) return const Center(child: Text('Sin datos de evolución'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Evolución en el Tiempo'),
          const Gap(16),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: timeData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.highRiskCount.toDouble())).toList(),
                    isCurved: true,
                    color: const Color(0xFFDC2626),
                    dotData: const FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: timeData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.lowRiskCount.toDouble())).toList(),
                    isCurved: true,
                    color: const Color(0xFF16A34A),
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Reporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Button.ghost(
              onPressed: () {
                Navigator.pop(context);
                _exportPDF();
              },
              child: const Row(
                children: [
                  Icon(Symbols.picture_as_pdf),
                  Gap(8),
                  Text('Exportar como PDF'),
                ],
              ),
            ),
            const Gap(8),
            Button.ghost(
              onPressed: () {
                Navigator.pop(context);
                _exportCSV();
              },
              child: const Row(
                children: [
                  Icon(Symbols.table),
                  Gap(8),
                  Text('Exportar como CSV'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Button(
            onPressed: () => Navigator.pop(context),
            style: ButtonVariance.destructive,
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPDF() async {
    try {
      final pdf = pw.Document();
      final report = _report!;

      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Reporte de Osteoporosis', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                pw.Text('Generado: ${report.generatedAt.toString()}'),
                pw.SizedBox(height: 24),
                pw.Text('Resumen General', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Total de Pacientes: ${report.overview.totalPatients}'),
                    pw.Text('Riesgo Bajo: ${report.overview.lowRiskPercentage.toStringAsFixed(1)}%'),
                    pw.Text('Riesgo Alto: ${report.overview.highRiskPercentage.toStringAsFixed(1)}%'),
                    pw.Text('No Aplica: ${report.overview.naPercentage.toStringAsFixed(1)}%'),
                    pw.Text('IMC Promedio: ${report.overview.averageBMI.toStringAsFixed(2)}'),
                    pw.Text('Puntuación Promedio: ${report.overview.averageScore.toStringAsFixed(2)}'),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/Reporte_Osteoporosis.pdf');
      await file.writeAsBytes(bytes);

      if (mounted) {
        await Printing.layoutPdf(onLayout: (_) => bytes);
      }
    } catch (e) {
      //
    }
  }

  Future<void> _exportCSV() async {
    try {
      final report = _report!;
      final buffer = StringBuffer();

      buffer.writeln('Reporte de Osteoporosis - ${report.generatedAt}');
      buffer.writeln('');
      buffer.writeln('RESUMEN GENERAL');
      buffer.writeln('Total Pacientes,Riesgo Bajo %,Riesgo Alto %,No Aplica %,IMC Promedio,Puntuación Promedio');
      buffer.writeln('${report.overview.totalPatients},${report.overview.lowRiskPercentage.toStringAsFixed(1)},${report.overview.highRiskPercentage.toStringAsFixed(1)},${report.overview.naPercentage.toStringAsFixed(1)},${report.overview.averageBMI.toStringAsFixed(2)},${report.overview.averageScore.toStringAsFixed(2)}');
      buffer.writeln('');
      buffer.writeln('RIESGO POR GRUPO DE EDAD');
      buffer.writeln('Grupo Edad,Total,Riesgo Alto %,Puntuación Promedio');
      for (final data in report.ageGroupData) {
        buffer.writeln('${data.ageGroup},${data.totalCount},${data.highRiskPercentage.toStringAsFixed(1)},${data.averageScore.toStringAsFixed(2)}');
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/Reporte_Osteoporosis.csv');
      await file.writeAsString(buffer.toString());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Reporte de Osteoporosis',
        ),
      );
    } catch (e) {
      //
    }
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color ?? Theme.of(context).colorScheme.primary),
            const Gap(8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const Gap(4),
            Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}





