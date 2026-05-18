import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Two line series sharing the X axis but with independent Y ranges.
/// Used for SF-36 PCS vs MCS, or ICIQ-SF quantity vs QoL impact.
class DualAxisLineChart extends StatelessWidget {
  final List<FlSpot> series1;
  final List<FlSpot> series2;
  final double maxY1;
  final double maxY2;
  final Color color1;
  final Color color2;
  final String legend1;
  final String legend2;

  const DualAxisLineChart({
    super.key,
    required this.series1,
    required this.series2,
    required this.maxY1,
    required this.maxY2,
    required this.color1,
    required this.color2,
    required this.legend1,
    required this.legend2,
  });

  @override
  Widget build(BuildContext context) {
    // Normalize series2 to series1 scale
    final scale = maxY1 / (maxY2 == 0 ? 1 : maxY2);
    final series2Scaled = series2.map((s) => FlSpot(s.x, s.y * scale)).toList();

    return Column(children: [
      Expanded(
        child: LineChart(LineChartData(
          maxY: maxY1,
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: series1,
              isCurved: true,
              color: color1,
              barWidth: 2.5,
              dotData: FlDotData(show: series1.length <= 10),
            ),
            LineChartBarData(
              spots: series2Scaled,
              isCurved: true,
              color: color2,
              barWidth: 2.5,
              dashArray: [6, 3],
              dotData: FlDotData(show: series2.length <= 10),
            ),
          ],
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 34)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Text('#${v.toInt() + 1}', style: const TextStyle(fontSize: 9)),
              ),
            ),
          ),
        )),
      ),
      const Gap(6),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _legend(color1, legend1, dashed: false),
        const Gap(16),
        _legend(color2, legend2, dashed: true),
      ]),
    ]);
  }

  Widget _legend(Color c, String label, {required bool dashed}) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 20, height: 2.5,
        color: dashed ? null : c,
        decoration: dashed ? BoxDecoration(
          gradient: LinearGradient(colors: [c, Colors.transparent, c, Colors.transparent]),
        ) : null,
      ),
      const Gap(5),
      Text(label, style: const TextStyle(fontSize: 11)),
    ]);
  }
}
