import 'package:shadcn_flutter/shadcn_flutter.dart';

class SummaryValue extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const SummaryValue({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: color),
                const Gap(4),
                Flexible(
                  child: Text(label, overflow: TextOverflow.ellipsis).xSmall(),
                ),
              ],
            ),
            const Gap(3),
            Text(value, overflow: TextOverflow.ellipsis).semiBold(),
          ],
        ),
      ),
    );
  }
}

