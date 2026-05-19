import 'package:shadcn_flutter/shadcn_flutter.dart';

class ScaleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;

  const ScaleItem({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Center(child: Icon(icon, color: color, size: 26, fill: 1)),
        ),
        const Gap(12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 14)),
          const Gap(2),
          Text(description, style: const TextStyle(fontSize: 12, height: 1.3)),
        ])),
      ]),
    );
  }
}
