import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class StatBarChart extends StatelessWidget {
  final List<BarChartGroupData> groups;
  final double maxY;
  final List<String> bottomLabels;
  final String? leftAxisLabel;

  const StatBarChart({
    super.key,
    required this.groups,
    required this.maxY,
    required this.bottomLabels,
    this.leftAxisLabel,
  });

  @override
  Widget build(BuildContext context) {
    Widget bottomTitles(double value, TitleMeta meta) {
      final idx = value.toInt();
      if (idx < 0 || idx >= bottomLabels.length) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(bottomLabels[idx], style: const TextStyle(fontSize: 11)),
      );
    }

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: groups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY <= 5 ? 1 : (maxY / 5),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            axisNameWidget: leftAxisLabel == null
                ? null
                : Text(leftAxisLabel!, style: const TextStyle(fontSize: 11)),
            sideTitles: const SideTitles(showTitles: true, reservedSize: 34),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: bottomTitles),
          ),
        ),
      ),
    );
  }
}
