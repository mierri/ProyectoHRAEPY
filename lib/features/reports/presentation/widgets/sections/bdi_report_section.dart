import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/gauge_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/line_timeline_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

class BdiReportSection extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  static final k1 = GlobalKey(debugLabel: 'bdi_k1');
  static final k2 = GlobalKey(debugLabel: 'bdi_k2');
  static final k3 = GlobalKey(debugLabel: 'bdi_k3');
  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  static const _color = Color(0xFF10B981);

  // BDI-II item categories
  // Cognitivo-afectivos: 1-13 | Somáticos: 14-21
  static const _cogLabel = 'Cognitivo-afectivo (ítem 1-13)';
  static const _somLabel = 'Somático (ítem 14-21)';

  const BdiReportSection({super.key, required this.surveys});

  int _sumItems(Map<String, dynamic> s, bool Function(int q) filter) {
    final r = (s['responses'] as List? ?? []).cast<Map<String, dynamic>>();
    return r.where((x) => filter(x['question_id'] as int? ?? 0))
        .fold(0, (sum, x) => sum + (x['answer_value'] as int? ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) return const Center(child: Text('Sin encuestas disponibles'));

    final sorted = List<Map<String, dynamic>>.from(surveys)
      ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
    final scores = sorted.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);

    // Cognitive vs somatic trends
    final cogScores = sorted.map((s) => _sumItems(s, (q) => q >= 1 && q <= 13).toDouble()).toList();
    final somScores = sorted.map((s) => _sumItems(s, (q) => q >= 14 && q <= 21).toDouble()).toList();
    final maxCogSom = (cogScores + somScores).fold(0.0, (a, b) => a > b ? a : b) + 2;

    final timelineSpots = [for (var i = 0; i < scores.length; i++) FlSpot(i.toDouble(), scores[i].toDouble())];
    final cogSpots = [for (var i = 0; i < cogScores.length; i++) FlSpot(i.toDouble(), cogScores[i])];
    final somSpots = [for (var i = 0; i < somScores.length; i++) FlSpot(i.toDouble(), somScores[i])];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'BDI-II — Inventario de Depresión de Beck',
        subtitle: 'Severidad de la depresión (0–63 puntos)',
        icon: Icons.psychology_outlined,
        color: _color,
      ),
      const Gap(16),
      MetricCardGroup(cards: buildScoredMetricCards(
        mean: stats.mean, mode: stats.mode, stdDev: stats.stdDev, count: stats.count, color: _color,
      )),
      const Gap(16),
      // Chart 1: Gauge — severity level
      ChartCard(
        title: 'Nivel de severidad (media: ${stats.mean.toStringAsFixed(1)} pts)',
        boundaryKey: k1,
        height: 220,
        chart: GaugeChart(
          value: stats.mean,
          maxValue: 63,
          centerLabel: stats.mean.toStringAsFixed(1),
          sublabel: SurveyStatsCalculator.bdiLevel(stats.mean.round()),
          segments: const [
            GaugeSegment(label: 'Mínima  (0-13)', endValue: 13, color: Color(0xFF10B981)),
            GaugeSegment(label: 'Leve  (14-19)', endValue: 19, color: Color(0xFFFBBF24)),
            GaugeSegment(label: 'Moderada  (20-28)', endValue: 28, color: Color(0xFFF97316)),
            GaugeSegment(label: 'Severa  (29-63)', endValue: 63, color: Color(0xFFEF4444)),
          ],
        ),
      ),
      const Gap(12),
      // Chart 2: Dual-line — cognitive vs somatic trend
      ChartCard(
        title: 'Síntomas cognitivos vs somáticos por sesión',
        boundaryKey: k2,
        chart: _DualLineNote(
          series: [
            LineChartBarData(
              spots: cogSpots,
              isCurved: true,
              color: const Color(0xFF6366F1),
              barWidth: 2.5,
              dotData: FlDotData(show: cogSpots.length <= 12),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF6366F1).withValues(alpha: 0.08)),
            ),
            LineChartBarData(
              spots: somSpots,
              isCurved: true,
              color: const Color(0xFFF97316),
              barWidth: 2.5,
              dashArray: [6, 3],
              dotData: FlDotData(show: somSpots.length <= 12),
            ),
          ],
          maxY: maxCogSom,
          legend1: _cogLabel,
          legend2: _somLabel,
          color1: const Color(0xFF6366F1),
          color2: const Color(0xFFF97316),
        ),
      ),
      const Gap(12),
      // Chart 3: Line — total score evolution
      ChartCard(
        title: 'Evolución del puntaje total',
        boundaryKey: k3,
        chart: LineTimelineChart(
          series: [LineChartBarData(
            spots: timelineSpots,
            isCurved: true,
            color: _color,
            barWidth: 2.5,
            dotData: FlDotData(show: scores.length <= 15),
          )],
          maxY: 63,
        ),
      ),
      const Gap(12),
      _InterpretationBox(
        color: _color,
        text: SurveyStatsCalculator.bdiInterpretation(stats.mean),
      ),
    ]);
  }
}

// Dual-line chart with legend labels below
class _DualLineNote extends StatelessWidget {
  final List<LineChartBarData> series;
  final double maxY;
  final String legend1, legend2;
  final Color color1, color2;

  const _DualLineNote({
    required this.series, required this.maxY,
    required this.legend1, required this.legend2,
    required this.color1, required this.color2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: LineTimelineChart(series: series, maxY: maxY),
      ),
      const Gap(6),
      Wrap(spacing: 16, runSpacing: 4, alignment: WrapAlignment.center, children: [
        _leg(color1, legend1, solid: true),
        _leg(color2, legend2, solid: false),
      ]),
    ]);
  }

  Widget _leg(Color c, String label, {required bool solid}) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(
      width: 20, height: 2.5,
      color: solid ? c : null,
      decoration: solid ? null : BoxDecoration(
        gradient: LinearGradient(colors: [c, Colors.transparent, c, Colors.transparent]),
      ),
    ),
    const Gap(5),
    Flexible(child: Text(label, style: const TextStyle(fontSize: 10))),
  ]);
}

class _InterpretationBox extends StatelessWidget {
  final Color color;
  final String text;
  const _InterpretationBox({required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      borderRadius: BorderRadius.circular(8),
      padding: const EdgeInsets.all(14),
      backgroundColor: color.withValues(alpha: 0.05),
      borderColor: color.withValues(alpha: 0.3),
      child: Text(text, style: const TextStyle(fontSize: 13, height: 1.5)),
    );
  }
}
