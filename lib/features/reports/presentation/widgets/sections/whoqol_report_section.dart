import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/report_models.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/line_timeline_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/radar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

class WhoqolReportSection extends StatelessWidget {
  final WhoqolReportData data;
  static final k1 = GlobalKey(debugLabel: 'whoqol_k1');
  static final k2 = GlobalKey(debugLabel: 'whoqol_k2');
  static final k3 = GlobalKey(debugLabel: 'whoqol_k3');
  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  const WhoqolReportSection({super.key, required this.data});

  static const _color = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final domains = [data.dom1, data.dom2, data.dom3, data.dom4];
    final radarValues = domains.map((d) => d.mean / d.maxPossible * 100).toList();
    const radarLabels = ['Salud Física', 'Salud Psicológica', 'Relaciones Sociales', 'Ambiente'];

    // Global timeline
    final maxTimeline = data.globalTimeline.isEmpty ? 100.0
        : data.globalTimeline.reduce((a, b) => a > b ? a : b) * 1.1;

    // Domain bar chart: current mean per domain
    final domainBars = <BarChartGroupData>[];
    for (var i = 0; i < domains.length; i++) {
      final d = domains[i];
      domainBars.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: d.mean / d.maxPossible * 100,
          color: _color.withValues(alpha: 0.75),
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ]));
    }
    const domainAbbrev = ['Física', 'Psicol.', 'Social', 'Ambiente'];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'WHOQOL-BREF — Calidad de Vida OMS',
        subtitle: '4 dominios de calidad de vida (puntaje 0–100%)',
        icon: Icons.favorite_outline,
        color: _color,
      ),
      const Gap(16),
      MetricCardGroup(cards: buildScoredMetricCards(
        mean: data.globalStats.mean,
        mode: data.globalStats.mode,
        stdDev: data.globalStats.stdDev,
        count: data.surveyCount,
        color: _color,
      )),
      const Gap(16),
      ChartCard(
        title: 'Perfil de calidad de vida por dominio',
        boundaryKey: k1,
        chart: ReportRadarChart(labels: radarLabels, values: radarValues, maxValue: 100, color: _color),
      ),
      const Gap(12),
      ChartCard(
        title: 'Puntuación media por dominio (% del máximo)',
        boundaryKey: k2,
        chart: ReportBarChart(
          groups: domainBars,
          maxY: 100,
          bottomLabels: domainAbbrev,
          leftLabel: '%',
        ),
      ),
      const Gap(12),
      ChartCard(
        title: 'Evolución del puntaje global',
        boundaryKey: k3,
        chart: LineTimelineChart(
          series: [LineChartBarData(
            spots: [for (var i = 0; i < data.globalTimeline.length; i++)
              FlSpot(i.toDouble(), data.globalTimeline[i])],
            isCurved: true,
            color: _color,
            barWidth: 2.5,
            dotData: FlDotData(show: data.globalTimeline.length <= 15),
          )],
          maxY: maxTimeline,
        ),
      ),
      const Gap(12),
      OutlinedContainer(
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(14),
        backgroundColor: _color.withValues(alpha: 0.05),
        borderColor: _color.withValues(alpha: 0.3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Interpretación por dominio', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const Gap(8),
          ...domains.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('${d.label}: ${SurveyStatsCalculator.whoqolDomainInterpretation(d)}',
                style: const TextStyle(fontSize: 12, height: 1.4)),
          )),
        ]),
      ),
    ]);
  }
}
