import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/line_timeline_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/lollipop_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/kpi_alert_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

class Phq9ReportSection extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  static final k1 = GlobalKey(debugLabel: 'phq9_k1');
  static final k2 = GlobalKey(debugLabel: 'phq9_k2');
  static final k3 = GlobalKey(debugLabel: 'phq9_k3');
  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  const Phq9ReportSection({super.key, required this.surveys});

  static const _color = Color(0xFF9333EA);

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) return const Center(child: Text('Sin encuestas disponibles'));
    final sorted = List<Map<String, dynamic>>.from(surveys)
      ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
    final scores = sorted.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);

    // Per-item means (Q1-Q9, score 0-3)
    final itemMeans = <int, double>{};
    for (var q = 1; q <= 9; q++) {
      double total = 0; int n = 0;
      for (final s in sorted) {
        final r = (s['responses'] as List? ?? []).cast<Map<String, dynamic>>();
        final match = r.where((x) => (x['question_id'] as int?) == q);
        if (match.isNotEmpty) { total += (match.first['answer_value'] as int? ?? 0); n++; }
      }
      itemMeans[q] = n == 0 ? 0 : total / n;
    }

    const itemLabels = {
      1: 'Poco placer',      2: 'Decaimiento',     3: 'Sueño',
      4: 'Cansancio',        5: 'Apetito',          6: 'Autoestima',
      7: 'Concentración',    8: 'Movimiento',       9: 'Ideación',
    };

    final lollipopItems = itemLabels.entries.map((e) =>
      (label: e.value, value: itemMeans[e.key] ?? 0)).toList();

    // Item 9 alert: count surveys where q9 > 0
    final item9Alert = sorted.where((s) {
      final r = (s['responses'] as List? ?? []).cast<Map<String, dynamic>>();
      final q9 = r.where((x) => (x['question_id'] as int?) == 9);
      return q9.isNotEmpty && (q9.first['answer_value'] as int? ?? 0) > 0;
    }).length;

    final timelineSpots = [for (var i = 0; i < scores.length; i++) FlSpot(i.toDouble(), scores[i].toDouble())];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'PHQ-9 — Cuestionario de Salud del Paciente',
        subtitle: 'Gravedad de la depresión (0–27 puntos)',
        icon: Icons.mood_bad_outlined,
        color: _color,
      ),
      const Gap(16),
      MetricCardGroup(cards: buildScoredMetricCards(
        mean: stats.mean, mode: stats.mode, stdDev: stats.stdDev, count: stats.count, color: _color,
      )),
      const Gap(16),
      KpiAlertCard(
        label: 'Ítem 9 — Ideación suicida',
        value: '$item9Alert encuesta${item9Alert == 1 ? '' : 's'}',
        description: item9Alert == 0
            ? 'Ninguna encuesta reporta ideación suicida'
            : 'Encuestas con puntaje > 0 en Ítem 9 — Requiere atención',
        isAlert: item9Alert > 0,
      ),
      const Gap(12),
      ChartCard(
        title: 'Puntaje medio por ítem (0–3)',
        boundaryKey: k1,
        height: 300,
        chart: LollipopChart(items: lollipopItems, maxValue: 3, color: _color),
      ),
      const Gap(12),
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
          maxY: 27,
        ),
      ),
    ]);
  }
}
