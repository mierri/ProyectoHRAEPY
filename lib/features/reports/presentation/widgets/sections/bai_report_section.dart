import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/area_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/doughnut_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/horizontal_bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

class BaiReportSection extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  static final k1 = GlobalKey(debugLabel: 'bai_k1');
  static final k2 = GlobalKey(debugLabel: 'bai_k2');
  static final k3 = GlobalKey(debugLabel: 'bai_k3');
  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  const BaiReportSection({super.key, required this.surveys});

  static const _color = Color(0xFF14B8A6);

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) return const Center(child: Text('Sin encuestas disponibles'));
    final sorted = List<Map<String, dynamic>>.from(surveys)
      ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
    final scores = sorted.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);
    final dist = SurveyStatsCalculator.baiDistribution(surveys);

    final spots = [for (var i = 0; i < scores.length; i++) FlSpot(i.toDouble(), scores[i].toDouble())];

    // Somatic vs subjective: items 1-13 = subjective/cognitive, 14-21 = somatic
    double _groupMean(List<Map<String, dynamic>> srvs, bool Function(int) qFilter) {
      int total = 0, n = 0;
      for (final s in srvs) {
        final r = s['responses'] as List? ?? [];
        for (final x in r) {
          if (qFilter(x['question_id'] as int? ?? 0)) {
            total += x['answer_value'] as int? ?? 0;
            n++;
          }
        }
      }
      return n == 0 ? 0 : total / n;
    }
    final somMean = _groupMean(sorted, (q) => q >= 14);
    final subMean = _groupMean(sorted, (q) => q > 0 && q < 14);

    final doughnutSections = dist.counts.entries.where((e) => e.value > 0).map((e) {
      const colors = {
        'Mínima': Color(0xFF10B981), 'Leve': Color(0xFFFBBF24),
        'Moderada': Color(0xFFF97316), 'Severa': Color(0xFFEF4444),
      };
      final c = colors[e.key] ?? _color;
      return PieChartSectionData(
        value: e.value.toDouble(), color: c,
        title: '${dist.pct(e.key).toStringAsFixed(0)}%',
        radius: 55, titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
      );
    }).toList();

    final legend = dist.counts.entries.map((e) {
      const colors = {
        'Mínima': Color(0xFF10B981), 'Leve': Color(0xFFFBBF24),
        'Moderada': Color(0xFFF97316), 'Severa': Color(0xFFEF4444),
      };
      return (label: e.key, color: colors[e.key] ?? _color, value: '${e.value}');
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'BAI — Inventario de Ansiedad de Beck',
        subtitle: 'Severidad de la ansiedad (0–63 puntos)',
        icon: Icons.monitor_heart_outlined,
        color: _color,
      ),
      const Gap(16),
      MetricCardGroup(cards: buildScoredMetricCards(
        mean: stats.mean, mode: stats.mode, stdDev: stats.stdDev, count: stats.count, color: _color,
      )),
      const Gap(16),
      ChartCard(
        title: 'Evolución — Carga acumulada de ansiedad',
        boundaryKey: k1,
        chart: AreaChart(spots: spots, maxY: 63, color: _color),
      ),
      const Gap(12),
      ChartCard(
        title: 'Síntomas somáticos vs subjetivos (media por ítem)',
        boundaryKey: k2,
        height: 140,
        chart: HorizontalBarChart(
          items: [
            (label: 'Subjetivos / Cognitivos', value: subMean),
            (label: 'Somáticos / Físicos', value: somMean),
          ],
          maxValue: 3,
          color: _color,
          valueUnit: ' pts',
        ),
      ),
      const Gap(12),
      ChartCard(
        title: 'Distribución por nivel de ansiedad',
        boundaryKey: k3,
        chart: DoughnutChart(sections: doughnutSections, legend: legend),
      ),
      const Gap(12),
      OutlinedContainer(
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(14),
        backgroundColor: _color.withValues(alpha: 0.05),
        borderColor: _color.withValues(alpha: 0.3),
        child: Text(SurveyStatsCalculator.baiInterpretation(stats.mean),
            style: const TextStyle(fontSize: 13, height: 1.5)),
      ),
    ]);
  }
}
