import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Histogram — bar chart with automatic binning of a list of numeric values.
class HistogramChart extends StatelessWidget {
  final List<double> values;
  final int binCount;
  final Color color;
  final String? xLabel;

  const HistogramChart({
    super.key,
    required this.values,
    required this.color,
    this.binCount = 8,
    this.xLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const Center(child: Text('Sin datos', style: TextStyle(color: Color(0xFF9CA3AF))));
    }

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    final binWidth = range == 0 ? 1.0 : range / binCount;

    final counts = List<int>.filled(binCount, 0);
    for (final v in values) {
      final idx = range == 0 ? 0 : ((v - minVal) / binWidth).floor().clamp(0, binCount - 1);
      counts[idx]++;
    }

    final maxCount = counts.reduce((a, b) => a > b ? a : b).toDouble();

    final groups = List.generate(binCount, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: counts[i].toDouble(),
            color: color.withValues(alpha: 0.8),
            width: 22,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });

    return BarChart(
      BarChartData(
        maxY: maxCount * 1.15,
        barGroups: groups,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          bottomTitles: AxisTitles(
            axisNameWidget: xLabel == null ? null : Text(xLabel!, style: const TextStyle(fontSize: 10)),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx % 2 != 0) return const SizedBox.shrink();
                final binStart = (minVal + idx * binWidth).round();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('$binStart', style: const TextStyle(fontSize: 9)),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
