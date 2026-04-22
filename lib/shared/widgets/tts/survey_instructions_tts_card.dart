import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/domain/survey_type_config.dart';
import 'package:ssapp/shared/services/tts/survey_tts_text_builder.dart';
import 'package:ssapp/shared/widgets/tts/tts_button.dart';

/// Card de instrucciones de encuesta con botón de escucha.
/// Se muestra dentro del diálogo de instrucciones en [ConsentFormScreen].
///
/// Sustituye o complementa el bloque de instrucciones existente
/// añadiendo el botón [TtsButton] sin romper el layout.
class SurveyInstructionsTtsCard extends StatelessWidget {
  final String surveyType;

  const SurveyInstructionsTtsCard({super.key, required this.surveyType});

  @override
  Widget build(BuildContext context) {
    final instruction = SurveyTypeConfig.instructionFor(surveyType);
    final ttsText = SurveyTtsTextBuilder.instructions(
      surveyType: surveyType,
      title: instruction.title,
      instructionText: instruction.instructions,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(instruction.title).semiBold(),
              const Gap(4),
              Text(instruction.instructions, style: const TextStyle(height: 1.5)),
            ],
          ),
        ),
        const Gap(8),
        TtsButton(text: ttsText),
      ],
    );
  }
}