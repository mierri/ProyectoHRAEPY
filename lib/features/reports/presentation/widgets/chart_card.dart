import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Wraps a chart in a titled card with a [RepaintBoundary] keyed by [boundaryKey].
/// The PDF generator uses that key to capture the chart as a PNG image.
class ChartCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final GlobalKey boundaryKey;
  final double height;

  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    required this.boundaryKey,
    this.height = 260,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const Gap(12),
          RepaintBoundary(
            key: boundaryKey,
            child: SizedBox(height: height, child: chart),
          ),
        ],
      ),
    );
  }
}
