import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/utils/theme.dart';

class RecommendationsCard extends StatelessWidget {
  final String level;
  final String recommendation;

  const RecommendationsCard({super.key, required this.level, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LightModeColors.lightSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LightModeColors.lightSecondary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(material.Icons.lightbulb_outline, color: LightModeColors.lightSecondary, size: 28),
          const Gap(12),
          const Text('Recomendaciones').semiBold().large(),
        ]),
        const Gap(16),
        Text(recommendation, style: const TextStyle(fontSize: 15, height: 1.6)),
        const Gap(16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: LightModeColors.lightError.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: LightModeColors.lightError.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            Icon(material.Icons.warning_amber, size: 20, color: LightModeColors.lightError),
            const Gap(12),
            Expanded(
              child: Text(
                'Nota: Esta evaluación no sustituye un diagnóstico profesional. '
                'Consulte con un especialista en salud mental.',
                style: TextStyle(fontSize: 13, color: LightModeColors.lightError, height: 1.4),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
