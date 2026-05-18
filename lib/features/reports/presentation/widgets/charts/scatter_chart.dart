import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ThresholdLine {
  final double y;
  final Color color;
  final String label;
  const ThresholdLine({required this.y, required this.color, required this.label});
}

/// Scatter plot with optional horizontal threshold lines.
class ReportScatterChart extends StatelessWidget {
  final List<ScatterSpot> spots;
  final double maxX;
  final double maxY;
  final double minY;
  final String xLabel;
  final String yLabel;
  final List<ThresholdLine> thresholds;

  const ReportScatterChart({
    super.key,
    required this.spots,
    required this.maxX,
    required this.maxY,
    this.minY = 0,
    required this.xLabel,
    required this.yLabel,
    this.thresholds = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ScatterChart(
      ScatterChartData(
        scatterSpots: spots,
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            for (final t in thresholds) {
              if ((value - t.y).abs() < 0.01) {
                return FlLine(color: t.color, strokeWidth: 1.5, dashArray: [6, 4]);
              }
            }
            return FlLine(color: const Color(0xFFE5E7EB), strokeWidth: 0.5);
          },
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            axisNameWidget: Text(yLabel, style: const TextStyle(fontSize: 10)),
            sideTitles: const SideTitles(showTitles: true, reservedSize: 34),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: Text(xLabel, style: const TextStyle(fontSize: 10)),
            sideTitles: const SideTitles(showTitles: true, reservedSize: 22),
          ),
        ),
      ),
    );
  }
}
