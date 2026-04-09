import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/data/investigation_repository.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/features/surveys/domain/survey_type_config.dart';
import 'package:ssapp/shared/widgets/section_empty_state.dart';

class InvestigationSurveysSection extends StatelessWidget {
  final InvestigationModel investigation;

  const InvestigationSurveysSection({
    super.key,
    required this.investigation,
  });

  @override
  Widget build(BuildContext context) {
    final surveyTypes = investigation.surveyTypeIds.map((id) {
      final code = InvestigationService.surveyTypeToRouteCode[id] ?? 'bdi';
      return (
        id: id,
        name: InvestigationService.surveyTypes[id] ?? 'Tipo $id',
        description: SurveyTypeConfig.descriptionFor(code),
        itemCount: SurveyTypeConfig.itemCountFor(code),
      );
    }).toList();

    if (surveyTypes.isEmpty) {
      return const SectionEmptyState(
        icon: material.Icons.checklist_rtl,
        title: 'No hay instrumentos asignados',
        subtitle: 'Agrega encuestas para comenzar a recolectar datos.',
      );
    }

    return Column(
      children: [
        for (final survey in surveyTypes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedContainer(
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            Text(survey.name).semiBold(),
                            const Gap(2),
                            Text(survey.description).small().muted(),
                          ],
                        ),
                      ),
                      const Gap(10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('${survey.itemCount} ítems').small().semiBold(),
                      ),
                    ],
                  ),
                  const Gap(10),
                  Text('Instrumento incluido en esta investigacion').small().muted(),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

