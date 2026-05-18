import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/doughnut_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/horizontal_bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/stacked_bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

class AssistReportSection extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  static final k1 = GlobalKey(debugLabel: 'assist_k1');
  static final k2 = GlobalKey(debugLabel: 'assist_k2');
  static final k3 = GlobalKey(debugLabel: 'assist_k3');
  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  const AssistReportSection({super.key, required this.surveys});

  static const _color = Color(0xFF6B7FBD);

  // ASSIST question ranges per substance block (each substance spans ~8 questions in the survey)
  // For simplicity we use total score and distribution
  static const _substances = [
    (id: 1, label: 'Tabaco'),   (id: 2, label: 'Alcohol'),
    (id: 3, label: 'Cannabis'), (id: 4, label: 'Cocaína'),
    (id: 5, label: 'Anfetam.'), (id: 6, label: 'Inhalantes'),
    (id: 7, label: 'Sedantes'), (id: 8, label: 'Alucinóg.'),
    (id: 9, label: 'Opiáceos'), (id: 10, label: 'Otras'),
  ];

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) return const Center(child: Text('Sin encuestas disponibles'));
    final scores = surveys.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);

    // Compute substance-level scores from responses
    // ASSIST responses store substance-specific scores keyed by question_id
    // question_ids 1-10 map to each substance's composite score
    final substanceMeans = <int, double>{};
    final substanceCounts = <int, int>{};
    for (final s in surveys) {
      final r = (s['responses'] as List? ?? []).cast<Map<String, dynamic>>();
      for (final sub in _substances) {
        final match = r.where((x) => (x['question_id'] as int?) == sub.id);
        if (match.isNotEmpty) {
          substanceMeans[sub.id] = (substanceMeans[sub.id] ?? 0) + (match.first['answer_value'] as int? ?? 0);
          substanceCounts[sub.id] = (substanceCounts[sub.id] ?? 0) + 1;
        }
      }
    }
    final hBarItems = _substances.map((s) {
      final n = substanceCounts[s.id] ?? 0;
      final total = substanceMeans[s.id] ?? 0;
      return (label: s.label, value: n == 0 ? 0.0 : total / n);
    }).where((i) => i.value > 0).toList();

    // Risk distribution
    int low = 0, moderate = 0, high = 0;
    for (final score in scores) {
      if (score <= 3) low++;
      else if (score <= 26) moderate++;
      else high++;
    }
    final doughnut = [
      if (low > 0) PieChartSectionData(value: low.toDouble(), color: const Color(0xFF10B981), radius: 55,
          title: '$low', titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
      if (moderate > 0) PieChartSectionData(value: moderate.toDouble(), color: const Color(0xFFF59E0B), radius: 55,
          title: '$moderate', titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
      if (high > 0) PieChartSectionData(value: high.toDouble(), color: const Color(0xFFEF4444), radius: 55,
          title: '$high', titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
    ];
    final doughnutLegend = [
      (label: 'Bajo (0-3)', color: const Color(0xFF10B981), value: null as String?),
      (label: 'Moderado (4-26)', color: const Color(0xFFF59E0B), value: null as String?),
      (label: 'Alto (27+)', color: const Color(0xFFEF4444), value: null as String?),
    ];

    // 100% stacked bar (risk level by substance)
    final groups = <BarChartGroupData>[];
    final stackLabels = <String>[];
    for (var i = 0; i < _substances.length; i++) {
      final sub = _substances[i];
      final n = substanceCounts[sub.id] ?? 0;
      if (n == 0) continue;
      final mean = (substanceMeans[sub.id] ?? 0) / n;
      final lowPct = mean <= 3 ? 100.0 : 0.0;
      final modPct = (mean > 3 && mean <= 26) ? 100.0 : 0.0;
      final highPct = mean > 26 ? 100.0 : 0.0;
      groups.add(BarChartGroupData(x: groups.length, barRods: [
        BarChartRodData(toY: 100, width: 18, color: const Color(0xFF10B981),
          rodStackItems: [
            BarChartRodStackItem(0, lowPct, const Color(0xFF10B981)),
            BarChartRodStackItem(lowPct, lowPct + modPct, const Color(0xFFF59E0B)),
            BarChartRodStackItem(lowPct + modPct, 100, const Color(0xFFEF4444)),
          ],
        ),
      ]));
      stackLabels.add(sub.label);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'ASSIST V3.0 — Consumo de Sustancias',
        subtitle: 'Nivel de riesgo por tipo de sustancia',
        icon: Icons.health_and_safety_outlined,
        color: _color,
      ),
      const Gap(16),
      MetricCardGroup(cards: buildScoredMetricCards(
        mean: stats.mean, mode: stats.mode, stdDev: stats.stdDev, count: stats.count, color: _color,
      )),
      const Gap(16),
      if (groups.isNotEmpty)
        ChartCard(
          title: 'Nivel de riesgo por sustancia (100%)',
          boundaryKey: k1,
          chart: StackedBarChart(
            groups: groups,
            maxY: 100,
            bottomLabels: stackLabels,
            percentageMode: true,
            legend: const [
              (label: 'Bajo', color: Color(0xFF10B981)),
              (label: 'Moderado', color: Color(0xFFF59E0B)),
              (label: 'Alto', color: Color(0xFFEF4444)),
            ],
          ),
        ),
      const Gap(12),
      if (hBarItems.isNotEmpty)
        ChartCard(
          title: 'Puntaje medio por sustancia',
          boundaryKey: k2,
          height: hBarItems.length * 36.0 + 20,
          chart: HorizontalBarChart(items: hBarItems, maxValue: 39, color: _color),
        ),
      const Gap(12),
      ChartCard(
        title: 'Distribución de riesgo global',
        boundaryKey: k3,
        chart: DoughnutChart(sections: doughnut, legend: doughnutLegend, holeRadius: 55),
      ),
      const Gap(12),
      OutlinedContainer(
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(14),
        backgroundColor: _color.withValues(alpha: 0.05),
        borderColor: _color.withValues(alpha: 0.3),
        child: Text(SurveyStatsCalculator.assistInterpretation(stats.mean),
            style: const TextStyle(fontSize: 13, height: 1.5)),
      ),
    ]);
  }
}
