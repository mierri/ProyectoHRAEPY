import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Horizontal bar chart. Built with Flutter primitives (not fl_chart),
/// making it easy to show long labels on the left side.
class HorizontalBarChart extends StatelessWidget {
  final List<({String label, double value})> items;
  final double maxValue;
  final Color color;
  final String? valueUnit;

  const HorizontalBarChart({
    super.key,
    required this.items,
    required this.maxValue,
    required this.color,
    this.valueUnit,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Sin datos', style: TextStyle(color: Color(0xFF9CA3AF))));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items.map((item) {
        final fraction = maxValue == 0 ? 0.0 : (item.value / maxValue).clamp(0.0, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            SizedBox(
              width: 100,
              child: Text(
                item.label,
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Gap(8),
            Expanded(
              child: Stack(children: [
                Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ]),
            ),
            const Gap(6),
            SizedBox(
              width: 38,
              child: Text(
                valueUnit != null
                    ? '${item.value.toStringAsFixed(1)}$valueUnit'
                    : item.value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ]),
        );
      }).toList(),
    );
  }
}
