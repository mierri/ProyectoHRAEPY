import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class StackedBarChart extends StatelessWidget {
  final List<BarChartGroupData> groups;
  final double maxY;
  final List<String> bottomLabels;
  final List<({String label, Color color})> legend;
  final bool percentageMode;

  const StackedBarChart({
    super.key,
    required this.groups,
    required this.maxY,
    required this.bottomLabels,
    required this.legend,
    this.percentageMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: percentageMode ? 100 : maxY,
              barGroups: groups,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: percentageMode ? 25 : (maxY / 4).ceilToDouble(),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 38,
                    getTitlesWidget: (v, _) => Text(
                      percentageMode ? '${v.toInt()}%' : '${v.toInt()}',
                      style: const TextStyle(fontSize: 9),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= bottomLabels.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(bottomLabels[idx], style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gap(8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: legend.map((item) => Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(2))),
            const Gap(4),
            Text(item.label, style: const TextStyle(fontSize: 11)),
          ])).toList(),
        ),
      ],
    );
  }
}
