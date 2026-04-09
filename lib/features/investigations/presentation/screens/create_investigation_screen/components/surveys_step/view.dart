import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/data/investigation_repository.dart';
import 'package:ssapp/features/investigations/presentation/screens/create_investigation_screen/components/surveys_step/widgets/widgets.dart';
import 'package:ssapp/shared/widgets/section_empty_state.dart';

class InvestigationSurveysStep extends StatelessWidget {
  final List<int> selectedSurveyTypeIds;
  final ValueChanged<int> onToggleSurvey;

  const InvestigationSurveysStep({
    super.key,
    required this.selectedSurveyTypeIds,
    required this.onToggleSurvey,
  });

  @override
  Widget build(BuildContext context) {
    final surveyEntries = InvestigationService.surveyTypes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (surveyEntries.isEmpty) {
      return const SectionEmptyState(
        icon: Icons.checklist_rtl,
        title: 'No hay instrumentos disponibles',
        subtitle: 'Agrega tipos de encuesta para continuar.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seleccionados: ${selectedSurveyTypeIds.length}').small().muted(),
        const Gap(10),
        for (final survey in surveyEntries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurveyTile(
              name: survey.value,
              selected: selectedSurveyTypeIds.contains(survey.key),
              onTap: () => onToggleSurvey(survey.key),
            ),
          ),
      ],
    );
  }
}

