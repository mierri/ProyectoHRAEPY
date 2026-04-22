import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/types/assist/domain/assist_questions.dart';
import 'package:ssapp/shared/services/tts/survey_tts_text_builder.dart';
import 'package:ssapp/shared/widgets/tts/tts_button.dart';

/// Barra TTS para [AssistScreen].
///
/// ASSIST es un caso especial porque:
/// - La pregunta 1 lista sustancias (no opciones fijas).
/// - Las preguntas 2–7 tienen sustancias seleccionadas como sub-items.
/// - La pregunta 8 es sobre vía de administración.
///
/// Esta barra genera el texto correcto según el contexto.
class AssistQuestionTtsBar extends StatelessWidget {
  final int questionNumber;
  final int totalQuestions;
  final String questionTitle;
  final List<AssistSubstance> relevantSubstances;

  const AssistQuestionTtsBar({
    super.key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.questionTitle,
    required this.relevantSubstances,
  });

  List<String> _buildOptions() {
    switch (questionNumber) {
      case 1:
      // Pregunta 1: solo explica que se debe seleccionar Sí o No por sustancia
        return ['Sí, la he consumido alguna vez', 'No, nunca la he consumido'];
      case 2:
        return AssistQuestions.frequencyOptions;
      case 3:
        return AssistQuestions.frequencyOptions;
      case 4:
        return AssistQuestions.frequencyOptions;
      case 5:
        return AssistQuestions.frequencyOptions;
      case 6:
      case 7:
        return AssistQuestions.p67Options;
      case 8:
        return AssistQuestions.p8Options;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final substanceNames = relevantSubstances.map((s) => s.label).toList();
    final options = _buildOptions();

    final ttsText = SurveyTtsTextBuilder.assistQuestion(
      questionNumber: questionNumber,
      totalQuestions: totalQuestions,
      questionTitle: questionTitle,
      options: options,
      substanceNames: substanceNames.isNotEmpty ? substanceNames : null,
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