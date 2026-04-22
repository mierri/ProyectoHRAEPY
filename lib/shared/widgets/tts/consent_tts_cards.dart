import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/domain/survey_type_config.dart';
import 'package:ssapp/shared/services/tts/survey_tts_text_builder.dart';
import 'package:ssapp/shared/widgets/tts/tts_button.dart';

/// Card de consentimiento informado de encuesta con botón TTS.
/// Reemplaza al [ConsentInfoCard] existente añadiendo el botón de audio.
class ConsentInfoTtsCard extends StatelessWidget {
  final String? surveyType;

  const ConsentInfoTtsCard({super.key, this.surveyType});

  @override
  Widget build(BuildContext context) {
    final color = SurveyTypeConfig.colorFor(surveyType);
    final description = SurveyTypeConfig.descriptionFor(surveyType);
    final ttsText = SurveyTtsTextBuilder.consent(description);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(material.Icons.info_outline, color: color),
                const Gap(8),
                Expanded(
                  child: const Text('Información Importante').semiBold(),
                ),
                TtsButton(text: ttsText),
              ],
            ),
            const Gap(16),
            Text(description).muted(),
            const Gap(16),
            const Text(
              '• Su participación es completamente voluntaria\n'
                  '• Toda la información será tratada con confidencialidad\n'
                  '• Los resultados serán utilizados para mejorar la atención psicológica',
            ).small().muted(),
          ],
        ),
      ),
    );
  }
}

/// Card de consentimiento para investigaciones con TTS.
/// Se usa en [InvestigationConsentSection] y en el flujo de Apply.
class InvestigationConsentTtsCard extends StatelessWidget {
  final String investigationName;
  final String consentText;

  const InvestigationConsentTtsCard({
    super.key,
    required this.investigationName,
    required this.consentText,
  });

  @override
  Widget build(BuildContext context) {
    final ttsText = SurveyTtsTextBuilder.investigationConsent(
      investigationName: investigationName,
      consentText: consentText,
    );

    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(material.Icons.fact_check_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary),
                const Gap(8),
                Expanded(
                  child: const Text('Consentimiento informado').semiBold(),
                ),
                TtsButton(text: ttsText),
              ],
            ),
            const Gap(12),
            Text(
              consentText.trim().isEmpty
                  ? 'Esta investigación aún no tiene consentimiento registrado.'
                  : consentText,
              style: const TextStyle(height: 1.5),
            ).small().muted(),
          ],
        ),
      ),
    );
  }
}