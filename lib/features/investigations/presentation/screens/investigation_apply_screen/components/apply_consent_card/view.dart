import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/services/tts/survey_tts_text_builder.dart';
import 'package:ssapp/shared/widgets/tts/tts_button.dart';

class ApplyConsentCard extends StatelessWidget {
  final String consentText;

  const ApplyConsentCard({
    super.key,
    required this.consentText,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(material.Icons.fact_check_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
                const Gap(8),
                Expanded(
                  child: Text('Consentimiento de la investigacion').semiBold(),
                ),
                TtsButton(
                  text: SurveyTtsTextBuilder.investigationConsent(
                    investigationName: 'Investigación',
                    consentText: consentText,
                  ),
                ),
              ],
            ),
            const Gap(12),
            Text(
              consentText.trim().isEmpty
                  ? 'Esta investigacion aun no tiene consentimiento registrado.'
                  : consentText,
              style: const TextStyle(height: 1.5),
            ).small().muted(),
          ],
        ),
      ),
    );
  }
}


