import 'package:shadcn_flutter/shadcn_flutter.dart';

class MetricCardData {
  final IconData icon;
  final String label;
  final String value;
  final String? hint;
  final Color color;

  const MetricCardData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.hint,
  });
}

class MetricCardGroup extends StatelessWidget {
  final List<MetricCardData> cards;

  const MetricCardGroup({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0) {
          return const SizedBox.shrink();
        }
        final isNarrow = constraints.maxWidth < 520;
        if (isNarrow) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (_, i) => _MetricCard(data: cards[i]),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              Expanded(child: _MetricCard(data: cards[i])),
              if (i < cards.length - 1) const Gap(10),
            ],
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final MetricCardData data;

  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      backgroundColor: data.color.withValues(alpha: 0.05),
      borderColor: data.color.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(data.icon, color: data.color, size: 18),
              const Gap(6),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: data.color,
              height: 1.0,
            ),
          ),
          if (data.hint != null) ...[
            const Gap(4),
            Text(
              data.hint!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: data.color.withValues(alpha: 0.75),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────────
// Common metric card builders for scored surveys
// ───────────────────────────────────────────────────────────────────────────────

List<MetricCardData> buildScoredMetricCards({
  required double mean,
  required double mode,
  required double stdDev,
  required int count,
  Color color = const Color(0xFF6B7FBD),
}) {
  return [
    MetricCardData(
      icon: Icons.show_chart,
      label: 'Media',
      value: mean.toStringAsFixed(1),
      color: color,
    ),
    MetricCardData(
      icon: Icons.bar_chart,
      label: 'Moda',
      value: mode.toStringAsFixed(0),
      color: color,
    ),
    MetricCardData(
      icon: Icons.scatter_plot,
      label: 'Desv. est.',
      value: stdDev.toStringAsFixed(1),
      color: color,
    ),
    MetricCardData(
      icon: Icons.assignment_turned_in,
      label: 'Encuestas',
      value: '$count',
      color: color,
    ),
  ];
}
