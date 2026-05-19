import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/types/assist/domain/assist_questions.dart';
import 'package:ssapp/features/surveys/presentation/survey_results/components/assist_results_card.dart';
import 'package:ssapp/features/surveys/presentation/survey_results/components/patient_info_card.dart';

/// Full scaffold for ASSIST V3.0 results — different layout than standard surveys.
class AssistResultView extends StatelessWidget {
  final String patientName;
  final DateTime createdAt;
  final String surveyTypeName;
  final AssistComputedResults results;
  final VoidCallback onBack;
  final VoidCallback onHome;

  const AssistResultView({
    super.key,
    required this.patientName,
    required this.createdAt,
    required this.surveyTypeName,
    required this.results,
    required this.onBack,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PatientInfoCard(patientName: patientName, createdAt: createdAt),
        const Gap(24),
        AssistResultsCard(results: results),
        const Gap(24),
        Row(children: [
          Expanded(child: OutlineButton(
            onPressed: onBack,
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(material.Icons.arrow_back, size: 20), Gap(8), Text('Volver'),
            ]),
          )),
          const Gap(12),
          Expanded(child: PrimaryButton(
            onPressed: onHome,
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(material.Icons.home, size: 20), Gap(8), Text('Inicio'),
            ]),
          )),
        ]),
      ]),
    );
  }
}
