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
          SurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1. DISTRIBUCIÓN DE RIESGO (LA MÁS IMPORTANTE)').semiBold().large(),
                  Text('Porcentaje de pacientes por nivel de riesgo',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.mutedForeground)).small(),
                  const Gap(16),
                  SizedBox(
                    height: 320,
                    child: _buildRiskDistributionChart(overview),
                  ),
                  const Gap(16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF16A34A), shape: BoxShape.circle)),
                                const Gap(8),
                                Text('Bajo Riesgo', style: TextStyle(color: Theme.of(context).colorScheme.foreground)),
                              ],
                            ),
                            const Gap(4),
                            Text('${overview.lowRiskCount} pacientes (${overview.lowRiskPercentage.toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 12)).muted(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFFDC2626), shape: BoxShape.circle)),
                                const Gap(8),
                                Text('Alto Riesgo', style: TextStyle(color: Theme.of(context).colorScheme.foreground)),
                              ],
                            ),
                            const Gap(4),
                            Text('${overview.highRiskCount} pacientes (${overview.highRiskPercentage.toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 12)).muted(),
                          ],
                        ),
                      ),
                      if (overview.naCount > 0)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF0EA5E9), shape: BoxShape.circle)),
                                  const Gap(8),
                                  Text('NA', style: TextStyle(color: Theme.of(context).colorScheme.foreground)),
                                ],
                              ),
                              const Gap(4),
                              Text('${overview.naCount} pacientes (${overview.naPercentage.toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 12)).muted(),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskDistributionChart(OsteoporosisReportMetrics overview) {
    final total = overview.lowRiskCount + overview.highRiskCount + overview.naCount;
    if (total == 0) {
      return Center(
        child: Text('Sin datos', style: TextStyle(color: Theme.of(context).colorScheme.mutedForeground)),
      );
    }

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: overview.lowRiskCount.toDouble(),
            title: '${overview.lowRiskPercentage.toStringAsFixed(1)}%',
            color: const Color(0xFF16A34A),
            radius: 120,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          PieChartSectionData(
            value: overview.highRiskCount.toDouble(),
            title: '${overview.highRiskPercentage.toStringAsFixed(1)}%',
            color: const Color(0xFFDC2626),
            radius: 120,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (overview.naCount > 0)
            PieChartSectionData(
              value: overview.naCount.toDouble(),
              title: '${overview.naPercentage.toStringAsFixed(1)}%',
              color: const Color(0xFF0EA5E9),
              radius: 120,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
        ],
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildAgeGroupTab() {
    final ageGroupData = _report!.ageGroupData;
    if (ageGroupData.isEmpty) {
      return Center(
        child: Text('Sin datos', style: TextStyle(color: Theme.of(context).colorScheme.mutedForeground)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('2. RIESGO POR GRUPO DE EDAD').semiBold().large(),
                  Text('Porcentaje de pacientes con alto riesgo por rango de edad',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.mutedForeground)).small(),
                  const Gap(24),
                  SizedBox(
                    height: 350,
                    child: _buildAgeGroupBarChart(ageGroupData),
                  ),
                  const Gap(24),
                  _buildAgeGroupSummary(ageGroupData),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeGroupBarChart(List<AgeGroupRiskData> data) {
    // Filtrar solo grupos con datos
    final dataWithCases = data.where((item) => item.totalCount > 0).toList();
    
    if (dataWithCases.isEmpty) {
      return Center(
        child: Text('Sin datos para mostrar', style: TextStyle(color: Theme.of(context).colorScheme.mutedForeground)),
      );
    }

    // Encontrar el máximo para escala Y
    double maxY = 1;
    for (final item in dataWithCases) {
      final total = (item.lowRiskCount + item.highRiskCount).toDouble();
      if (total > maxY) {
        maxY = total;
      }
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              BarChart(
                BarChartData(
                  barGroups: List.generate(
                    dataWithCases.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: dataWithCases[index].lowRiskCount.toDouble(),
                          color: const Color(0xFF16A34A),
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        BarChartRodData(
                          toY: dataWithCases[index].highRiskCount.toDouble(),
                          color: const Color(0xFFDC2626),
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                      barsSpace: 4,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500));
                        },
                        reservedSize: 35,
                        interval: (maxY / 4).ceilToDouble().toDouble(),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < dataWithCases.length) {
                            final ageGroup = dataWithCases[index].ageGroup;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(ageGroup, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY / 4).ceilToDouble(),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: const Color(0xFFF3F4F6),
                      strokeWidth: 1,
                    ),
                  ),
                  maxY: maxY,
                ),
              ),
              // Etiquetas de conteo sobre cada barra
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth = 8.0;
                    final groupSpace = 4.0;
                    final chartHeight = constraints.maxHeight;
                    final chartWidth = constraints.maxWidth;
                    return Stack(
                      children: List.generate(dataWithCases.length, (i) {
                        final group = dataWithCases[i];
                        final totalGroups = dataWithCases.length;
                        final groupX = (chartWidth / totalGroups) * i + barWidth;
                        final lowY = group.lowRiskCount > 0 ? chartHeight * (1 - group.lowRiskCount / maxY) : chartHeight;
                        final highY = group.highRiskCount > 0 ? chartHeight * (1 - group.highRiskCount / maxY) : chartHeight;
                        return Stack(
                          children: [
                            if (group.lowRiskCount > 0)
                              Positioned(
                                left: groupX - barWidth,
                                top: lowY - 18,
                                child: Text('${group.lowRiskCount}', style: const TextStyle(fontSize: 10, color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
                              ),
                            if (group.highRiskCount > 0)
                              Positioned(
                                left: groupX + barWidth + groupSpace,
                                top: highY - 18,
                                child: Text('${group.highRiskCount}', style: const TextStyle(fontSize: 10, color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                              ),
                          ],
                        );
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Leyenda',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(2)),
                      ),
                      const Gap(6),
                      const Text('Bajo Riesgo', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(2)),
                      ),
                      const Gap(6),
                      const Text('Alto Riesgo', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              const Gap(6),
              const Text(
                'Eje Y: Número de casos por categoría',
                style: TextStyle(fontSize: 8, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgeGroupSummary(List<AgeGroupRiskData> data) {
    final maxRisk = data.reduce((a, b) => a.highRiskPercentage > b.highRiskPercentage ? a : b);
    final minRisk = data.reduce((a, b) => a.highRiskPercentage < b.highRiskPercentage ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detalle por Grupo de Edad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.foreground)),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626).withAlpha((0.1 * 255).toInt()),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDC2626).withAlpha((0.3 * 255).toInt())),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mayor riesgo alto:', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.mutedForeground)),
                  Text('${maxRisk.ageGroup}: ${maxRisk.highRiskPercentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Menor riesgo alto:', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.mutedForeground)),
                  Text('${minRisk.ageGroup}: ${minRisk.highRiskPercentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        const Gap(12),
        Text('Riesgo Bajo vs Alto por Grupo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.foreground)),
        const Gap(8),
        ...data.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.ageGroup} años (n=${item.totalCount})',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  if (item.totalCount == 0)
                    Text(
                      'Sin datos',
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.mutedForeground),
                    ),
                ],
              ),
              if (item.totalCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: item.lowRiskCount,
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A),
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(3), bottomLeft: Radius.circular(3)),
                          ),
                          alignment: Alignment.center,
                          child: item.lowRiskCount > 0
                              ? Text(
                                  '${item.lowRiskCount}',
                                  style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                      Expanded(
                        flex: item.highRiskCount,
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: const BorderRadius.only(topRight: Radius.circular(3), bottomRight: Radius.circular(3)),
                          ),
                          alignment: Alignment.center,
                          child: item.highRiskCount > 0
                              ? Text(
                                  '${item.highRiskCount}',
                                  style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        )),
        const Gap(12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(2)),
                  ),
                  const Gap(6),
                  const Text('Riesgo Bajo', style: TextStyle(fontSize: 10)),
                ],
              ),
              const Gap(16),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(2)),
                  ),
                  const Gap(6),
                  const Text('Riesgo Alto', style: TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBMICategoryTab() {
    final bmiData = _report!.bmiCategoryData;
    if (bmiData.isEmpty) {
      return Center(
        child: Text('Sin datos', style: TextStyle(color: Theme.of(context).colorScheme.mutedForeground)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('3. RIESGO POR IMC (Índice de Masa Corporal)').semiBold().large(),
                  Text('Distribución de riesgo por cada rango de IMC',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.mutedForeground)).small(),
                  const Gap(24),
                  SizedBox(
                    height: 350,
                    child: _buildBMIStackedBarChart(bmiData),
                  ),
                  const Gap(24),
                  _buildBMILegend(),
                  const Gap(24),
                  _buildBMISummary(bmiData),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIStackedBarChart(List<BMICategoryRiskData> data) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              BarChart(
                BarChartData(
                  barGroups: List.generate(
                    data.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: 100,
                          rodStackItems: [
                            BarChartRodStackItem(0, data[index].lowRiskPercentage, const Color(0xFF16A34A)),
                            BarChartRodStackItem(data[index].lowRiskPercentage,
                                data[index].lowRiskPercentage + data[index].highRiskPercentage, const Color(0xFFDC2626)),
                            BarChartRodStackItem(
                                data[index].lowRiskPercentage + data[index].highRiskPercentage,
                                100,
                                const Color(0xFF0EA5E9)),
                          ],
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 9)),
                        reservedSize: 35,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                       sideTitles: SideTitles(
                         showTitles: true,
                         getTitlesWidget: (value, meta) {
                           final index = value.toInt();
                           return index >= 0 && index < data.length
                               ? Padding(
                                   padding: const EdgeInsets.only(top: 6),
                                   child: Text(data[index].bmiCategory, style: const TextStyle(fontSize: 9)),
                                 )
                               : const Text('');
                         },
                         reservedSize: 35,
                       ),
                     ),
                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                   ),
                   borderData: FlBorderData(show: false),
                   gridData: FlGridData(
                     show: true,
                     drawVerticalLine: false,
                     horizontalInterval: 20,
                     getDrawingHorizontalLine: (value) => FlLine(
                       color: const Color(0xFFF3F4F6),
                       strokeWidth: 1,
                     ),
                   ),
                   maxY: 100,
                 ),
               ),
               // Etiquetas de conteo sobre cada barra apilada
               Positioned.fill(
                 child: LayoutBuilder(
                   builder: (context, constraints) {
                     final chartHeight = constraints.maxHeight;
                     final chartWidth = constraints.maxWidth;
                     final barWidth = 16.0;
                     return Stack(
                       children: List.generate(data.length, (i) {
                         final item = data[i];
                         final totalGroups = data.length;
                         final groupX = (chartWidth / totalGroups) * i + barWidth / 2;
                         // Calcular la posición Y para cada segmento
                         final lowY = chartHeight * (1 - item.lowRiskPercentage / 100);
                         final highY = chartHeight * (1 - (item.lowRiskPercentage + item.highRiskPercentage) / 100);
                         final naY = chartHeight * (1 - (item.lowRiskPercentage + item.highRiskPercentage + item.naPercentage) / 100);
                         return Stack(
                           children: [
                             if (item.lowRiskCount > 0)
                               Positioned(
                                 left: groupX - barWidth / 2,
                                 top: lowY - 18,
                                 child: Text('${item.lowRiskCount}', style: const TextStyle(fontSize: 10, color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
                               ),
                             if (item.highRiskCount > 0)
                               Positioned(
                                 left: groupX - barWidth / 2,
                                 top: highY - 18,
                                 child: Text('${item.highRiskCount}', style: const TextStyle(fontSize: 10, color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                               ),
                             if (item.naCount > 0)
                               Positioned(
                                 left: groupX - barWidth / 2,
                                 top: naY - 18,
                                 child: Text('${item.naCount}', style: const TextStyle(fontSize: 10, color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold)),
                               ),
                           ],
                         );
                       }),
                     );
                   },
                 ),
               ),
             ],
           ),
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              Text('15-19', style: const TextStyle(fontSize: 8, color: Color(0xFF6B7280))),
              Text('20-24', style: const TextStyle(fontSize: 8, color: Color(0xFF6B7280))),
              Text('25-29', style: const TextStyle(fontSize: 8, color: Color(0xFF6B7280))),
              Text('30-34', style: const TextStyle(fontSize: 8, color: Color(0xFF6B7280))),
              Text('35-39', style: const TextStyle(fontSize: 8, color: Color(0xFF6B7280))),
              Text('40-44', style: const TextStyle(fontSize: 8, color: Color(0xFF6B7280))),
              Text('45+', style: const TextStyle(fontSize: 8, color: Color(0xFF6B7280))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBMILegend() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(width: 16, height: 16, decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(2))),
              const Gap(8),
              const Text('Bajo Riesgo', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Container(width: 16, height: 16, decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(2))),
              const Gap(8),
              const Text('Alto Riesgo', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Container(width: 16, height: 16, decoration: BoxDecoration(color: const Color(0xFF0EA5E9), borderRadius: BorderRadius.circular(2))),
              const Gap(8),
              const Text('NA', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBMISummary(List<BMICategoryRiskData> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detalle por Rango de IMC', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.foreground)),
        const Gap(12),
        ...data.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('IMC ${item.bmiCategory}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const Gap(4),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 20,
                        child: Stack(
                          children: [
                            Container(color: const Color(0xFFF3F4F6)),
                            Row(
                              children: [
                                if (item.lowRiskPercentage > 0)
                                  Container(
                                    width: (item.lowRiskPercentage / 100) * 200,
                                    color: const Color(0xFF16A34A),
                                  ),
                                if (item.highRiskPercentage > 0)
                                  Container(
                                    width: (item.highRiskPercentage / 100) * 200,
                                    color: const Color(0xFFDC2626),
                                  ),
                                if (item.naPercentage > 0)
                                  Container(
                                    width: (item.naPercentage / 100) * 200,
                                    color: const Color(0xFF0EA5E9),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  Text('${item.totalCount}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              const Gap(4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('BR: ${item.lowRiskPercentage.toStringAsFixed(1)}%', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.mutedForeground)),
                  Text('AR: ${item.highRiskPercentage.toStringAsFixed(1)}%', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.mutedForeground)),
                  Text('NA: ${item.naPercentage.toStringAsFixed(1)}%', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.mutedForeground)),
                ],
              ),
            ],
          ),
        )),
      ],
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

  /// Get abbreviation for a risk factor question number
  String _getRiskFactorAbbreviation(int questionNumber) {
    const abbreviations = {
      1: 'FR',  // Fractura anterior
      2: 'HF',  // Historial familiar
      3: 'FA',  // Fumador actual
      4: 'UG',  // Uso de glucocorticoides
      5: 'AR',  // Artritis reumatoide
      6: 'OS',  // Osteoporosis secundaria
      7: 'EA',  // Exceso alcohol
    };
    return abbreviations[questionNumber] ?? 'Q$questionNumber';
  }

  /// Get full text for risk factor abbreviation
  String _getRiskFactorFullText(int questionNumber) {
    const descriptions = {
      1: 'Fractura anterior',
      2: 'Historial familiar de fractura',
      3: 'Fumador actual',
      4: 'Uso de glucocorticoides',
      5: 'Artritis reumatoide',
      6: 'Osteoporosis secundaria',
      7: 'Consumo excesivo de alcohol',
    };
    return descriptions[questionNumber] ?? 'Pregunta $questionNumber';
  }

  Widget _buildRiskFactorsTab() {
    final factors = _report!.riskFactors;
    if (factors.isEmpty) {
      return Center(
        child: Text('Sin datos', style: TextStyle(color: Theme.of(context).colorScheme.mutedForeground)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('4. FACTORES DE RIESGO (ANÁLISIS DE RESPUESTAS)').semiBold().large(),
                  Text('Porcentaje de respuestas "Sí" para cada factor de riesgo',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.mutedForeground)).small(),
                  const Gap(24),
                  SizedBox(
                    height: factors.length * 70.0,
                    child: _buildRiskFactorsHorizontalChart(factors),
                  ),
                  const Gap(24),
                  _buildRiskFactorsLegend(factors),
                  const Gap(16),
                  _buildRiskFactorsDetail(factors),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFactorsLegend(List<RiskFactorData> factors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Leyenda de Abreviaturas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.foreground)),
        const Gap(8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: List.generate(factors.length, (index) {
            final factor = factors[index];
            final abbrev = _getRiskFactorAbbreviation(factor.questionNumber);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    abbrev,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const Text(': ', style: TextStyle(fontSize: 11)),
                  Flexible(
                    child: Text(
                      _getRiskFactorFullText(factor.questionNumber),
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRiskFactorsHorizontalChart(List<RiskFactorData> factors) {
    return BarChart(
      BarChartData(
        barGroups: List.generate(
          factors.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: factors[index].yesPercentage,
                color: const Color(0xFFDC2626),
                width: 18,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 100,
                  color: const Color(0xFFF3F4F6),
                ),
              ),
            ],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                return index >= 0 && index < factors.length
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 30,
                          child: Text(
                            _getRiskFactorAbbreviation(factors[index].questionNumber),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    : const Text('');
              },
              reservedSize: 50,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 10)),
              reservedSize: 30,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: false,
          verticalInterval: 20,
          getDrawingVerticalLine: (value) => FlLine(
            color: const Color(0xFFF3F4F6),
            strokeWidth: 1,
          ),
        ),
        maxY: 100,
      ),
    );
  }

  Widget _buildRiskFactorsDetail(List<RiskFactorData> factors) {
    final sortedFactors = [...factors]..sort((a, b) => b.yesPercentage.compareTo(a.yesPercentage));
    final topFactor = sortedFactors.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626).withAlpha((0.1 * 255).toInt()),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDC2626).withAlpha((0.3 * 255).toInt())),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Factor de Riesgo Más Frecuente', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.mutedForeground)),
              const Gap(4),
              Text('${topFactor.questionText}: ${topFactor.yesPercentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const Gap(4),
              Text('${topFactor.yesCount} de ${topFactor.totalCount} pacientes', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.mutedForeground)),
            ],
          ),
        ),
        const Gap(16),
        Text('Detalle de Factores', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.foreground)),
        const Gap(8),
        ...sortedFactors.map((factor) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  factor.questionText,
                  style: const TextStyle(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(8),
              Text(
                '${factor.yesPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const Gap(4),
              Text(
                '(${factor.yesCount}/${factor.totalCount})',
                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.mutedForeground),
              ),
            ],
          ),
        )),
      ],
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
          SurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('5. DISTRIBUCIÓN DE PUNTUACIONES (Score)').semiBold().large(),
                  Text('Frecuencia de puntajes obtenidos (rango 0-6)',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.mutedForeground)).small(),
                  const Gap(24),
                  SizedBox(
                    height: 320,
                    child: _buildScoreDistributionChart(distribution),
                  ),
                  const Gap(24),
                  _buildScoreDistributionSummary(distribution),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDistributionChart(List<ScoreDistributionData> distribution) {
    // Calcular estadísticas
    double maxCount = distribution.isNotEmpty ? distribution.map((d) => d.count).reduce((a, b) => a > b ? a : b).toDouble() : 1;

    return BarChart(
      BarChartData(
        barGroups: List.generate(
          distribution.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: distribution[index].count.toDouble(),
                color: _getScoreColor(index),
                width: 14,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxCount * 1.1,
                  color: const Color(0xFFF3F4F6),
                ),
              ),
            ],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                return index >= 0 && index < distribution.length
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('${distribution[index].score}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      )
                    : const Text('');
              },
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFFF3F4F6),
            strokeWidth: 1,
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    // Gradiente de colores según el score
    const colors = [
      Color(0xFF16A34A), // 0 - Verde
      Color(0xFF22D3EE), // 1 - Cyan
      Color(0xFF60A5FA), // 2 - Azul
      Color(0xFFFCA5A5), // 3 - Rojo claro
      Color(0xFFFD8C73), // 4 - Naranja
      Color(0xFFF87171), // 5 - Rojo
      Color(0xFFDC2626), // 6 - Rojo oscuro
    ];
    return colors[score.clamp(0, colors.length - 1)];
  }

  Widget _buildScoreDistributionSummary(List<ScoreDistributionData> distribution) {
    double totalCount = distribution.fold(0, (sum, item) => sum + item.count);
    int maxScore = distribution.isEmpty ? 0 : distribution.reduce((a, b) => a.count > b.count ? a : b).score;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withAlpha((0.1 * 255).toInt()),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF3B82F6).withAlpha((0.3 * 255).toInt())),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resumen de Puntuaciones', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.mutedForeground)),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Puntaje Más Común', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.mutedForeground)),
                      Text('$maxScore', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Total Encuestas', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.mutedForeground)),
                      Text(totalCount.toInt().toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Rango', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.mutedForeground)),
                      Text('0-6', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const Gap(16),
        Text('Distribución Detallada', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.foreground)),
        const Gap(8),
        ...distribution.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(color: _getScoreColor(item.score), borderRadius: BorderRadius.circular(4)),
                    child: Center(
                      child: Text(item.score.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 20,
                        child: Stack(
                          children: [
                            Container(color: const Color(0xFFF3F4F6)),
                            Container(
                              width: (item.percentage / 100) * 300,
                              color: _getScoreColor(item.score),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap(8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${item.percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      Text('${item.count} pacientes', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.mutedForeground)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildTimeEvolutionTab() {
    final timeData = _report!.timeEvolution;
    if (timeData.isEmpty || timeData.length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.info, size: 48, color: Theme.of(context).colorScheme.mutedForeground),
            const Gap(16),
            Text('Sin datos de evolución temporal',
                style: TextStyle(color: Theme.of(context).colorScheme.mutedForeground)),
            const Gap(8),
            const Text('Se requieren al menos 2 registros en diferentes meses').muted().small(),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('6. TENDENCIA TEMPORAL DE PUNTAJES').semiBold().large(),
                  Text('Evolución mensual del riesgo a lo largo del tiempo',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.mutedForeground)).small(),
                  const Gap(24),
                  SizedBox(
                    height: 340,
                    child: _buildTimeEvolutionChart(timeData),
                  ),
                  const Gap(24),
                  _buildTimeEvolutionLegend(),
                  const Gap(24),
                  _buildTimeEvolutionSummary(timeData),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeEvolutionChart(List<TimeEvolutionData> timeData) {
    // maxValue eliminado porque no se usa

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: timeData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.highRiskCount.toDouble())).toList(),
            isCurved: true,
            color: const Color(0xFFDC2626),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, xPercentage, barData, index) => FlDotCirclePainter(
                radius: 5,
                color: const Color(0xFFDC2626),
                strokeColor: Colors.white,
                strokeWidth: 2,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFDC2626).withAlpha((0.1 * 255).toInt()),
            ),
          ),
          LineChartBarData(
            spots: timeData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.lowRiskCount.toDouble())).toList(),
            isCurved: true,
            color: const Color(0xFF16A34A),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, xPercentage, barData, index) => FlDotCirclePainter(
                radius: 5,
                color: const Color(0xFF16A34A),
                strokeColor: Colors.white,
                strokeWidth: 2,
              ),
            ),
             belowBarData: BarAreaData(
               show: true,
               color: const Color(0xFF16A34A).withAlpha((0.1 * 255).toInt()),
             ),
          ),
          if (timeData.any((d) => d.naCount > 0))
            LineChartBarData(
              spots: timeData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.naCount.toDouble())).toList(),
              isCurved: true,
              color: const Color(0xFF0EA5E9),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, xPercentage, barData, index) => FlDotCirclePainter(
                  radius: 5,
                  color: const Color(0xFF0EA5E9),
                  strokeColor: Colors.white,
                  strokeWidth: 2,
                ),
              ),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFF0EA5E9).withAlpha((0.1 * 255).toInt()),
                ),
            ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= timeData.length) return const Text('');
                final month = timeData[index].month;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${month.month}/${month.year}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFFF3F4F6),
            strokeWidth: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeEvolutionLegend() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(2)),
              ),
              const Gap(6),
              const Text('Alto Riesgo', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(2)),
              ),
              const Gap(6),
              const Text('Bajo Riesgo', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: const Color(0xFF0EA5E9), borderRadius: BorderRadius.circular(2)),
              ),
              const Gap(6),
              const Text('NA', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeEvolutionSummary(List<TimeEvolutionData> timeData) {
    int totalHigh = timeData.fold(0, (sum, e) => sum + e.highRiskCount);
    int totalLow = timeData.fold(0, (sum, e) => sum + e.lowRiskCount);
    int totalNA = timeData.fold(0, (sum, e) => sum + e.naCount);

    final firstMonth = timeData.first.month;
    final lastMonth = timeData.last.month;

    // Calcular tendencia
    final firstHighRisk = timeData.first.highRiskCount;
    final lastHighRisk = timeData.last.highRiskCount;
    final trend = lastHighRisk > firstHighRisk ? 'Incremento ↑' : 'Decremento ↓';
    final trendChange = (lastHighRisk - firstHighRisk).abs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withAlpha((0.1 * 255).toInt()),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF3B82F6).withAlpha((0.3 * 255).toInt())),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Período: ${firstMonth.day}/${firstMonth.month}/${firstMonth.year} - ${lastMonth.day}/${lastMonth.month}/${lastMonth.year}',
                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.mutedForeground)),
              const Gap(8),
              Text('Tendencia General: $trend ($trendChange casos)',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const Gap(16),
        Text('Totales por Período', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.foreground)),
        const Gap(12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _TimeEvolutionStatBox(
              label: 'Alto Riesgo',
              value: totalHigh,
              color: const Color(0xFFDC2626),
            ),
            _TimeEvolutionStatBox(
              label: 'Bajo Riesgo',
              value: totalLow,
              color: const Color(0xFF16A34A),
            ),
            _TimeEvolutionStatBox(
              label: 'NA',
              value: totalNA,
              color: const Color(0xFF0EA5E9),
            ),
          ],
        ),
        const Gap(12),
        Text('Detalle Mensual', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.foreground)),
        const Gap(8),
        ...timeData.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${item.month.month}/${item.month.year}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('AR: ${item.highRiskCount}',
                        style: const TextStyle(fontSize: 10, color: Color(0xFFDC2626), fontWeight: FontWeight.w600)),
                  ),
                  const Gap(4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('BR: ${item.lowRiskCount}',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
                  ),
                  if (item.naCount > 0) ...[
                    const Gap(4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withAlpha((0.1 * 255).toInt()),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('NA: ${item.naCount}',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF0EA5E9), fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        )),
      ],
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

class _TimeEvolutionStatBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _TimeEvolutionStatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((0.3 * 255).toInt())),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const Gap(4),
          Text(label, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}





