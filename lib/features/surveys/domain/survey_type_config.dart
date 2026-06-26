import 'package:flutter/material.dart';
import 'package:ssapp/shared/utils/theme.dart';

// Responsabilidad: centralizar metadatos de tipos de encuesta (color, descripción e instrucciones).
enum SurveyInstructionVariant {
  bdi,
  bai,
  ghq12,
  phq9,
  gds,
  lawton,
  katz,
  iciqSf,
  whoqol,
  sf36,
  assist,
  osteoporosis,
  sociodemographic,
  socialDeterminants,
  specialtyConsultationAttendance,
  perceivedAttendanceBarriers,
  custom,
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
  static const Map<String, int> _itemCounts = {
    'bdi': 21,
    'bai': 21,
    'ghq12': 12,
    'phq9': 9,
    'gds': 15,
    'lawton': 8,
    'katz': 6,
    'iciqsf': 4,
    'whoqol': 26,
    'sf36': 36,
    'assist': 8,
    'osteoporosis': 7,
    'sociodemographic': 15,
    'social_determinants': 15,
    'specialty_consultation_attendance': 7,
    'perceived_attendance_barriers': 4,
  };

  static String normalizeType(String? surveyType) {
    final normalized = (surveyType ?? 'bdi').toLowerCase();
    if (normalized == 'socialdeterminants') {
      return 'social_determinants';
    }
    if (normalized == 'specialtyconsultationattendance' ||
        normalized == 'asistencia en consulta de especialidad' ||
        normalized == 'asistencia en consultas de especialidad' ||
        normalized == 'anexo 1' ||
        normalized == '16') {
      return 'specialty_consultation_attendance';
    }
    if (normalized == 'perceivedattendancebarriers' ||
        normalized == 'barreras percibidas para la asistencia' ||
        normalized == 'barreras percibidas para asistencia' ||
        normalized == 'barreras percibidas para la asistencia a consultas médicas programadas' ||
        normalized == 'barreras percibidas para la asistencia a consultas medicas programadas' ||
        normalized == '17') {
      return 'perceived_attendance_barriers';
    }
    return normalized.isEmpty ? 'bdi' : normalized;
  }

  static Color colorFor(String? surveyType) {
    switch (normalizeType(surveyType)) {
      case 'bai':
        return LightModeColors.lightTertiary;
      case 'ghq12':
        return const Color(0xFF0284C7);
      case 'phq9':
        return const Color(0xFF9333EA);
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
      case 'sociodemographic':
        return const Color(0xFF4F46E5);
      case 'social_determinants':
        return const Color(0xFF0F766E);
      case 'specialty_consultation_attendance':
        return const Color(0xFFB45309);
      case 'perceived_attendance_barriers':
        return const Color(0xFFBE123C);
      case 'custom':
        return const Color(0xFF0D9488);
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
      case 'ghq12':
        return 'Este cuestionario evalua malestar psicologico reciente asociado al estres mediante el Cuestionario de Salud General de Goldberg (GHQ-12). No sustituye un diagnostico clinico y se centra en cambios del funcionamiento en las ultimas dos semanas.';
      case 'phq9':
        return 'Este cuestionario evalua sintomas depresivos en las ultimas dos semanas mediante el PHQ-9. Incluye tamizaje de ideacion autolesiva y orienta la necesidad de valoracion clinica.';
      case 'whoqol':
        return 'Este cuestionario evalúa la calidad de vida en cuatro dominios: salud física, salud psicológica, relaciones sociales y ambiente, mediante el instrumento WHOQOL-BREF de la Organización Mundial de la Salud. Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'sf36':
        return 'Este cuestionario evalúa diferentes aspectos de la salud y el bienestar mediante la Encuesta de Salud de 36 Items (SF-36). Evalúa funcionamiento físico, rol físico, dolor corporal, salud general, vitalidad, funcionamiento social, rol emocional y salud mental. Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'assist':
        return 'Este cuestionario evalúa riesgo asociado al consumo de tabaco, alcohol y otras sustancias mediante el instrumento OMS-ASSIST V3.0. Los resultados orientan el nivel de intervención (sin intervención, intervención breve o tratamiento intensivo). Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'sociodemographic':
        return 'Este cuestionario recoge datos sociodemográficos del participante. No genera puntaje clínico; la información es para caracterización y análisis del contexto.';
      case 'social_determinants':
        return 'Este cuestionario recoge determinantes sociales del hogar (educación, vivienda, servicios y apoyo social). No genera puntaje clínico; la información es para análisis del contexto.';
      case 'specialty_consultation_attendance':
        return 'Este cuestionario recoge datos generales del usuario y antecedentes recientes de asistencia a consulta de especialidad. No genera puntaje clínico; la información sirve para seguimiento de barreras y adherencia a la atención.';
      case 'perceived_attendance_barriers':
        return 'Este cuestionario identifica barreras percibidas para la asistencia a consultas médicas programadas. No genera puntaje clínico; la información sirve para explorar motivos de inasistencia reciente y riesgos de inasistencia futura.';
      case 'custom':
        return 'Esta es una encuesta personalizada creada por su equipo de salud. Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de seguimiento.';
      case 'bdi':
      default:
        return 'Este cuestionario evalúa síntomas de depresión mediante el Inventario de Depresión de Beck (BDI-II). Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
    }
  }

  static int itemCountFor(String? surveyType) {
    return _itemCounts[normalizeType(surveyType)] ?? 0;
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
      case 'ghq12':
        return const SurveyInstructionContent(
          title: 'Cuestionario de Salud General de Goldberg (GHQ-12)',
          instructions:
              'Responda cada pregunta segun como se ha sentido ultimamente, durante las ultimas dos semanas. El instrumento detecta cambios recientes en su funcionamiento general y no rasgos permanentes de personalidad.',
          variant: SurveyInstructionVariant.ghq12,
        );
      case 'phq9':
        return const SurveyInstructionContent(
          title: 'Cuestionario sobre la Salud del Paciente (PHQ-9)',
          instructions:
              'Durante las ultimas dos semanas, indique con que frecuencia le han afectado los sintomas descritos. No hay respuestas correctas o incorrectas; responda con honestidad segun su situacion actual.',
          variant: SurveyInstructionVariant.phq9,
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
      case 'sociodemographic':
        return const SurveyInstructionContent(
          title: 'Cuestionario Sociodemográfico',
          instructions:
              'Responda cada apartado con la información del participante. Algunos campos pueden requerir especificación adicional.',
          variant: SurveyInstructionVariant.sociodemographic,
        );
      case 'social_determinants':
        return const SurveyInstructionContent(
          title: 'Cuestionario de Determinantes Sociales',
          instructions:
              'Responda cada apartado con la información del hogar. Marque todas las opciones que apliquen cuando se solicite.',
          variant: SurveyInstructionVariant.socialDeterminants,
        );
      case 'specialty_consultation_attendance':
        return const SurveyInstructionContent(
          title: 'Asistencia en Consulta de Especialidad',
          instructions:
              'Capture los datos generales del usuario y registre la especialidad, disponibilidad de transporte y antecedentes de inasistencia a citas durante los últimos tres meses.',
          variant: SurveyInstructionVariant.specialtyConsultationAttendance,
        );
      case 'perceived_attendance_barriers':
        return const SurveyInstructionContent(
          title: 'Barreras Percibidas para la Asistencia',
          instructions:
              'Si existe antecedente reciente de inasistencia, primero se registrará el principal motivo de la falta más reciente. Después, seleccione tres motivos distintos en orden de importancia sobre por qué podría faltar a una consulta médica programada en el futuro.',
          variant: SurveyInstructionVariant.perceivedAttendanceBarriers,
        );
      case 'custom':
        return const SurveyInstructionContent(
          title: 'Encuesta personalizada',
          instructions:
              'Responda cada pregunta con sinceridad. Esta encuesta fue diseñada por su equipo de salud para este seguimiento.',
          variant: SurveyInstructionVariant.custom,
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
