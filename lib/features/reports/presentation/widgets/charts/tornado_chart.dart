import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Tornado / divergent bar chart — bars extend left and right from a center axis.
/// Useful for SF-36 physical vs mental components.
class TornadoChart extends StatelessWidget {
  final List<({String label, double leftValue, double rightValue})> items;
  final double maxValue;
  final Color leftColor;
  final Color rightColor;
  final String leftLegend;
  final String rightLegend;

  const TornadoChart({
    super.key,
    required this.items,
    required this.maxValue,
    required this.leftColor,
    required this.rightColor,
    required this.leftLegend,
    required this.rightLegend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _dot(leftColor), const Gap(4),
          Text(leftLegend, style: const TextStyle(fontSize: 11)),
          const Gap(16),
          _dot(rightColor), const Gap(4),
          Text(rightLegend, style: const TextStyle(fontSize: 11)),
        ]),
        const Gap(10),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            SizedBox(width: 80,
              child: Text(item.label, style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            const Gap(6),
            Expanded(child: LayoutBuilder(builder: (_, c) {
              if (c.maxWidth <= 0) {
                return const SizedBox.shrink();
              }
              final half = c.maxWidth / 2;
              final lFrac = maxValue == 0 ? 0.0 : (item.leftValue / maxValue).clamp(0.0, 1.0);
              final rFrac = maxValue == 0 ? 0.0 : (item.rightValue / maxValue).clamp(0.0, 1.0);
              return Row(children: [
                SizedBox(width: half, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Container(
                    width: half * lFrac, height: 16,
                    decoration: BoxDecoration(
                      color: leftColor,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                    ),
                  ),
                ])),
                Container(width: 1, height: 20, color: const Color(0xFFD1D5DB)),
                SizedBox(width: half, child: Row(children: [
                  Container(
                    width: half * rFrac, height: 16,
                    decoration: BoxDecoration(
                      color: rightColor,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                    ),
                  ),
                ])),
              ]);
            })),
          ]),
        )),
      ],
    );
  }

  Widget _dot(Color c) => Container(
    width: 10, height: 10,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}
