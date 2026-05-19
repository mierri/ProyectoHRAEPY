import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/domain/survey_type_config.dart';

class ConsentInfoCard extends StatelessWidget {
  final String? surveyType;

  const ConsentInfoCard({super.key, this.surveyType});

  @override
  Widget build(BuildContext context) {
    final color = SurveyTypeConfig.colorFor(surveyType);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(material.Icons.info_outline, color: color),
            const Gap(8),
            const Text('Información Importante').semiBold(),
          ]),
          const Gap(16),
          Text(SurveyTypeConfig.descriptionFor(surveyType)).muted(),
          const Gap(16),
          const Text(
            '• Su participación es completamente voluntaria\n'
            '• Toda la información será tratada con confidencialidad\n'
            '• Los resultados serán utilizados para mejorar la atención psicológica',
          ).small().muted(),
        ]),
      ),
    );
  }
}
