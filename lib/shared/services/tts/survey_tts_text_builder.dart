import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';

/// Construye los textos que se narrarán en TTS para cada pantalla.
/// Sin dependencias de UI (solo strings).
class SurveyTtsTextBuilder {
  SurveyTtsTextBuilder._();

  /// Texto de instrucción para el tipo de encuesta dado.
  static String instructions({
    required String surveyType,
    required String title,
    required String instructionText,
  }) {
    return '$title. $instructionText';
  }

  /// Texto para narrar la pregunta actual y sus opciones.
  static String question({
    required int questionNumber,
    required int totalQuestions,
    required String category,
    required List<SurveyOption> options,
    String? surveyType,
  }) {
    final buffer = StringBuffer();
    buffer.write('Pregunta $questionNumber de $totalQuestions. ');
    buffer.write('$category. ');
    buffer.write('Las opciones son: ');

    for (var i = 0; i < options.length; i++) {
      buffer.write('Opción ${i + 1}: ${options[i].text}. ');
    }

    return buffer.toString();
  }

  /// Texto para ASSIST: pregunta + sustancias o sub-opciones.
  static String assistQuestion({
    required int questionNumber,
    required int totalQuestions,
    required String questionTitle,
    required List<String> options,
    List<String>? substanceNames,
  }) {
    final buffer = StringBuffer();
    buffer.write('Pregunta $questionNumber de $totalQuestions. ');
    buffer.write('$questionTitle. ');

    if (substanceNames != null && substanceNames.isNotEmpty) {
      buffer.write('Sustancias a evaluar: ');
      for (final name in substanceNames) {
        buffer.write('$name. ');
      }
    }

    if (options.isNotEmpty) {
      buffer.write('Opciones de respuesta: ');
      for (var i = 0; i < options.length; i++) {
        buffer.write('${options[i]}. ');
      }
    }

    return buffer.toString();
  }

  /// Texto para narrar un consentimiento informado.
  static String consent(String consentText) {
    final trimmed = consentText.trim();
    if (trimmed.isEmpty) {
      return 'Esta encuesta no tiene texto de consentimiento registrado.';
    }
    return 'Consentimiento informado. $trimmed';
  }

  /// Texto para narrar el consentimiento de una investigación.
  static String investigationConsent({
    required String investigationName,
    required String consentText,
  }) {
    final trimmed = consentText.trim();
    if (trimmed.isEmpty) {
      return 'Investigación: $investigationName. '
          'Esta investigación no tiene texto de consentimiento registrado.';
    }
    return 'Investigación: $investigationName. '
        'Consentimiento informado. $trimmed';
  }
}