import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/divergent_likert_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/histogram_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/line_timeline_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

class Ghq12ReportSection extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  static final k1 = GlobalKey(debugLabel: 'ghq12_k1');
  static final k2 = GlobalKey(debugLabel: 'ghq12_k2');
  static final k3 = GlobalKey(debugLabel: 'ghq12_k3');
  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  const Ghq12ReportSection({super.key, required this.surveys});

  static const _color = Color(0xFF0284C7);

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) return const Center(child: Text('Sin encuestas disponibles'));
    final sorted = List<Map<String, dynamic>>.from(surveys)
      ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
    final scores = sorted.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);

    // Per-item analysis: 12 items, low score (0-1) = positive, high (2-3) = problem
    const itemLabels = [
      'Concentración', 'Insomnio', 'Rol útil', 'Decisiones',
      'Estrés constante', 'Dificultades', 'Disfrute', 'Problemas',
      'Depresión', 'Confianza', 'Merecer felicidad', 'Futuro',
    ];
    final likertItems = <({String label, int positive, int negative, int total})>[];
    for (var q = 1; q <= 12; q++) {
      int pos = 0, neg = 0;
      for (final s in sorted) {
        final r = (s['responses'] as List? ?? []).cast<Map<String, dynamic>>();
        final match = r.where((x) => (x['question_id'] as int?) == q);
        if (match.isNotEmpty) {
          final val = match.first['answer_value'] as int? ?? 0;
          if (val <= 1) pos++; else neg++;
        }
      }
      likertItems.add((
        label: q <= itemLabels.length ? itemLabels[q - 1] : 'Ítem $q',
        positive: pos, negative: neg, total: pos + neg,
      ));
    }

    final timelineSpots = [for (var i = 0; i < scores.length; i++) FlSpot(i.toDouble(), scores[i].toDouble())];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'GHQ-12 — Cuestionario de Salud General',
        subtitle: 'Cribado de malestar psicológico (0–36 puntos)',
        icon: Icons.psychology_alt_outlined,
        color: _color,
      ),
      const Gap(16),
      MetricCardGroup(cards: buildScoredMetricCards(
        mean: stats.mean, mode: stats.mode, stdDev: stats.stdDev, count: stats.count, color: _color,
      )),
      const Gap(16),
      ChartCard(
        title: 'Distribución de puntajes totales',
        boundaryKey: k1,
        chart: HistogramChart(
          values: scores.map((s) => s.toDouble()).toList(),
          color: _color,
          xLabel: 'Puntaje',
        ),
      ),
      const Gap(12),
      ChartCard(
        title: 'Respuestas normales vs problemáticas por ítem',
        boundaryKey: k2,
        height: 380,
        chart: DivergentLikertChart(
          items: likertItems,
          positiveColor: const Color(0xFF10B981),
          negativeColor: const Color(0xFFDC2626),
          positiveLegend: 'Normal / Mejor',
          negativeLegend: 'Problema / Peor',
        ),
      ),
      const Gap(12),
      ChartCard(
        title: 'Tendencia del puntaje total',
        boundaryKey: k3,
        chart: LineTimelineChart(
          series: [LineChartBarData(
            spots: timelineSpots,
            isCurved: true,
            color: _color,
            barWidth: 2.5,
            dotData: FlDotData(show: scores.length <= 15),
          )],
          maxY: 36,
        ),
      ),
    ]);
  }
}
