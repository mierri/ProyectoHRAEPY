import 'package:fl_chart/fl_chart.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class LegendItem {
  final String label;
  final Color color;
  final String? value;

  const LegendItem({required this.label, required this.color, this.value});
}

class SeverityPieChart extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final List<LegendItem> legend;
  final double centerSpaceRadius;

  const SeverityPieChart({
    super.key,
    required this.sections,
    required this.legend,
    required this.centerSpaceRadius,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 420;
        final chart = SizedBox(
          height: 260,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: centerSpaceRadius,
            ),
          ),
        );

        final legendWidget = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: legend
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: item.color.withValues(alpha: 0.35)),
                    borderRadius: BorderRadius.circular(999),
                    color: item.color.withValues(alpha: 0.08),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Gap(6),
                      Text('${item.label}${item.value == null ? '' : ' (${item.value})'}'),
                    ],
                  ),
                ),
              )
              .toList(),
        );

        if (isNarrow) {
          return Column(
            children: [
              chart,
              const Gap(12),
              legendWidget,
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 3, child: chart),
            const Gap(12),
            Expanded(flex: 2, child: legendWidget),
          ],
        );
      },
    );
  }
}
