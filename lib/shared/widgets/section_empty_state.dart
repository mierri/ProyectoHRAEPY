import 'package:shadcn_flutter/shadcn_flutter.dart';

class SectionEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const SectionEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        child: Column(
          children: [
            Icon(icon, size: 36, color: Theme.of(context).colorScheme.mutedForeground),
            const Gap(8),
            Text(title, textAlign: TextAlign.center).semiBold(),
            const Gap(4),
            Text(subtitle, textAlign: TextAlign.center).small().muted(),
          ],
        ),
      ),
    );
  }
}

