import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/report_models.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/severity_pie_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/stat_bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/timeline_line_chart.dart';

class BdiReportSection extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  final BasicStats stats;
  final LevelDistribution distribution;
  final String title;

  const BdiReportSection({
    super.key,
    required this.surveys,
    required this.stats,
    required this.distribution,
    this.title = 'Reporte',
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<Map<String, dynamic>>.from(surveys)
      ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
    final timelineScores = sorted
        .map(SurveyStatsCalculator.calculateSurveyScore)
        .map((e) => e.toDouble())
        .toList();
    final maxTimeline = timelineScores.isEmpty
        ? 1.0
        : timelineScores.reduce((a, b) => a > b ? a : b);

    final bars = <BarChartGroupData>[];
    final labels = <String>[];
    var index = 0;
    distribution.counts.forEach((label, value) {
      labels.add(label);
      bars.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(toY: value.toDouble(), width: 18),
          ],
        ),
      );
      index++;
    });

    final maxCount = distribution.counts.values.isEmpty
        ? 1.0
        : distribution.counts.values.reduce((a, b) => a > b ? a : b).toDouble();

    final pieSections = distribution.counts.entries
        .where((e) => e.value > 0)
        .map(
          (e) => PieChartSectionData(
            value: e.value.toDouble(),
            title: '${distribution.pct(e.key).toStringAsFixed(0)}%',
            radius: 55,
          ),
        )
        .toList();

    final pieLegend = distribution.counts.entries
        .map(
          (e) => LegendItem(
            label: e.key,
            color: const Color(0xFF6B7280),
            value: e.value.toString(),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title).semiBold().xLarge(),
        const Gap(12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(label: 'Media', value: stats.mean.toStringAsFixed(1)),
            _MetricCard(label: 'Mediana', value: stats.median.toStringAsFixed(1)),
            _MetricCard(label: 'Moda', value: stats.mode.toStringAsFixed(0)),
            _MetricCard(label: 'Desv. Est.', value: stats.stdDev.toStringAsFixed(2)),
          ],
        ),
        const Gap(16),
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Distribución por nivel').semiBold(),
                const Gap(12),
                SizedBox(
                  height: 260,
                  child: StatBarChart(
                    groups: bars,
                    maxY: maxCount + 1,
                    bottomLabels: labels,
                    leftAxisLabel: 'N',
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(16),
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tendencia temporal').semiBold(),
                const Gap(12),
                SizedBox(
                  height: 260,
                  child: TimelineLineChart(
                    series: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < timelineScores.length; i++)
                            FlSpot(i.toDouble(), timelineScores[i]),
                        ],
                        isCurved: true,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                    maxY: maxTimeline + 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(16),
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Proporción por nivel').semiBold(),
                const Gap(12),
                SizedBox(
                  height: 320,
                  child: SeverityPieChart(
                    sections: pieSections,
                    legend: pieLegend,
                    centerSpaceRadius: 36,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 130),
      child: SurfaceCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label).small().muted(),
              const Gap(4),
              Text(value).semiBold().large(),
            ],
          ),
        ),
      ),
    );
  }
}
