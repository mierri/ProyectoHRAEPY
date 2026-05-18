import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ReportRadarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final double maxValue;
  final Color color;
  final List<double>? compareValues;
  final Color compareColor;

  const ReportRadarChart({
    super.key,
    required this.labels,
    required this.values,
    required this.maxValue,
    required this.color,
    this.compareValues,
    this.compareColor = const Color(0xFF94A3B8),
  });

  @override
  Widget build(BuildContext context) {
    final dataSets = [
      RadarDataSet(
        dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
        fillColor: color.withValues(alpha: 0.2),
        borderColor: color,
        borderWidth: 2,
        entryRadius: 3,
      ),
      if (compareValues != null)
        RadarDataSet(
          dataEntries: compareValues!.map((v) => RadarEntry(value: v)).toList(),
          fillColor: compareColor.withValues(alpha: 0.1),
          borderColor: compareColor,
          borderWidth: 1.5,
          entryRadius: 2,
        ),
    ];

    return RadarChart(
      RadarChartData(
        dataSets: dataSets,
        radarShape: RadarShape.polygon,
        radarBackgroundColor: Colors.transparent,
        radarBorderData: BorderSide(color: const Color(0xFFE5E7EB)),
        gridBorderData: BorderSide(color: const Color(0xFFF3F4F6), width: 1),
        tickCount: 5,
        ticksTextStyle: const TextStyle(fontSize: 8, color: Color(0xFF9CA3AF)),
        getTitle: (index, angle) => RadarChartTitle(
          text: index < labels.length ? labels[index] : '',
          angle: 0,
        ),
        titleTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        titlePositionPercentageOffset: 0.18,
      ),
    );
  }
}
