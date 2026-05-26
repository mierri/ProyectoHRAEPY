import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/data/investigation_repository.dart';

class InvestigationReviewStep extends StatelessWidget {
  final String name;
  final String consent;
  final List<int> selectedSurveyTypeIds;
  final List<String> consentCheckboxes;

  const InvestigationReviewStep({
    super.key,
    required this.name,
    required this.consent,
    required this.selectedSurveyTypeIds,
    this.consentCheckboxes = const [],
  });

  @override
  Widget build(BuildContext context) {
    final surveyNames = selectedSurveyTypeIds
        .map((id) => InvestigationService.surveyTypes[id] ?? 'Tipo $id')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Resumen').semiBold(),
                const Gap(10),
                Text(name).semiBold().large(),
                const Gap(8),
                Text('Instrumentos: ${selectedSurveyTypeIds.length}').small().muted(),
                const Gap(8),
                if (surveyNames.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final survey in surveyNames)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.muted,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(survey).small(),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const Gap(12),
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Consentimiento').semiBold(),
                const Gap(8),
                Text(
                  consent.trim().isEmpty ? 'Sin consentimiento registrado.' : consent,
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                ).small().muted(),
              ],
            ),
          ),
        ),
        if (consentCheckboxes.isNotEmpty) ...[
          const Gap(12),
          SurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Checkboxes de consentimiento').semiBold(),
                  const Gap(8),
                  for (final label in consentCheckboxes) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(material.Icons.check_box_outline_blank, size: 16,
                            color: Theme.of(context).colorScheme.mutedForeground),
                        const Gap(8),
                        Expanded(child: Text(label).small().muted()),
                      ],
                    ),
                    const Gap(6),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
