import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Lollipop chart — thin bar + dot for each item. Ideal for PHQ-9 item scores.
class LollipopChart extends StatelessWidget {
  final List<({String label, double value})> items;
  final double maxValue;
  final Color color;

  const LollipopChart({
    super.key,
    required this.items,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Sin datos', style: TextStyle(color: Color(0xFF9CA3AF))));
    }
    return LayoutBuilder(builder: (_, constraints) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.map((item) {
          final fraction = maxValue == 0 ? 0.0 : (item.value / maxValue).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              SizedBox(
                width: 90,
                child: Text(
                  item.label,
                  style: const TextStyle(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(8),
              Expanded(
                child: Stack(alignment: Alignment.centerLeft, children: [
                  Container(
                    height: 2,
                    width: double.infinity,
                    color: color.withValues(alpha: 0.12),
                  ),
                  FractionallySizedBox(
                    widthFactor: fraction,
                    child: Stack(alignment: Alignment.centerRight, children: [
                      Container(height: 2, color: color),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
              const Gap(8),
              SizedBox(
                width: 24,
                child: Text(
                  item.value.toStringAsFixed(1),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                  textAlign: TextAlign.right,
                ),
              ),
            ]),
          );
        }).toList(),
      );
    });
  }
}
