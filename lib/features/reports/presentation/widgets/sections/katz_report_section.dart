import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/doughnut_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/horizontal_bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/radar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

class KatzReportSection extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  static final k1 = GlobalKey(debugLabel: 'katz_k1');
  static final k2 = GlobalKey(debugLabel: 'katz_k2');
  static final k3 = GlobalKey(debugLabel: 'katz_k3');
  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  const KatzReportSection({super.key, required this.surveys});

  static const _color = Color(0xFF0D9488);
  static const _funcLabels = ['Baño', 'Vestido', 'Sanitario', 'Movilidad', 'Continencia', 'Alimentación'];

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) return const Center(child: Text('Sin encuestas disponibles'));
    final sorted = List<Map<String, dynamic>>.from(surveys)
      ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
    final scores = sorted.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);

    // Per-function independence rate (q 1-6)
    final funcMeans = <double>[];
    for (var q = 1; q <= 6; q++) {
      double sum = 0; int n = 0;
      for (final s in sorted) {
        final r = (s['responses'] as List? ?? []).cast<Map<String, dynamic>>();
        final match = r.where((x) => (x['question_id'] as int?) == q);
        if (match.isNotEmpty) { sum += (match.first['answer_value'] as int? ?? 0); n++; }
      }
      funcMeans.add(n == 0 ? 0 : sum / n * 100);
    }

    final hBarItems = List.generate(_funcLabels.length, (i) =>
      (label: _funcLabels[i], value: i < funcMeans.length ? funcMeans[i] : 0.0));

    final independent = scores.where((s) => s == 6).length;
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
      (label: 'Dependencia parcial', color: const Color(0xFF94A3B8), value: null as String?),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'Katz ABVD — Actividades Básicas de la Vida Diaria',
        subtitle: 'Nivel de independencia en 6 funciones básicas (0–6)',
        icon: Icons.self_improvement_outlined,
        color: _color,
      ),
      const Gap(16),
      MetricCardGroup(cards: buildScoredMetricCards(
        mean: stats.mean, mode: stats.mode, stdDev: stats.stdDev, count: stats.count, color: _color,
      )),
      const Gap(16),
      ChartCard(
        title: 'Perfil de independencia por función (% de encuestas)',
        boundaryKey: k1,
        chart: ReportRadarChart(
          labels: _funcLabels,
          values: funcMeans,
          maxValue: 100,
          color: _color,
        ),
      ),
      const Gap(12),
      ChartCard(
        title: 'Independencia por función',
        boundaryKey: k2,
        height: 260,
        chart: HorizontalBarChart(items: hBarItems, maxValue: 100, color: _color, valueUnit: '%'),
      ),
      const Gap(12),
      ChartCard(
        title: 'Independencia total vs dependencia',
        boundaryKey: k3,
        chart: DoughnutChart(sections: doughnut, legend: doughnutLegend, holeRadius: 55),
      ),
      const Gap(12),
      OutlinedContainer(
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(14),
        backgroundColor: _color.withValues(alpha: 0.05),
        borderColor: _color.withValues(alpha: 0.3),
        child: Text(SurveyStatsCalculator.katzInterpretation(stats.mean),
            style: const TextStyle(fontSize: 13, height: 1.5)),
      ),
    ]);
  }
}
