import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/types/assist/domain/assist_questions.dart';
import 'package:ssapp/shared/utils/theme.dart';

class AssistResultsCard extends StatelessWidget {
  final AssistComputedResults results;

  const AssistResultsCard({super.key, required this.results});

  Color _riskColor(String level) => switch (level.toLowerCase()) {
        'bajo'     => LightModeColors.lightTertiary,
        'moderado' => const Color(0xFFF59E0B),
        'alto'     => LightModeColors.lightError,
        _          => LightModeColors.lightSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final ordered = AssistQuestions.substances
        .where((s) => results.resultsBySubstance.containsKey(s.id))
        .map((s) => results.resultsBySubstance[s.id]!)
        .toList();

    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(material.Icons.medication_outlined, color: LightModeColors.lightSecondary),
            const Gap(10),
            Expanded(child: Text('Resultados OMS-ASSIST V3.0').semiBold().large()),
          ]),
          const Gap(14),
          if (!results.hasAnyLifetimeUse)
            _infoBox(LightModeColors.lightTertiary,
                'No se reporta consumo de sustancias alguna vez en la vida. Recomendación: Sin intervención.'),
          ...ordered.map((item) {
            final color = _riskColor(item.riskLevel);
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(item.substance.label, style: const TextStyle(fontWeight: FontWeight.w600))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
                    child: Text(item.riskLevel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const Gap(6),
                Text('Puntaje: ${item.score}'),
                const Gap(2),
                Text('Intervención: ${item.recommendation}'),
              ]),
            );
          }),
          if (results.hasInjectedInLast3Months)
            _infoBox(LightModeColors.lightError,
                'Advertencia: uso por vía inyectada en los últimos 3 meses. Se recomienda valoración clínica prioritaria.',
                icon: material.Icons.warning_amber),
        ]),
      ),
    );
  }

  Widget _infoBox(Color color, String text, {IconData? icon}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: icon == null
          ? Text(text)
          : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, color: color, size: 20),
              const Gap(10),
              Expanded(child: Text(text, style: const TextStyle(height: 1.5))),
            ]),
    );
  }
}
