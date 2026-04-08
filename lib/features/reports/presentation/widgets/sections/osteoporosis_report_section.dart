import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/models/osteoporosis_report_model.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/stat_bar_chart.dart';

class OsteoporosisReportSection extends StatelessWidget {
  final OsteoporosisCompleteReport report;

  const OsteoporosisReportSection({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final ageLabels = report.ageGroupData.map((e) => e.ageGroup).toList();
    final ageBars = <BarChartGroupData>[];
    var idx = 0;
    for (final row in report.ageGroupData) {
      ageBars.add(
        BarChartGroupData(
          x: idx,
          barRods: [
            BarChartRodData(
              toY: row.highRiskPercentage,
              width: 14,
              color: const Color(0xFFEF4444),
            ),
          ],
        ),
      );
      idx++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Osteoporosis').semiBold().xLarge(),
        const Gap(12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricChip(label: 'Total', value: report.overview.totalPatients.toString()),
            _MetricChip(label: 'Riesgo alto', value: report.overview.highRiskCount.toString()),
            _MetricChip(label: 'Riesgo bajo', value: report.overview.lowRiskCount.toString()),
            _MetricChip(label: 'IMC promedio', value: report.overview.averageBMI.toStringAsFixed(1)),
          ],
        ),
        const Gap(16),
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Riesgo alto por grupo etario (%)').semiBold(),
                const Gap(12),
                SizedBox(
                  height: 260,
                  child: StatBarChart(
                    groups: ageBars,
                    maxY: 100,
                    bottomLabels: ageLabels,
                    leftAxisLabel: '%',
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

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
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
    );
  }
}
