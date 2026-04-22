import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';
import 'package:ssapp/shared/services/tts/survey_tts_text_builder.dart';
import 'package:ssapp/shared/widgets/tts/tts_button.dart';

/// Barra compacta con botón TTS para la pregunta actual de [SurveyScreen].
///
/// Genera el texto automáticamente a partir de la pregunta y sus opciones.
/// Ubicar justo encima de las opciones en el scroll de la encuesta.
class SurveyQuestionTtsBar extends StatelessWidget {
  final int questionNumber;
  final int totalQuestions;
  final String category;
  final List<SurveyOption> options;
  final String? surveyType;

  const SurveyQuestionTtsBar({
    super.key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.category,
    required this.options,
    this.surveyType,
  });

  @override
  Widget build(BuildContext context) {
    final ttsText = SurveyTtsTextBuilder.question(
      questionNumber: questionNumber,
      totalQuestions: totalQuestions,
      category: category,
      options: options,
      surveyType: surveyType,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TtsButton(
          text: ttsText,
          outlined: true,
        ),
      ],
    );
  }
}