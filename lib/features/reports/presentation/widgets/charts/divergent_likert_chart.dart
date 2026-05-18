import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Divergent Likert-style chart — items shown as bars extending from a center axis.
/// Left = negative/problem responses, right = positive/normal responses.
class DivergentLikertChart extends StatelessWidget {
  final List<({String label, int positive, int negative, int total})> items;
  final Color positiveColor;
  final Color negativeColor;
  final String positiveLegend;
  final String negativeLegend;

  const DivergentLikertChart({
    super.key,
    required this.items,
    this.positiveColor = const Color(0xFF16A34A),
    this.negativeColor = const Color(0xFFDC2626),
    this.positiveLegend = 'Normal',
    this.negativeLegend = 'Problema',
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _dot(negativeColor), const Gap(4),
        Text(negativeLegend, style: const TextStyle(fontSize: 11)),
        const Gap(16),
        _dot(positiveColor), const Gap(4),
        Text(positiveLegend, style: const TextStyle(fontSize: 11)),
      ]),
      const Gap(8),
      ...items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          SizedBox(width: 80,
            child: Text(item.label, style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.right, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          const Gap(6),
          Expanded(child: LayoutBuilder(builder: (_, c) {
            final half = c.maxWidth / 2;
            final total = item.total == 0 ? 1 : item.total;
            final negFrac = (item.negative / total).clamp(0.0, 1.0);
            final posFrac = (item.positive / total).clamp(0.0, 1.0);
            return Row(children: [
              SizedBox(width: half, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                  width: half * negFrac, height: 16, color: negativeColor,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Align(alignment: Alignment.centerLeft,
                    child: Text('${item.negative}', style: const TextStyle(fontSize: 8, color: Colors.white))),
                ),
              ])),
              Container(width: 1, height: 20, color: const Color(0xFFD1D5DB)),
              SizedBox(width: half, child: Row(children: [
                Container(
                  width: half * posFrac, height: 16, color: positiveColor,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Align(alignment: Alignment.centerRight,
                    child: Text('${item.positive}', style: const TextStyle(fontSize: 8, color: Colors.white))),
                ),
              ])),
            ]);
          })),
        ]),
      )),
    ]);
  }

  Widget _dot(Color c) => Container(
    width: 10, height: 10,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}
