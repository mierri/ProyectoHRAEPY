import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/domain/survey_catalog.dart';
import 'package:ssapp/features/surveys/domain/survey_rules.dart';
import 'package:ssapp/features/surveys/types/assist/domain/assist_questions.dart';
import 'package:ssapp/features/surveys/types/iciq_sf/domain/iciq_sf_questions.dart';
import 'package:ssapp/features/surveys/types/katz/domain/katz_questions.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_service.dart';
import 'package:ssapp/features/surveys/presentation/survey_results/components/assist_result_view.dart';
import 'package:ssapp/features/surveys/presentation/survey_results/components/custom_result_view.dart';
import 'package:ssapp/features/surveys/presentation/survey_results/components/standard_result_view.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';

// Responsabilidad: presentar resultados de una encuesta ya guardada.
class SurveyResultsScreen extends StatefulWidget {
  final int surveyId;

  const SurveyResultsScreen({
    super.key,
    required this.surveyId,
  });

  @override
  State<SurveyResultsScreen> createState() => _SurveyResultsScreenState();
}

class _SurveyResultsScreenState extends State<SurveyResultsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _survey;

  @override
  void initState() {
    super.initState();
    _loadSurvey();
  }

  Future<void> _loadSurvey() async {
    setState(() => _isLoading = true);

    final surveyService = context.read<SurveyService>();
    await surveyService.loadSurveys();

    final survey = surveyService.surveys.firstWhere(
      (s) => s['survey_id'] == widget.surveyId,
      orElse: () => {},
    );

    if (survey.isNotEmpty && survey['survey_type'] == SurveyCatalog.custom) {
      final customService = context.read<CustomSurveyService>();
      final customSurveyId = survey['custom_survey_id'] as int?;
      if (customSurveyId == null || customService.getById(customSurveyId) == null) {
        await customService.loadAll();
      }
    }

    if (mounted) {
      setState(() {
        _survey = survey.isNotEmpty ? survey : null;
        _isLoading = false;
      });
    }
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'mínima':
      case 'minima':
        return LightModeColors.lightTertiary;
      case 'leve':
        return const Color(0xFFFBBF24); // Yellow
      case 'moderada':
        return const Color(0xFFF97316); // Orange
      case 'severa':
        return LightModeColors.lightError;
      case 'excelente':
        return LightModeColors.lightTertiary;
      case 'muy bueno':
        return const Color(0xFFFBBF24);
      case 'bueno':
        return const Color(0xFFF97316);
      case 'regular':
        return const Color(0xFFFF7043);
      case 'bajo':
        return LightModeColors.lightError;
      case 'normal':
        return LightModeColors.lightTertiary;
      case 'síntomas depresivos':
      case 'sintomas depresivos':
        return LightModeColors.lightError;
      case 'independencia total':
        return LightModeColors.lightTertiary;
      case 'dependencia en algún grado':
      case 'dependencia en algun grado':
        return const Color(0xFFF59E0B);
      case 'deterioro funcional':
        return const Color(0xFFF59E0B);
      case 'sin incontinencia':
        return LightModeColors.lightTertiary;
      case 'moderado':
        return const Color(0xFFF59E0B);
      case 'moderadamente grave':
        return const Color(0xFFDC2626);
      case 'alto':
        return LightModeColors.lightError;
      case 'grave':
        return const Color(0xFFB91C1C);
      default:
        return LightModeColors.lightSecondary;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'mínima':
      case 'minima':
        return material.Icons.sentiment_very_satisfied;
      case 'leve':
        return material.Icons.sentiment_neutral;
      case 'moderada':
        return material.Icons.sentiment_dissatisfied;
      case 'severa':
        return material.Icons.sentiment_very_dissatisfied;
      case 'excelente':
        return material.Icons.sentiment_very_satisfied;
      case 'muy bueno':
        return material.Icons.sentiment_satisfied;
      case 'bueno':
        return material.Icons.sentiment_neutral;
      case 'regular':
        return material.Icons.sentiment_dissatisfied;
      case 'bajo':
        return material.Icons.sentiment_very_dissatisfied;
      case 'normal':
        return material.Icons.sentiment_very_satisfied;
      case 'síntomas depresivos':
      case 'sintomas depresivos':
        return material.Icons.sentiment_dissatisfied;
      case 'independencia total':
        return material.Icons.check_circle_outline;
      case 'dependencia en algún grado':
      case 'dependencia en algun grado':
        return material.Icons.warning_amber_outlined;
      case 'deterioro funcional':
        return material.Icons.warning_amber_outlined;
      case 'sin incontinencia':
        return material.Icons.check_circle_outline;
      case 'moderadamente grave':
        return material.Icons.report_problem_outlined;
      case 'alto':
        return material.Icons.warning_amber_outlined;
      case 'grave':
        return material.Icons.error_outline;
      default:
        return material.Icons.help_outline;
    }
  }

  String _katzClassificationFromSurvey(Map<String, dynamic> survey) {
    final responses = survey['responses'] as List? ?? const [];
    final responseMap = <int, int>{};
    for (final r in responses) {
      final qId = r['question_id'] as int?;
      final val = r['answer_value'] as int?;
      if (qId != null && val != null) {
        responseMap[qId] = val;
      }
    }
    try {
      return KatzQuestions.evaluate(responseMap).clasificacionKatz;
    } catch (_) {
      return 'H';
    }
  }

  String _getScoreLevel(int score, int surveyType) {
    switch (surveyType) {
      case 1: // BDI-II
        if (score <= 13) return 'Mínima';
        if (score <= 19) return 'Leve';
        if (score <= 28) return 'Moderada';
        return 'Severa';
      case 2: // BAI
        if (score <= 7) return 'Mínima';
        if (score <= 15) return 'Leve';
        if (score <= 25) return 'Moderada';
        return 'Severa';
      case 3: // WHOQOL
        if (score >= 4) return 'Excelente';
        if (score >= 3.5) return 'Muy bueno';
        if (score >= 3) return 'Bueno';
        if (score >= 2.5) return 'Regular';
        return 'Bajo';
      case 5: // SF-36
        if (score >= 4) return 'Excelente';
        if (score >= 3.5) return 'Muy bueno';
        if (score >= 3) return 'Bueno';
        if (score >= 2.5) return 'Regular';
        return 'Bajo';
      case 6: // ASSIST
        return 'ASSIST';
      case 7: // GDS-15
        if (score <= 4) return 'Normal';
        return 'Síntomas depresivos';
      case 8: // Lawton
        if (score == 8) return 'Independencia total';
        return 'Deterioro funcional';
      case 9: // hay que checar bien este pq se calcula con un tabla :(
        if (score <= 2) return 'Bajo';
        if (score <= 5) return 'Moderado';
        return 'Alto';
      case 10: // Katz ABVD
        if (score == 6) return 'Independencia total';
        return 'Dependencia en algún grado';
      case 11: // ICIQ-SF
        if (score == 0) return 'Sin incontinencia';
        if (score <= 5) return 'Leve';
        if (score <= 12) return 'Moderada';
        return 'Severa';
      case 12: // GHQ-12
        if (score <= 11) return 'Bajo';
        if (score <= 20) return 'Leve';
        if (score <= 27) return 'Moderado';
        return 'Alto';
      case 13: // PHQ-9
        if (score <= 4) return 'Minima';
        if (score <= 9) return 'Leve';
        if (score <= 14) return 'Moderada';
        if (score <= 19) return 'Moderadamente grave';
        return 'Grave';
      case 14: // Sociodemográfico
      case 15: // Determinantes sociales
      case 16: // Asistencia en Consulta de Especialidad
      case 17: // Barreras percibidas para la asistencia
        return 'Sin puntuación';
      default:
        return 'Resultado';
    }
  }

  List<String> _iciqOrientationFromSurvey(Map<String, dynamic> survey) {
    final responses = survey['responses'] as List? ?? const [];
    int mask = 0;
    for (final r in responses) {
      final qId = r['question_id'] as int?;
      if (qId == 4) {
        mask = r['answer_value'] as int? ?? 0;
        break;
      }
    }

    final situations = IciqSfQuestions.decodeSituationsFromMask(mask);
    return IciqSfQuestions.inferIncontinenceType(situations);
  }

  String _getRecommendation(String level, int surveyType) {
    switch (surveyType) {
      case 1: // BDI-II
        switch (level.toLowerCase()) {
          case 'mínima':
          case 'minima':
            return 'Los resultados indican ausencia de síntomas clínicamente relevantes de depresión. '
                'Se recomienda mantener hábitos saludables y seguimiento preventivo.';
          case 'leve':
            return 'Los resultados sugieren síntomas leves de depresión. '
                'Se recomienda evaluación con un profesional de salud mental y considerar intervenciones psicoterapéuticas.';
          case 'moderada':
            return 'Los resultados indican depresión moderada. '
                'Es importante buscar atención profesional. Se recomienda evaluación psiquiátrica y psicoterapia.';
          case 'severa':
            return 'Los resultados sugieren depresión severa. '
                'Se requiere atención profesional inmediata. Consulte con un psiquiatra para evaluación y tratamiento integral.';
          default:
            return 'Se recomienda consultar con un profesional de salud mental para una evaluación completa.';
        }
      case 2: // BAI
        switch (level.toLowerCase()) {
          case 'mínima':
          case 'minima':
            return 'Los resultados indican ausencia de síntomas clínicamente relevantes de ansiedad. '
                'Se recomienda mantener hábitos saludables y seguimiento preventivo.';
          case 'leve':
            return 'Los resultados sugieren síntomas leves de ansiedad. '
                'Se recomienda evaluación con un profesional de salud mental y considerar intervenciones psicoterapéuticas.';
          case 'moderada':
            return 'Los resultados indican ansiedad moderada. '
                'Es importante buscar atención profesional. Se recomienda evaluación psiquiátrica y psicoterapia.';
          case 'severa':
            return 'Los resultados sugieren ansiedad severa. '
                'Se requiere atención profesional inmediata. Consulte con un psiquiatra para evaluación y tratamiento integral.';
          default:
            return 'Se recomienda consultar con un profesional de salud mental para una evaluación completa.';
        }
      case 3: // WHOQOL
        switch (level.toLowerCase()) {
          case 'excelente':
            return 'Su calidad de vida es excelente. Continúe con sus hábitos y rutinas que le mantienen en este nivel de bienestar.';
          case 'muy bueno':
            return 'Su calidad de vida es muy buena. Mantenga sus actividades y hábitos positivos.';
          case 'bueno':
            return 'Su calidad de vida es buena. Se pueden identificar áreas para mejorar.';
          case 'regular':
            return 'Su calidad de vida es regular. Se recomienda evaluar aspectos de salud física, mental, social y ambiental.';
          case 'bajo':
            return 'Su calidad de vida requiere atención. Se recomienda consultar con profesionales para mejorar su bienestar.';
          default:
            return 'Se recomienda una evaluación más detallada de su calidad de vida.';
        }
      case 5: // SF-36
        switch (level.toLowerCase()) {
          case 'excelente':
            return 'Su salud general es excelente. Continúe manteniendo sus hábitos de vida saludables.';
          case 'muy bueno':
            return 'Su salud general es muy buena. Mantenga sus actividades y rutinas positivas.';
          case 'bueno':
            return 'Su salud general es buena. Se pueden identificar áreas para optimizar su bienestar.';
          case 'regular':
            return 'Su salud general es regular. Se recomienda evaluar aspectos físicos, emocionales y sociales.';
          case 'bajo':
            return 'Su salud general requiere atención. Se recomienda consultar con profesionales de salud.';
          default:
            return 'Se recomienda una evaluación más detallada de su salud general.';
        }
      case 6: // ASSIST
        return 'La intervención se define por sustancia según nivel de riesgo: Bajo (sin intervención), Moderado (intervención breve), Alto (tratamiento intensivo).';
      case 7: // GDS-15
        if (level.toLowerCase() == 'normal') {
          return 'El puntaje se encuentra dentro del rango normal para la escala GDS-15.';
        }
        return 'El puntaje sugiere síntomas depresivos. Se recomienda valoración clínica por un profesional de salud mental.';
      case 8: // Lawton
        if (level.toLowerCase() == 'independencia total') {
          return 'El resultado sugiere independencia para las actividades instrumentales evaluadas.';
        }
        return 'El resultado sugiere deterioro funcional en al menos una actividad instrumental. Se recomienda valoración geriátrica y plan de apoyo funcional.';
      case 9:
          switch (level.toLowerCase()) {
            case 'bajo':
              return 'El puntaje indica bajo riesgo de osteoporosis. Mantenga hábitos saludables para la salud ósea.';
            case 'moderado':
              return 'El puntaje indica riesgo moderado de osteoporosis. Se recomienda evaluación médica y medidas preventivas.';
            case 'alto':
              return 'El puntaje indica alto riesgo de osteoporosis. Se requiere evaluación médica urgente y posible tratamiento.';
            default:
              return 'Se recomienda consultar con un profesional de salud para una evaluación completa del riesgo de osteoporosis.';
          }
      case 10: // Katz ABVD
        if (level.toLowerCase().contains('independencia total')) {
          return 'El resultado sugiere independencia total en actividades basicas de la vida diaria (Katz A).';
        }
        return 'El resultado indica dependencia en algun grado. Revise la clasificacion alfabetica de Katz (A-H) para definir el nivel funcional y plan de apoyo.';
      case 11: // ICIQ-SF
        if (level.toLowerCase() == 'sin incontinencia') {
          return 'Sin evidencia de incontinencia urinaria segun ICIQ-SF.';
        }
        return 'Se detecta presencia de incontinencia urinaria. Se recomienda valoracion clinica para manejo individualizado.';
      case 12: // GHQ-12
        if (level.toLowerCase() == 'bajo') {
          return 'El puntaje sugiere bajo malestar psicologico reciente. Se recomienda mantener seguimiento preventivo.';
        }
        if (level.toLowerCase() == 'leve') {
          return 'Se observa malestar psicologico leve. Puede beneficiarse de seguimiento clinico y estrategias de manejo de estres.';
        }
        if (level.toLowerCase() == 'moderado') {
          return 'Se observa malestar psicologico moderado. Se recomienda valoracion por profesional de salud mental.';
        }
        return 'Se observa malestar psicologico alto. Se recomienda atencion profesional prioritaria.';
      case 13: // PHQ-9
        return 'El PHQ-9 sugiere sintomas depresivos segun su severidad actual. Si existe ideacion autolesiva, active valoracion clinica urgente.';
      case 14: // Sociodemográfico
        return 'El cuestionario sociodeomográfico no tiene una interpretación de puntajes. Se recomienda utilizar la información recopilada para contextualizar la situación del paciente.';
      case 15: // Determinantes Sociales
        return 'El cuestionario de determinantes sociales no tiene una interpretación de puntajes. Se recomienda utilizar la información recopilada para contextualizar la situación del paciente.';
      case 16: // Asistencia en Consulta de Especialidad
        return 'Este cuestionario no tiene una interpretación de puntajes. Se recomienda revisar la especialidad médica, disponibilidad de transporte y antecedentes de inasistencia para apoyar el seguimiento del paciente.';
      case 17: // Barreras percibidas para la asistencia
        return 'Este cuestionario no tiene una interpretación de puntajes. Se recomienda revisar los motivos de inasistencia reciente y los tres principales riesgos percibidos de falta futura para planear apoyos y seguimiento.';
      default:
        return 'Se recomienda consultar con un profesional de salud para una evaluación completa.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        headers: [
          AppBar(
            title: const Text('Resultados'),
            leading: [
              IconButton(
                icon: const Icon(material.Icons.arrow_back),
                onPressed: () => context.pop(),
                variance: ButtonVariance.ghost,
              ),
            ],
          ),
        ],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_survey == null) {
      return Scaffold(
        headers: [
          AppBar(
            title: const Text('Resultados'),
            leading: [
              IconButton(
                icon: const Icon(material.Icons.arrow_back),
                onPressed: () => context.pop(),
                variance: ButtonVariance.ghost,
              ),
            ],
          ),
        ],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                material.Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
              const Gap(16),
              const Text('Encuesta no encontrada').large(),
              const Gap(24),
              PrimaryButton(
                onPressed: () => context.pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    final patientService = context.watch<PatientService>();

    final responses = _survey!['responses'] as List?;
    final score = SurveyRules.calculateScore(_survey!);
    final surveyType = _survey!['survey_type'] as int? ?? 1;

    String getSurveyFullName(int type) {
      switch (type) {
        case 1: return 'Inventario de Depresión de Beck II';
        case 2: return 'Inventario de Ansiedad de Beck';
        case 3: return 'Cuestionario de Calidad de Vida WHOQOL-BREF';
        case 5: return 'Encuesta de Salud de 36 Items';
        case 6: return 'OMS-ASSIST V3.0';
        case 7: return 'Escala de Depresión Geriátrica de 15 ítems';
        case 8: return 'Escala de Lawton para Actividades Instrumentales de la Vida Diaria';
        case 9: return 'Cuestionario de Riesgo de Fractura por Osteoporosis';
        case 10: return 'Indice de Katz para Actividades Basicas de la Vida Diaria';
        case 11: return 'International Consultation on Incontinence Questionnaire - Short Form';
        case 12: return 'Cuestionario de Salud General de Goldberg';
        case 13: return 'Cuestionario sobre la Salud del Paciente';
        case 14: return 'Cuestionario Sociodemográfico';
        case 15: return 'Cuestionario de Determinantes Sociales';
        case 16: return 'Asistencia en Consulta de Especialidad';
        case 17: return 'Cuestionario de Barreras Percibidas para la Asistencia a Consultas Médicas Programadas';
        default: return 'Encuesta';
      }
    }

    final surveyTypeName = SurveyCatalog.nameForId(surveyType);
    final surveyFullName = getSurveyFullName(surveyType);
    final baseLevel = _getScoreLevel(score, surveyType);
    final katzClassification =
      surveyType == 10 ? _katzClassificationFromSurvey(_survey!) : null;
    final level = surveyType == 10 && katzClassification != null
      ? '$baseLevel (Katz $katzClassification)'
      : baseLevel;
    final iciqOrientation = surveyType == 11 ? _iciqOrientationFromSurvey(_survey!) : const <String>[];
    final color = _getLevelColor(baseLevel);
    final createdAt = DateTime.parse(_survey!['created_at']);

    // Obtener información del paciente
    final patientId = _survey!['patient_id'] as int?;
    String patientName = 'Paciente no encontrado';
    if (patientId != null) {
      try {
        final patient = patientService.patients.firstWhere(
          (p) => p.patientId == patientId,
        );
        patientName = patient.name;
      } catch (e) {
        patientName = 'Paciente no encontrado';
      }
    }

    if (surveyType == SurveyCatalog.custom) {
      final customSurveyId = _survey!['custom_survey_id'] as int?;
      final definition = customSurveyId != null
          ? context.watch<CustomSurveyService>().getById(customSurveyId)
          : null;

      if (definition == null) {
        return Scaffold(
          headers: [AppBar(
            title: const Text('Resultados'),
            leading: [IconButton(icon: const Icon(material.Icons.arrow_back), onPressed: () => context.pop(), variance: ButtonVariance.ghost)],
          )],
          child: const Center(child: Text('No se encontró la definición de esta encuesta personalizada.')),
        );
      }

      return Scaffold(
        headers: [AppBar(
          title: Text('Resultados ${definition.title}'),
          leading: [IconButton(icon: const Icon(material.Icons.arrow_back), onPressed: () => context.pop(), variance: ButtonVariance.ghost)],
        )],
        child: CustomSurveyResultView(
          patientName: patientName,
          createdAt: createdAt,
          score: score,
          definition: definition,
          responses: responses ?? [],
          onBack: () => context.pop(),
          onHome: () => context.go('/'),
        ),
      );
    }

    if (surveyType == 6) {
      final assistResults = AssistQuestions.computeFromPersistedResponses(
        List.from(responses ?? []),
      );
      return Scaffold(
        headers: [AppBar(
          title: Text('Resultados $surveyTypeName'),
          leading: [IconButton(icon: const Icon(material.Icons.arrow_back), onPressed: () => context.pop(), variance: ButtonVariance.ghost)],
        )],
        child: AssistResultView(
          patientName: patientName,
          createdAt: createdAt,
          surveyTypeName: surveyTypeName,
          results: assistResults,
          onBack: () => context.pop(),
          onHome: () => context.go('/'),
        ),
      );
    }

    final recommendation = surveyType == 11 && iciqOrientation.isNotEmpty
        ? '${_getRecommendation(baseLevel, surveyType)} Orientacion tipo: ${iciqOrientation.join(', ')}.'
        : _getRecommendation(baseLevel, surveyType);

    return Scaffold(
      headers: [AppBar(
        title: Text('Resultados $surveyTypeName'),
        leading: [IconButton(icon: const Icon(material.Icons.arrow_back), onPressed: () => context.pop(), variance: ButtonVariance.ghost)],
        trailing: [IconButton(
          icon: const Icon(material.Icons.share),
          onPressed: () => showCenteredToast(context,
            title: 'Compartir resultados', subtitle: 'Función próximamente disponible',
            icon: material.Icons.info, iconColor: LightModeColors.lightPrimary, location: ToastLocation.bottomCenter),
          variance: ButtonVariance.ghost,
        )],
      )],
      child: StandardResultView(
        patientName: patientName,
        createdAt: createdAt,
        score: score,
        level: level,
        color: color,
        levelIcon: _getLevelIcon(baseLevel),
        surveyType: surveyType,
        surveyFullName: surveyFullName,
        recommendation: recommendation,
        responses: responses,
        onBack: () => context.pop(),
        onHome: () => context.go('/'),
      ),
    );
  }
}
