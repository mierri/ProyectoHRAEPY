import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Area chart (filled line) — useful for visualizing cumulative burden over time.
class AreaChart extends StatelessWidget {
  final List<FlSpot> spots;
  final double maxY;
  final Color color;
  final List<String>? xLabels;

  const AreaChart({
    super.key,
    required this.spots,
    required this.maxY,
    required this.color,
    this.xLabels,
  });

  @override
  Widget build(BuildContext context) {
    final barData = LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2.5,
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.18),
      ),
      dotData: FlDotData(show: spots.length <= 10),
    );

    return LineChart(
      LineChartData(
        maxY: maxY,
        minY: 0,
        lineBarsData: [barData],
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY <= 5 ? 1 : (maxY / 5).ceilToDouble(),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final labels = xLabels;
                if (labels == null) return Text('#${value.toInt() + 1}', style: const TextStyle(fontSize: 10));
                final idx = value.toInt();
                if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(labels[idx], style: const TextStyle(fontSize: 9)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
