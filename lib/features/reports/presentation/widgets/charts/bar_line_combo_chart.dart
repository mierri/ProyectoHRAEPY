import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Bar chart with an overlaid line series. E.g. ICIQ-SF loss quantity (bars) + QoL impact (line).
class BarLineComboChart extends StatelessWidget {
  final List<BarChartGroupData> bars;
  final List<FlSpot> lineSpots;
  final double maxBarY;
  final double maxLineY;
  final Color barColor;
  final Color lineColor;
  final List<String> bottomLabels;
  final String barLegend;
  final String lineLegend;

  const BarLineComboChart({
    super.key,
    required this.bars,
    required this.lineSpots,
    required this.maxBarY,
    required this.maxLineY,
    required this.barColor,
    required this.lineColor,
    required this.bottomLabels,
    required this.barLegend,
    required this.lineLegend,
  });

  @override
  Widget build(BuildContext context) {
    // Normalize line to bar scale
    final scale = maxBarY / (maxLineY == 0 ? 1 : maxLineY);
    final scaledLine = lineSpots.map((s) => FlSpot(s.x, s.y * scale)).toList();

    return Column(children: [
      Expanded(
        child: BarChart(BarChartData(
          maxY: maxBarY * 1.1,
          barGroups: bars,
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= bottomLabels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(bottomLabels[idx], style: const TextStyle(fontSize: 9)),
                  );
                },
              ),
            ),
          ),
        )),
      ),
      const Gap(6),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 12, height: 12, color: barColor),
        const Gap(4),
        Text(barLegend, style: const TextStyle(fontSize: 11)),
        const Gap(16),
        Container(width: 20, height: 2.5, color: lineColor),
        const Gap(4),
        Text(lineLegend, style: const TextStyle(fontSize: 11)),
      ]),
    ]);
  }
}
