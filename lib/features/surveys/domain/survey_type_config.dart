import 'package:flutter/material.dart';
import 'package:ssapp/shared/utils/theme.dart';

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
  mocaBasic,
  mocaBlind,
  fantasticMexA,
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
    'moca_basic': 9,
    'moca_blind': 8,
    'fantastic_mexa': 46,
  };

  static String normalizeType(String? surveyType) {
    final normalized = (surveyType ?? 'bdi').toLowerCase();
    if (normalized == 'socialdeterminants') return 'social_determinants';
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
        normalized == 'barreras percibidas para la asistencia a consultas medicas programadas' ||
        normalized == '17') {
      return 'perceived_attendance_barriers';
    }
    if (normalized == 'mocabasic' ||
        normalized == 'moca' ||
        normalized == 'moca 8.1' ||
        normalized == 'moca8.1' ||
        normalized == 'moca 8' ||
        normalized == 'moca basic' ||
        normalized == 'moca basica' ||
        normalized == '4') {
      return 'moca_basic';
    }
    if (normalized == 'mocablind' ||
        normalized == 'moca blind' ||
        normalized == 'moca discapacidad visual' ||
        normalized == '19') {
      return 'moca_blind';
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
      case 'moca_basic':
        return const Color(0xFF0F766E);
      case 'moca_blind':
        return const Color(0xFF1D4ED8);
      case 'fantastic_mexa':
        return const Color(0xFF059669);
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
        return 'Este cuestionario evalua sintomas de ansiedad mediante el Inventario de Ansiedad de Beck (BAI).';
      case 'gds':
        return 'Este cuestionario evalua sintomas depresivos en personas mayores mediante la Escala de Depresion Geriatrica de 15 items (GDS-15).';
      case 'lawton':
        return 'Este cuestionario evalua la independencia en actividades instrumentales de la vida diaria mediante la Escala de Lawton (AIVD).';
      case 'katz':
        return 'Este cuestionario evalua la independencia en actividades basicas de la vida diaria mediante el Indice de Katz (ABVD).';
      case 'iciqsf':
        return 'Este cuestionario evalua severidad e impacto de la incontinencia urinaria mediante ICIQ-SF.';
      case 'osteoporosis':
        return 'Este cuestionario detecta el riesgo de fracturas por osteoporosis.';
      case 'ghq12':
        return 'Este cuestionario evalua malestar psicologico reciente asociado al estres mediante el Cuestionario de Salud General de Goldberg (GHQ-12).';
      case 'phq9':
        return 'Este cuestionario evalua sintomas depresivos en las ultimas dos semanas mediante el PHQ-9.';
      case 'whoqol':
        return 'Este cuestionario evalua la calidad de vida mediante WHOQOL-BREF.';
      case 'sf36':
        return 'Este cuestionario evalua diferentes aspectos de la salud y el bienestar mediante la Encuesta de Salud de 36 Items (SF-36).';
      case 'assist':
        return 'Este cuestionario evalua riesgo asociado al consumo de tabaco, alcohol y otras sustancias mediante el instrumento OMS-ASSIST V3.0.';
      case 'sociodemographic':
        return 'Este cuestionario recoge datos sociodemograficos del participante. No genera puntaje clinico.';
      case 'social_determinants':
        return 'Este cuestionario recoge determinantes sociales del hogar. No genera puntaje clinico.';
      case 'specialty_consultation_attendance':
        return 'Este cuestionario recoge datos generales del usuario y antecedentes recientes de asistencia a consulta de especialidad.';
      case 'perceived_attendance_barriers':
        return 'Este cuestionario identifica barreras percibidas para la asistencia a consultas medicas programadas.';
      case 'moca_basic':
        return 'MoCA 8.1 es la version estandar del Montreal Cognitive Assessment. La app combina tareas del paciente en la tableta con captura clinica del doctor y calcula el puntaje ajustado sobre 30.';
      case 'moca_blind':
        return 'MoCA Blind es la version para discapacidad visual. La app registra el desempeno por apartados y calcula el puntaje total ajustado sobre 22.';
      case 'fantastic_mexa':
        return 'FANTASTIC MEX-A evalua el estilo de vida en 12 areas (familia, actividad fisica, nutricion, tabaco, alcohol, sueno, personalidad, introspeccion, carrera, salud, orden y somatometria) mediante 46 items puntuados 0-4.';
      case 'custom':
        return 'Esta es una encuesta personalizada creada por su equipo de salud.';
      case 'bdi':
      default:
        return 'Este cuestionario evalua sintomas de depresion mediante el Inventario de Depresion de Beck (BDI-II).';
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
              'A continuacion encontrara una lista de sintomas. Indique cuanto le ha molestado cada sintoma durante la ultima semana, incluyendo hoy.',
          variant: SurveyInstructionVariant.bai,
        );
      case 'ghq12':
        return const SurveyInstructionContent(
          title: 'Cuestionario de Salud General de Goldberg (GHQ-12)',
          instructions:
              'Responda cada pregunta segun como se ha sentido ultimamente, durante las ultimas dos semanas.',
          variant: SurveyInstructionVariant.ghq12,
        );
      case 'phq9':
        return const SurveyInstructionContent(
          title: 'Cuestionario sobre la Salud del Paciente (PHQ-9)',
          instructions:
              'Durante las ultimas dos semanas, indique con que frecuencia le han afectado los sintomas descritos.',
          variant: SurveyInstructionVariant.phq9,
        );
      case 'gds':
        return const SurveyInstructionContent(
          title: 'Escala de Depresion Geriatrica (GDS-15)',
          instructions:
              'Este cuestionario consta de 15 preguntas, cada una con dos opciones de respuesta: Si o No.',
          variant: SurveyInstructionVariant.gds,
        );
      case 'osteoporosis':
        return const SurveyInstructionContent(
          title: 'Encuesta de Riesgo de Fractura por Osteoporosis',
          instructions:
              'Marque la respuesta correspondiente a cada pregunta. Cada pregunta tiene dos opciones: Si o No.',
          variant: SurveyInstructionVariant.osteoporosis,
        );
      case 'lawton':
        return const SurveyInstructionContent(
          title: 'Escala de Lawton (AIVD)',
          instructions:
              'Seleccione la opcion que mejor describa su capacidad actual en cada actividad.',
          variant: SurveyInstructionVariant.lawton,
        );
      case 'katz':
        return const SurveyInstructionContent(
          title: 'Indice de Katz (ABVD)',
          instructions:
              'Cada item puntua 1 si existe independencia total o con minima ayuda, y 0 si existe dependencia.',
          variant: SurveyInstructionVariant.katz,
        );
      case 'iciqsf':
        return const SurveyInstructionContent(
          title: 'ICIQ-SF',
          instructions:
              'Este cuestionario evalua frecuencia, cantidad e impacto de la perdida de orina. La pregunta 4 no suma al puntaje total.',
          variant: SurveyInstructionVariant.iciqSf,
        );
      case 'whoqol':
        return const SurveyInstructionContent(
          title: 'Cuestionario de Calidad de Vida (WHOQOL-BREF)',
          instructions:
              'Responda todas las preguntas segun como se ha sentido durante las ultimas dos semanas.',
          variant: SurveyInstructionVariant.whoqol,
        );
      case 'sf36':
        return const SurveyInstructionContent(
          title: 'Encuesta de Salud de 36 Items (SF-36)',
          instructions:
              'Responda cada pregunta segun como se ha sentido o que ha podido hacer durante las ultimas cuatro semanas.',
          variant: SurveyInstructionVariant.sf36,
        );
      case 'assist':
        return const SurveyInstructionContent(
          title: 'OMS-ASSIST V3.0',
          instructions:
              'Primero se registra consumo alguna vez en la vida y luego frecuencia o problemas en los ultimos 3 meses para cada sustancia seleccionada.',
          variant: SurveyInstructionVariant.assist,
        );
      case 'sociodemographic':
        return const SurveyInstructionContent(
          title: 'Cuestionario Sociodemografico',
          instructions:
              'Verifique los datos precargados del consentimiento informado y complete la informacion sociodemografica del participante.',
          variant: SurveyInstructionVariant.sociodemographic,
        );
      case 'social_determinants':
        return const SurveyInstructionContent(
          title: 'Cuestionario de Determinantes Sociales',
          instructions:
              'Responda las preguntas sobre escolaridad, ocupacion, vivienda, seguridad social, composicion del hogar, bienes y apoyo social.',
          variant: SurveyInstructionVariant.socialDeterminants,
        );
      case 'specialty_consultation_attendance':
        return const SurveyInstructionContent(
          title: 'Asistencia en Consulta de Especialidad',
          instructions:
              'Capture los datos generales del usuario y registre la especialidad, disponibilidad de transporte y antecedentes de inasistencia.',
          variant: SurveyInstructionVariant.specialtyConsultationAttendance,
        );
      case 'perceived_attendance_barriers':
        return const SurveyInstructionContent(
          title: 'Barreras Percibidas para la Asistencia',
          instructions:
              'Primero registre el principal motivo de inasistencia reciente y despues tres motivos distintos en orden de importancia para inasistencia futura.',
          variant: SurveyInstructionVariant.perceivedAttendanceBarriers,
        );
      case 'moca_basic':
        return const SurveyInstructionContent(
          title: 'MoCA 8.1',
          instructions:
              'Esta version del MoCA 8.1 se aplica completamente en la tableta. El paciente realiza las tareas visuales y el doctor registra las respuestas y la puntuacion por dominio dentro de la misma app.',
          variant: SurveyInstructionVariant.mocaBasic,
        );
      case 'moca_blind':
        return const SurveyInstructionContent(
          title: 'MoCA Blind',
          instructions:
              'Esta version del MoCA Blind se aplica completamente en la tableta. El doctor sigue las consignas visibles en pantalla y registra ahi mismo el desempeno del paciente en cada apartado.',
          variant: SurveyInstructionVariant.mocaBlind,
        );
      case 'fantastic_mexa':
        return const SurveyInstructionContent(
          title: 'FANTASTIC MEX-A',
          instructions:
              'Senale la respuesta con la que se identifica, de acuerdo con sus patrones de comportamiento de los ultimos dos meses. La pregunta 46 (IMC) no tiene imagen.',
          variant: SurveyInstructionVariant.fantasticMexA,
        );
      case 'custom':
        return const SurveyInstructionContent(
          title: 'Encuesta personalizada',
          instructions:
              'Responda cada pregunta con sinceridad. Esta encuesta fue disenada por su equipo de salud.',
          variant: SurveyInstructionVariant.custom,
        );
      case 'bdi':
      default:
        return const SurveyInstructionContent(
          title: 'Inventario de Depresion de Beck (BDI-II)',
          instructions:
              'Este cuestionario consta de 21 afirmaciones. Lea cada grupo y elija la opcion que mejor describa como se ha sentido durante las ultimas dos semanas, incluyendo hoy.',
          variant: SurveyInstructionVariant.bdi,
        );
    }
  }
}
