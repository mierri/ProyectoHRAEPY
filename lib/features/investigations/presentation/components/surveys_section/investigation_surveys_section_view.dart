import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/data/investigation_repository.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/shared/widgets/section_empty_state.dart';

class InvestigationSurveysSection extends StatelessWidget {
  final InvestigationModel investigation;

  const InvestigationSurveysSection({
    super.key,
    required this.investigation,
  });

  @override
  Widget build(BuildContext context) {
    final surveyNames = investigation.surveyTypeIds
        .map((id) => InvestigationService.surveyTypes[id] ?? 'Tipo $id')
        .toList();

    if (surveyNames.isEmpty) {
      return const SectionEmptyState(
        icon: material.Icons.checklist_rtl,
        title: 'No hay instrumentos asignados',
        subtitle: 'Agrega encuestas para comenzar a recolectar datos.',
      );
    }

    return Column(
      children: [
        for (final surveyName in surveyNames)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedContainer(
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.muted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      material.Icons.assignment,
                      size: 18,
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(surveyName).semiBold(),
                        const Gap(2),
                        const Text('Instrumento incluido en esta investigacion').small().muted(),
                      ],
                    ),
                  ),
                  Icon(
                    material.Icons.chevron_right,
                    color: Theme.of(context).colorScheme.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

