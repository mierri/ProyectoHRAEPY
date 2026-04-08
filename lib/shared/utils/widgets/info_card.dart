import 'package:flutter/material.dart';
import 'package:ssapp/shared/utils/theme.dart';

/// Reusable info card widget
class InfoCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const InfoCard({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textStyles.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          ...items.map(
            (item) => Text(
              item,
              style: context.textStyles.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
