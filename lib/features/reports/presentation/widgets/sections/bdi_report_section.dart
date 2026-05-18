import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/report_models.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/gauge_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/line_timeline_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/stacked_bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

class BdiReportSection extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  static final k1 = GlobalKey(debugLabel: 'bdi_k1');
  static final k2 = GlobalKey(debugLabel: 'bdi_k2');
  static final k3 = GlobalKey(debugLabel: 'bdi_k3');
  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  const BdiReportSection({super.key, required this.surveys});

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) return const _EmptyState();
    final sorted = List<Map<String, dynamic>>.from(surveys)
      ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
    final scores = sorted.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'BDI-II — Inventario de Depresión de Beck',
          subtitle: 'Severidad de la depresión (0–63 puntos)',
          icon: Icons.psychology_outlined,
          color: const Color(0xFF10B981),
        ),
        const Gap(16),
        MetricCardGroup(cards: buildScoredMetricCards(
          mean: stats.mean, mode: stats.mode, stdDev: stats.stdDev, count: stats.count,
          color: const Color(0xFF10B981),
        )),
        const Gap(16),
        ChartCard(
          title: 'Severidad media — Gauge',
          boundaryKey: k1,
          chart: GaugeChart(
            value: stats.mean,
            maxValue: 63,
            centerLabel: stats.mean.toStringAsFixed(1),
            sublabel: SurveyStatsCalculator.bdiLevel(stats.mean.round()),
            segments: const [
              GaugeSegment(label: 'Mínima', endValue: 13, color: Color(0xFF10B981)),
              GaugeSegment(label: 'Leve', endValue: 19, color: Color(0xFFFBBF24)),
              GaugeSegment(label: 'Moderada', endValue: 28, color: Color(0xFFF97316)),
              GaugeSegment(label: 'Severa', endValue: 63, color: Color(0xFFEF4444)),
            ],
          ),
        ),
        const Gap(12),
        ChartCard(
          title: 'Cognitivo vs Somático (últimas ${sorted.length.clamp(0, 8)} encuestas)',
          boundaryKey: k2,
          chart: _stackedBdi(sorted.length > 8 ? sorted.sublist(sorted.length - 8) : sorted),
        ),
        const Gap(12),
        ChartCard(
          title: 'Evolución del puntaje',
          boundaryKey: k3,
          chart: LineTimelineChart(
            series: [LineChartBarData(
              spots: [for (var i = 0; i < scores.length; i++) FlSpot(i.toDouble(), scores[i].toDouble())],
              isCurved: true,
              color: const Color(0xFF10B981),
              barWidth: 2.5,
              dotData: FlDotData(show: scores.length <= 15),
            )],
            maxY: 63,
          ),
        ),
        const Gap(12),
        _InterpretationBox(text: SurveyStatsCalculator.bdiInterpretation(stats.mean)),
      ],
    );
  }

  Widget _stackedBdi(List<Map<String, dynamic>> last) {
    int cogScore(Map<String, dynamic> s) {
      final r = s['responses'] as List? ?? [];
      return r.where((x) => (x['question_id'] as int? ?? 0) <= 13)
          .fold(0, (sum, x) => sum + (x['answer_value'] as int? ?? 0));
    }
    int somScore(Map<String, dynamic> s) {
      final r = s['responses'] as List? ?? [];
      return r.where((x) => (x['question_id'] as int? ?? 0) > 13)
          .fold(0, (sum, x) => sum + (x['answer_value'] as int? ?? 0));
    }
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < last.length; i++) {
      final cog = cogScore(last[i]).toDouble();
      final som = somScore(last[i]).toDouble();
      groups.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: cog + som, width: 22, color: const Color(0xFF10B981),
          rodStackItems: [
            BarChartRodStackItem(0, cog, const Color(0xFF10B981)),
            BarChartRodStackItem(cog, cog + som, const Color(0xFF059669)),
          ],
        ),
      ]));
    }
    return StackedBarChart(
      groups: groups,
      maxY: 63,
      bottomLabels: List.generate(last.length, (i) => '${i + 1}'),
      legend: const [
        (label: 'Cognitivo', color: Color(0xFF10B981)),
        (label: 'Somático', color: Color(0xFF059669)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Sin encuestas disponibles'));
}

class _InterpretationBox extends StatelessWidget {
  final String text;
  const _InterpretationBox({required this.text});
  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      borderRadius: BorderRadius.circular(8),
      padding: const EdgeInsets.all(14),
      backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.05),
      borderColor: const Color(0xFF10B981).withValues(alpha: 0.3),
      child: Text(text, style: const TextStyle(fontSize: 13, height: 1.5)),
    );
  }
}
