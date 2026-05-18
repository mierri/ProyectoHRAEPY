import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class DoughnutChart extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final List<({String label, Color color, String? value})> legend;
  final double holeRadius;

  const DoughnutChart({
    super.key,
    required this.sections,
    required this.legend,
    this.holeRadius = 60,
  });

  @override
  Widget build(BuildContext context) {
    final chart = SizedBox(
      height: 220,
      child: PieChart(PieChartData(
        sections: sections,
        centerSpaceRadius: holeRadius,
        sectionsSpace: 2,
      )),
    );
    final legendW = Wrap(
      spacing: 8,
      runSpacing: 6,
      children: legend.map((item) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: item.color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(999),
          color: item.color.withValues(alpha: 0.08),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 9, height: 9,
            decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
          ),
          const Gap(5),
          Text(
            item.value != null ? '${item.label} (${item.value})' : item.label,
            style: const TextStyle(fontSize: 11),
          ),
        ]),
      )).toList(),
    );
    return LayoutBuilder(builder: (_, constraints) {
      if (constraints.maxWidth < 400) {
        return Column(children: [chart, const Gap(10), legendW]);
      }
      return Row(children: [
        Expanded(flex: 3, child: chart),
        const Gap(8),
        Expanded(flex: 2, child: legendW),
      ]);
    });
  }
}
