import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TimelineLineChart extends StatelessWidget {
  final List<LineChartBarData> series;
  final double maxY;
  final List<String>? xLabels;

  const TimelineLineChart({
    super.key,
    required this.series,
    required this.maxY,
    this.xLabels,
  });

  @override
  Widget build(BuildContext context) {
    Widget bottomTitles(double value, TitleMeta meta) {
      final labels = xLabels;
      if (labels == null || labels.isEmpty) {
        return Text('#${value.toInt() + 1}', style: const TextStyle(fontSize: 10));
      }
      final idx = value.toInt();
      if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
      return Text(labels[idx], style: const TextStyle(fontSize: 10));
    }

    return LineChart(
      LineChartData(
        maxY: maxY,
        lineBarsData: series,
        minX: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY <= 5 ? 1 : (maxY / 5),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: bottomTitles),
          ),
        ),
      ),
    );
  }
}
