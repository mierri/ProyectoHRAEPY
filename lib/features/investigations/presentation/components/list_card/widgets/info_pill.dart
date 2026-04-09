import 'package:shadcn_flutter/shadcn_flutter.dart';

class InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoPill({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.muted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Theme.of(context).colorScheme.mutedForeground),
          const Gap(4),
          Text(label).small(),
        ],
      ),
    );
  }
}

