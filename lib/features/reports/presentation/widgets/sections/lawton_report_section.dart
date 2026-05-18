import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/doughnut_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/horizontal_bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/line_timeline_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

class LawtonReportSection extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  static final k1 = GlobalKey(debugLabel: 'lawton_k1');
  static final k2 = GlobalKey(debugLabel: 'lawton_k2');
  static final k3 = GlobalKey(debugLabel: 'lawton_k3');
  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  const LawtonReportSection({super.key, required this.surveys});

  static const _color = Color(0xFF14B8A6);

  static const _taskLabels = [
    'Teléfono', 'Transporte', 'Medicación', 'Finanzas',
    'Compras', 'Comida', 'Limpieza', 'Ropa',
  ];

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) return const Center(child: Text('Sin encuestas disponibles'));
    final sorted = List<Map<String, dynamic>>.from(surveys)
      ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
    final scores = sorted.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);

    // Per-task independence rate
    final taskMeans = <double>[];
    for (var q = 1; q <= _taskLabels.length; q++) {
      double sum = 0; int n = 0;
      for (final s in sorted) {
        final r = (s['responses'] as List? ?? []).cast<Map<String, dynamic>>();
        final match = r.where((x) => (x['question_id'] as int?) == q);
        if (match.isNotEmpty) { sum += (match.first['answer_value'] as int? ?? 0); n++; }
      }
      taskMeans.add(n == 0 ? 0 : sum / n);
    }

    final hBarItems = List.generate(
      _taskLabels.length.clamp(0, taskMeans.length),
      (i) => (label: _taskLabels[i], value: taskMeans[i] * 100),
    );

    final independent = scores.where((s) => s == 8).length;
    final dependent = scores.length - independent;
    final doughnut = [
      PieChartSectionData(value: independent.toDouble(), color: _color,
          title: '$independent', radius: 55, titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
      if (dependent > 0)
        PieChartSectionData(value: dependent.toDouble(), color: const Color(0xFFE2E8F0),
            title: '$dependent', radius: 55, titleStyle: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
    ];
    final doughnutLegend = [
      (label: 'Independencia total', color: _color, value: null as String?),
      (label: 'Deterioro funcional', color: const Color(0xFF94A3B8), value: null as String?),
    ];

    final timelineSpots = [for (var i = 0; i < scores.length; i++) FlSpot(i.toDouble(), scores[i].toDouble())];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'Lawton AIVD — Actividades Instrumentales',
        subtitle: 'Autonomía funcional en 8 tareas cotidianas (0–8)',
        icon: Icons.accessibility_outlined,
        color: _color,
      ),
      const Gap(16),
      MetricCardGroup(cards: buildScoredMetricCards(
        mean: stats.mean, mode: stats.mode, stdDev: stats.stdDev, count: stats.count, color: _color,
      )),
      const Gap(16),
      ChartCard(
        title: 'Independencia por tarea (% de pacientes independientes)',
        boundaryKey: k1,
        height: 320,
        chart: HorizontalBarChart(items: hBarItems, maxValue: 100, color: _color, valueUnit: '%'),
      ),
      const Gap(12),
      ChartCard(
        title: 'Independencia total vs deterioro funcional',
        boundaryKey: k2,
        chart: DoughnutChart(sections: doughnut, legend: doughnutLegend, holeRadius: 55),
      ),
      const Gap(12),
      ChartCard(
        title: 'Evolución del puntaje',
        boundaryKey: k3,
        chart: LineTimelineChart(
          series: [LineChartBarData(
            spots: timelineSpots,
            isCurved: true,
            color: _color,
            barWidth: 2.5,
            dotData: FlDotData(show: scores.length <= 15),
          )],
          maxY: 8,
        ),
      ),
      const Gap(12),
      OutlinedContainer(
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(14),
        backgroundColor: _color.withValues(alpha: 0.05),
        borderColor: _color.withValues(alpha: 0.3),
        child: Text(SurveyStatsCalculator.lawtonInterpretation(stats.mean),
            style: const TextStyle(fontSize: 13, height: 1.5)),
      ),
    ]);
  }
}
