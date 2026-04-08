import 'package:flutter/material.dart';
import 'package:ssapp/shared/utils/theme.dart';

// Responsabilidad: centralizar metadatos de tipos de encuesta (color, descripción e instrucciones).
enum SurveyInstructionVariant {
  bdi,
  bai,
  moca,
  gds,
  lawton,
  katz,
  iciqSf,
  whoqol,
  sf36,
  assist,
  osteoporosis,
}

class SurveyInstructionContent {
  final String title;
  final String instructions;
  final SurveyInstructionVariant variant;

  const SurveyInstructionContent({
    required this.title,
    required this.instructions,
    required this.variant,
  });
}

class SurveyTypeConfig {
  static String normalizeType(String? surveyType) {
    final normalized = (surveyType ?? 'bdi').toLowerCase();
    return normalized.isEmpty ? 'bdi' : normalized;
  }

  static Color colorFor(String? surveyType) {
    switch (normalizeType(surveyType)) {
      case 'bai':
        return LightModeColors.lightTertiary;
      case 'moca':
        return LightModeColors.lightSecondary;
      case 'gds':
        return const Color(0xFF0EA5E9);
      case 'lawton':
        return const Color(0xFF14B8A6);
      case 'katz':
        return const Color(0xFF0D9488);
      case 'iciqsf':
        return const Color(0xFF2563EB);
      case 'whoqol':
        return const Color(0xFF7C3AED);
      case 'sf36':
        return const Color(0xFF06B6D4);
      case 'assist':
        return LightModeColors.lightSecondary;
      case 'osteoporosis':
        return const Color(0xFF145374);
      case 'bdi':
      default:
        return LightModeColors.lightPrimary;
    }
  }

  static String descriptionFor(String? surveyType) {
    switch (normalizeType(surveyType)) {
      case 'bai':
        return 'Este cuestionario evalúa síntomas de ansiedad mediante el Inventario de Ansiedad de Beck (BAI). Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'gds':
        return 'Este cuestionario evalúa síntomas depresivos en personas mayores mediante la Escala de Depresión Geriátrica de 15 items (GDS-15). Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'lawton':
        return 'Este cuestionario evalúa la independencia en actividades instrumentales de la vida diaria mediante la Escala de Lawton (AIVD). Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'katz':
        return 'Este cuestionario evalua la independencia en actividades basicas de la vida diaria mediante el Indice de Katz (ABVD). Genera puntaje total de 0 a 6 y clasificacion alfabetica A-H segun patron de dependencia. Los datos recopilados seran utilizados exclusivamente para propositos clinicos y de investigacion del Departamento de Psicologia del HRAEPY.';
      case 'iciqsf':
        return 'Este cuestionario evalua severidad e impacto de la incontinencia urinaria mediante ICIQ-SF. Incluye una seccion de orientacion clinica sobre situaciones de perdida de orina. Los datos recopilados seran utilizados exclusivamente para propositos clinicos y de investigacion del Departamento de Psicologia del HRAEPY.';
      case 'osteoporosis':
        return 'Este cuestionario detecta el riesgo de fracturas por osteoporosis. Los datos de peso, talla e IMC se solicitan y se almacenan en la base de datos junto con la encuesta. Los resultados deben cruzarse con la edad, IMC y puntaje obtenido.';
      case 'moca':
        return 'Esta evaluación cognitiva evalúa diferentes dominios cognitivos mediante la Evaluación Cognitiva Montreal (MoCA). Evalúa atención, concentración, funciones ejecutivas, memoria, lenguaje, habilidades visuoconstructivas, pensamiento conceptual, cálculo y orientación. Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'whoqol':
        return 'Este cuestionario evalúa la calidad de vida en cuatro dominios: salud física, salud psicológica, relaciones sociales y ambiente, mediante el instrumento WHOQOL-BREF de la Organización Mundial de la Salud. Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'sf36':
        return 'Este cuestionario evalúa diferentes aspectos de la salud y el bienestar mediante la Encuesta de Salud de 36 Items (SF-36). Evalúa funcionamiento físico, rol físico, dolor corporal, salud general, vitalidad, funcionamiento social, rol emocional y salud mental. Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'assist':
        return 'Este cuestionario evalúa riesgo asociado al consumo de tabaco, alcohol y otras sustancias mediante el instrumento OMS-ASSIST V3.0. Los resultados orientan el nivel de intervención (sin intervención, intervención breve o tratamiento intensivo). Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'bdi':
      default:
        return 'Este cuestionario evalúa síntomas de depresión mediante el Inventario de Depresión de Beck (BDI-II). Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
    }
  }

  static SurveyInstructionContent instructionFor(String? surveyType) {
    switch (normalizeType(surveyType)) {
      case 'bai':
        return const SurveyInstructionContent(
          title: 'Inventario de Ansiedad de Beck (BAI)',
          instructions:
              'A continuación encontrará una lista de síntomas. Por favor, indique cuánto le ha molestado cada síntoma durante la última semana, incluyendo hoy.',
          variant: SurveyInstructionVariant.bai,
        );
      case 'moca':
        return const SurveyInstructionContent(
          title: 'Evaluación Cognitiva Montreal (MoCA)',
          instructions:
              'A continuación se le presentarán una serie de tareas y preguntas que evalúan diferentes áreas de su funcionamiento cognitivo. Siga las instrucciones de cada actividad con atención. No hay respuestas buenas o malas, simplemente haga su mejor esfuerzo.',
          variant: SurveyInstructionVariant.moca,
        );
      case 'gds':
        return const SurveyInstructionContent(
          title: 'Escala de Depresión Geriátrica (GDS-15)',
          instructions:
              'Este cuestionario consta de 15 preguntas, cada una con dos opciones de respuesta: Sí o No. Responda según cómo se ha sentido recientemente. No hay respuestas correctas o incorrectas.',
          variant: SurveyInstructionVariant.gds,
        );
      case 'osteoporosis':
        return const SurveyInstructionContent(
          title: 'Encuesta de Riesgo de Fractura por Osteoporosis',
          instructions:
              'Este cuestionario se aplica a personas de 50 años o más y permite identificar el riesgo para fractura por osteoporosis. En las preguntas siguientes, marque con una X en la columna correspondiente a la respuesta por la persona entrevistada. Cada pregunta tiene solo dos opciones de respuesta: Sí o No.',
          variant: SurveyInstructionVariant.osteoporosis,
        );
      case 'lawton':
        return const SurveyInstructionContent(
          title: 'Escala de Lawton (AIVD)',
          instructions:
              'Este cuestionario evalúa su nivel de independencia en actividades instrumentales de la vida diaria. Seleccione la opción que mejor describa su capacidad actual en cada actividad.',
          variant: SurveyInstructionVariant.lawton,
        );
      case 'katz':
        return const SurveyInstructionContent(
          title: 'Indice de Katz (ABVD)',
          instructions:
              'Este instrumento evalua independencia en actividades basicas de la vida diaria. Cada item puntua 1 si existe independencia total o con minima ayuda, y 0 si existe dependencia.',
          variant: SurveyInstructionVariant.katz,
        );
      case 'iciqsf':
        return const SurveyInstructionContent(
          title: 'ICIQ-SF',
          instructions:
              'Este cuestionario evalua frecuencia, cantidad e impacto de la perdida de orina. La pregunta 4 registra situaciones de perdida para orientacion clinica y no suma al puntaje total.',
          variant: SurveyInstructionVariant.iciqSf,
        );
      case 'whoqol':
        return const SurveyInstructionContent(
          title: 'Cuestionario de Calidad de Vida (WHOQOL-BREF)',
          instructions:
              'Este cuestionario le pregunta cómo se ha sentido acerca de su calidad de vida, su salud y otros aspectos de su vida durante las dos últimas semanas. Por favor, responda todas las preguntas. Si no está seguro/a de qué respuesta dar a una pregunta, escoja la que le parezca más apropiada.',
          variant: SurveyInstructionVariant.whoqol,
        );
      case 'sf36':
        return const SurveyInstructionContent(
          title: 'Encuesta de Salud de 36 Items (SF-36)',
          instructions:
              'Este cuestionario evalúa diferentes aspectos de su salud y bienestar. Por favor, responda cada pregunta según cómo se ha sentido o qué ha podido hacer durante las últimas cuatro semanas. No hay respuestas correctas o incorrectas, simplemente elija la opción que mejor describa su situación.',
          variant: SurveyInstructionVariant.sf36,
        );
      case 'assist':
        return const SurveyInstructionContent(
          title: 'OMS-ASSIST V3.0',
          instructions:
              'Este cuestionario detecta riesgo asociado al consumo de tabaco, alcohol y otras sustancias. Primero se registra consumo alguna vez en la vida y luego frecuencia/problemas en los últimos 3 meses para cada sustancia seleccionada. Responda con la mayor precisión posible.',
          variant: SurveyInstructionVariant.assist,
        );
      case 'bdi':
      default:
        return const SurveyInstructionContent(
          title: 'Inventario de Depresión de Beck (BDI-II)',
          instructions:
              'Este cuestionario consta de 21 grupos de afirmaciones. Por favor, lea con cuidado cada grupo y elija la que mejor describe cómo se ha sentido durante las últimas dos semanas, incluyendo hoy.',
          variant: SurveyInstructionVariant.bdi,
        );
    }
  }
}
