import 'package:flutter/material.dart';
import 'package:ssapp/utils/theme.dart';

/// A welcome card widget for the dashboard
class WelcomeCard extends StatelessWidget {
  final String userName;
  final String subtitle;

  const WelcomeCard({
    super.key,
    required this.userName,
    this.subtitle = 'Bienvenido al sistema de evaluación BDI-II',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, $userName!',
            style: context.textStyles.headlineMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: context.textStyles.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
