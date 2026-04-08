import 'package:flutter/material.dart';
import 'package:ssapp/shared/utils/theme.dart';

/// Reusable app header component with icon and title
class AppHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const AppHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: AppSpacing.lg),
        Text(
          title,
          style: context.textStyles.displaySmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          SizedBox(height: AppSpacing.sm),
          Text(
            subtitle!,
            style: context.textStyles.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
