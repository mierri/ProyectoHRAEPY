import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/gauge_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/horizontal_bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/line_timeline_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

class GdsReportSection extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  static final k1 = GlobalKey(debugLabel: 'gds_k1');
  static final k2 = GlobalKey(debugLabel: 'gds_k2');
  static final k3 = GlobalKey(debugLabel: 'gds_k3');
  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  const GdsReportSection({super.key, required this.surveys});

  static const _color = Color(0xFF0EA5E9);

  // Positive items (answer YES = 1 pt): 2,3,4,6,8,9,10,12,14,15
  // Negative items (answer YES = 0 pt): 1,5,7,11,13
  static const _positiveItems = [2, 3, 4, 6, 8, 9, 10, 12, 14, 15];

  static const _itemLabels = {
    2:  'Renunció a hobbies',
    3:  'Vida vacía',
    4:  'Aburrimiento frecuente',
    6:  'Teme algo malo',
    8:  'Se siente impotente',
    9:  'Prefiere quedarse en casa',
    10: 'Problemas de memoria',
    12: 'Dificultad en proyectos',
    14: 'Situación desesperada',
    15: 'Otros están mejor',
  };

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) return const Center(child: Text('Sin encuestas disponibles'));
    final sorted = List<Map<String, dynamic>>.from(surveys)
      ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
    final scores = sorted.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);

    // Frequency of positive responses per item
    final itemFreq = <int, int>{for (var q in _positiveItems) q: 0};
    int total = 0;
    for (final s in sorted) {
      total++;
      final r = (s['responses'] as List? ?? []).cast<Map<String, dynamic>>();
      for (final q in _positiveItems) {
        final match = r.where((x) => (x['question_id'] as int?) == q);
        if (match.isNotEmpty && (match.first['answer_value'] as int? ?? 0) == 1) {
          itemFreq[q] = (itemFreq[q] ?? 0) + 1;
        }
      }
    }

    final hBarItems = itemFreq.entries
        .map((e) => (label: _itemLabels[e.key] ?? 'Ítem ${e.key}', value: total == 0 ? 0.0 : (e.value / total * 100)))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final timelineSpots = [for (var i = 0; i < scores.length; i++) FlSpot(i.toDouble(), scores[i].toDouble())];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'GDS-15 — Escala de Depresión Geriátrica',
        subtitle: 'Depresión en adultos mayores (0–15 puntos)',
        icon: Icons.elderly_outlined,
        color: _color,
      ),
      const Gap(16),
      MetricCardGroup(cards: buildScoredMetricCards(
        mean: stats.mean, mode: stats.mode, stdDev: stats.stdDev, count: stats.count, color: _color,
      )),
      const Gap(16),
      ChartCard(
        title: 'Severidad media — Gauge',
        boundaryKey: k1,
        chart: GaugeChart(
          value: stats.mean,
          maxValue: 15,
          centerLabel: stats.mean.toStringAsFixed(1),
          sublabel: SurveyStatsCalculator.gdsLevel(stats.mean.round()),
          segments: const [
            GaugeSegment(label: 'Normal', endValue: 4, color: Color(0xFF10B981)),
            GaugeSegment(label: 'Leve', endValue: 8, color: Color(0xFFFBBF24)),
            GaugeSegment(label: 'Moderada', endValue: 11, color: Color(0xFFF97316)),
            GaugeSegment(label: 'Severa', endValue: 15, color: Color(0xFFEF4444)),
          ],
        ),
      ),
      const Gap(12),
      ChartCard(
        title: 'Ítems positivos más frecuentes (% de encuestas)',
        boundaryKey: k2,
        height: hBarItems.length * 36.0 + 20,
        chart: HorizontalBarChart(
          items: hBarItems.take(8).toList(),
          maxValue: 100,
          color: _color,
          valueUnit: '%',
        ),
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
          maxY: 15,
        ),
      ),
      const Gap(12),
      OutlinedContainer(
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(14),
        backgroundColor: _color.withValues(alpha: 0.05),
        borderColor: _color.withValues(alpha: 0.3),
        child: Text(SurveyStatsCalculator.gdsInterpretation(stats.mean),
            style: const TextStyle(fontSize: 13, height: 1.5)),
      ),
    ]);
  }
}
