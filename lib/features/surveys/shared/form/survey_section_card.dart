import 'package:shadcn_flutter/shadcn_flutter.dart';

class SurveySectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const SurveySectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title).textLarge().bold(),
          if (subtitle != null) ...[
            const Gap(6),
            Text(subtitle!).muted(),
          ],
          const Gap(16),
          ...children,
        ],
      ),
    );
  }
}

