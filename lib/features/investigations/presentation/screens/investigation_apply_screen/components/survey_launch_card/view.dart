import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SurveyLaunchCard extends StatelessWidget {
  final String title;
  final String description;
  final int itemCount;
  final VoidCallback onTap;
  final bool enabled;

  const SurveyLaunchCard({
    super.key,
    required this.title,
    required this.description,
    required this.itemCount,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: SurfaceCard(
        child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.muted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(material.Icons.assignment, color: Theme.of(context).colorScheme.primary),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title).semiBold(),
                      const Gap(2),
                      Text(description, maxLines: 2, overflow: TextOverflow.ellipsis).small().muted(),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('$itemCount ítems').small().semiBold(),
                ),
                const Spacer(),
                PrimaryButton(
                  onPressed: enabled ? onTap : null,
                  child: const Text('Aplicar'),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}


