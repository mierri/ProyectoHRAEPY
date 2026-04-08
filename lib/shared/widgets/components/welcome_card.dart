import 'package:flutter/material.dart' as material show BoxDecoration, LinearGradient, Alignment, Colors, Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/utils/theme.dart';

/// A welcome card widget for the dashboard
class WelcomeCard extends StatelessWidget {
  final String userName;
  final String subtitle;
  /// When true, shows a side icon for wider screens
  final bool wide;

  const WelcomeCard({
    super.key,
    required this.userName,
    this.subtitle = 'Bienvenido al sistema de evaluación BDI-II',
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(wide ? 32.0 : 24.0),
      decoration: material.BoxDecoration(
        gradient: material.LinearGradient(
          colors: [LightModeColors.lightPrimary, LightModeColors.lightSecondary],
          begin: material.Alignment.topLeft,
          end: material.Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: wide
          ? Row(
              children: [
                Expanded(child: _textContent()),
                const Gap(24),
                Icon(
                  material.Icons.health_and_safety,
                  size: 72,
                  color: material.Colors.white.withValues(alpha: 0.25),
                ),
              ],
            )
          : _textContent(),
    );
  }

  Widget _textContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Hola, $userName!',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: material.Colors.white,
          ),
        ),
        const Gap(8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: material.Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
