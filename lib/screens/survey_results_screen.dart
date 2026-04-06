import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/models/assist_questions.dart';
import 'package:ssapp/models/iciq_sf_questions.dart';
import 'package:ssapp/models/katz_questions.dart';
import 'package:ssapp/utils/theme.dart';
import 'package:ssapp/utils/toast_helper.dart';

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
      case 'alto':
        return LightModeColors.lightError;
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
      case 4: // MoCA
        return 'MoCA';
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
      case 4: // MoCA
        return 'La evaluación cognitiva ha sido completada. Consulte con su médico para interpretar los resultados en detalle.';
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

    final surveyService = context.watch<SurveyService>();
    final patientService = context.watch<PatientService>();

    final responses = _survey!['responses'] as List?;
    final score = surveyService.calculateSurveyScore(_survey!);
    final surveyType = _survey!['survey_type'] as int? ?? 1;

    String getSurveyFullName(int type) {
      switch (type) {
        case 1: return 'Inventario de Depresión de Beck II';
        case 2: return 'Inventario de Ansiedad de Beck';
        case 3: return 'Cuestionario de Calidad de Vida WHOQOL-BREF';
        case 4: return 'Evaluación Cognitiva Montreal';
        case 5: return 'Encuesta de Salud de 36 Items';
        case 6: return 'OMS-ASSIST V3.0';
        case 7: return 'Escala de Depresión Geriátrica de 15 ítems';
        case 8: return 'Escala de Lawton para Actividades Instrumentales de la Vida Diaria';
        case 9: return 'Cuestionario de Riesgo de Fractura por Osteoporosis';
        case 10: return 'Indice de Katz para Actividades Basicas de la Vida Diaria';
        case 11: return 'International Consultation on Incontinence Questionnaire - Short Form';
        default: return 'Encuesta';
      }
    }

    final surveyTypeName = surveyService.getSurveyTypeName(surveyType);
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

    if (surveyType == 6) {
      final assistResults = AssistQuestions.computeFromPersistedResponses(
        List.from(responses ?? []),
      );

      return Scaffold(
        headers: [
          AppBar(
            title: Text('Resultados $surveyTypeName'),
            leading: [
              IconButton(
                icon: const Icon(material.Icons.arrow_back),
                onPressed: () => context.pop(),
                variance: ButtonVariance.ghost,
              ),
            ],
          ),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PatientInfoCard(patientName: patientName, createdAt: createdAt),
              const Gap(24),
              _AssistResultsCard(results: assistResults),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      onPressed: () => context.pop(),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(material.Icons.arrow_back, size: 20),
                          Gap(8),
                          Text('Volver'),
                        ],
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: PrimaryButton(
                      onPressed: () => context.go('/'),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(material.Icons.home, size: 20),
                          Gap(8),
                          Text('Inicio'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      headers: [
        AppBar(
          title: Text('Resultados $surveyTypeName'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              onPressed: () => context.pop(),
              variance: ButtonVariance.ghost,
            ),
          ],
          trailing: [
            IconButton(
              icon: const Icon(material.Icons.share),
              onPressed: () {
                showCenteredToast(
                  context,
                  title: 'Compartir resultados',
                  subtitle: 'Función próximamente disponible',
                  icon: material.Icons.info,
                  iconColor: LightModeColors.lightPrimary,
                  location: ToastLocation.bottomCenter,
                );
              },
              variance: ButtonVariance.ghost,
            ),
          ],
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del paciente
            _PatientInfoCard(patientName: patientName, createdAt: createdAt),
            const Gap(24),

            // Tarjeta principal de puntaje
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _getLevelIcon(baseLevel),
                    size: 80,
                    color: Colors.white,
                  ),
                  const Gap(16),
                  const Text(
                    'Puntaje Total',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      level,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    surveyFullName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Gap(32),

            // Interpretación de puntajes
            _ScoreInterpretationCard(surveyType: surveyType),
            const Gap(24),

            // Recomendaciones
            _RecommendationsCard(
              level: level,
              recommendation: surveyType == 11 && iciqOrientation.isNotEmpty
                  ? '${_getRecommendation(baseLevel, surveyType)} Orientacion tipo: ${iciqOrientation.join(', ')}.'
                  : _getRecommendation(baseLevel, surveyType),
            ),
            const Gap(24),

            // Detalles de respuestas (opcional)
            if (responses != null && responses.isNotEmpty) ...[
              _ResponseDetailsCard(responses: responses, surveyType: surveyType),
              const Gap(24),
            ],

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlineButton(
                    onPressed: () => context.pop(),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(material.Icons.arrow_back, size: 20),
                        Gap(8),
                        Text('Volver'),
                      ],
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: PrimaryButton(
                    onPressed: () => context.go('/'),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(material.Icons.home, size: 20),
                        Gap(8),
                        Text('Inicio'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientInfoCard extends StatelessWidget {
  final String patientName;
  final DateTime createdAt;

  const _PatientInfoCard({
    required this.patientName,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: LightModeColors.lightPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                material.Icons.person,
                color: LightModeColors.lightPrimary,
                size: 28,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Paciente').muted().small(),
                  const Gap(4),
                  Text(
                    patientName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'Evaluado el ${DateFormat('dd/MM/yyyy HH:mm').format(createdAt)}',
                  ).muted().small(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreInterpretationCard extends StatelessWidget {
  final int surveyType;

  const _ScoreInterpretationCard({required this.surveyType});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> ranges = [];

    switch (surveyType) {
      case 1: // BDI-II
        ranges = [
          {'range': '0-13', 'label': 'Depresión mínima', 'color': LightModeColors.lightTertiary},
          {'range': '14-19', 'label': 'Depresión leve', 'color': const Color(0xFFFBBF24)},
          {'range': '20-28', 'label': 'Depresión moderada', 'color': const Color(0xFFF97316)},
          {'range': '29-63', 'label': 'Depresión severa', 'color': LightModeColors.lightError},
        ];
        break;
      case 2: // BAI
        ranges = [
          {'range': '0-7', 'label': 'Ansiedad mínima', 'color': LightModeColors.lightTertiary},
          {'range': '8-15', 'label': 'Ansiedad leve', 'color': const Color(0xFFFBBF24)},
          {'range': '16-25', 'label': 'Ansiedad moderada', 'color': const Color(0xFFF97316)},
          {'range': '26-63', 'label': 'Ansiedad severa', 'color': LightModeColors.lightError},
        ];
        break;
      case 3: // WHOQOL
        ranges = [
          {'range': '4.0-5.0', 'label': 'Calidad de vida excelente', 'color': LightModeColors.lightTertiary},
          {'range': '3.5-3.9', 'label': 'Calidad de vida muy buena', 'color': const Color(0xFFFBBF24)},
          {'range': '3.0-3.4', 'label': 'Calidad de vida buena', 'color': const Color(0xFFF97316)},
          {'range': '2.5-2.9', 'label': 'Calidad de vida regular', 'color': const Color(0xFFFF7043)},
          {'range': '1.0-2.4', 'label': 'Calidad de vida baja', 'color': LightModeColors.lightError},
        ];
        break;
      case 4: // MoCA
        ranges = [
          {'range': 'N/A', 'label': 'Evaluación cognitiva completada', 'color': const Color(0xFF0EA5E9)},
        ];
        break;
      case 5: // SF-36
        ranges = [
          {'range': '4.0-5.0', 'label': 'Salud excelente', 'color': LightModeColors.lightTertiary},
          {'range': '3.5-3.9', 'label': 'Salud muy buena', 'color': const Color(0xFFFBBF24)},
          {'range': '3.0-3.4', 'label': 'Salud buena', 'color': const Color(0xFFF97316)},
          {'range': '2.5-2.9', 'label': 'Salud regular', 'color': const Color(0xFFFF7043)},
          {'range': '1.0-2.4', 'label': 'Salud baja', 'color': LightModeColors.lightError},
        ];
        break;
      case 7: // GDS-15
        ranges = [
          {'range': '0-4', 'label': 'Normal', 'color': LightModeColors.lightTertiary},
          {'range': '5-15', 'label': 'Síntomas depresivos', 'color': LightModeColors.lightError},
        ];
        break;
      case 8: // Lawton
        ranges = [
          {'range': '8', 'label': 'Independencia total', 'color': LightModeColors.lightTertiary},
          {'range': '0-7', 'label': 'Deterioro funcional', 'color': const Color(0xFFF59E0B)},
        ];
        break;
      case 9:
        ranges = [
          {'range': '0-2', 'label': 'Bajo riesgo de osteoporosis', 'color': LightModeColors.lightTertiary},
          {'range': '3-5', 'label': 'Riesgo moderado de osteoporosis', 'color': const Color(0xFFF59E0B)},
          {'range': '6-10', 'label': 'Alto riesgo de osteoporosis', 'color': LightModeColors.lightError},
        ];
        break;
      case 10: // Katz ABVD
        ranges = [
          {'range': '6', 'label': 'Independencia total', 'color': LightModeColors.lightTertiary},
          {'range': '0-5', 'label': 'Dependencia en algún grado', 'color': const Color(0xFFF59E0B)},
          {'range': 'A-H', 'label': 'Clasificación alfabética Katz', 'color': LightModeColors.lightSecondary},
        ];
        break;
      case 11: // ICIQ-SF
        ranges = [
          {'range': '0', 'label': 'Sin incontinencia', 'color': LightModeColors.lightTertiary},
          {'range': '1-5', 'label': 'Impacto leve', 'color': const Color(0xFFFBBF24)},
          {'range': '6-12', 'label': 'Impacto moderado', 'color': const Color(0xFFF97316)},
          {'range': '13-21', 'label': 'Impacto severo', 'color': LightModeColors.lightError},
        ];
        break;
      default:
        ranges = [];
    }

    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  material.Icons.info_outline,
                  color: LightModeColors.lightPrimary,
                ),
                const Gap(12),
                Expanded(
                  child: const Text('Interpretación de Puntajes').semiBold().large(),
                ),
              ],
            ),
            const Gap(20),
            ...ranges.map((range) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: range['color'] as Color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          '${range['range']}: ${range['label']}',
                          style: const TextStyle(fontSize: 14),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  final String level;
  final String recommendation;

  const _RecommendationsCard({
    required this.level,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LightModeColors.lightSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LightModeColors.lightSecondary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                material.Icons.lightbulb_outline,
                color: LightModeColors.lightSecondary,
                size: 28,
              ),
              const Gap(12),
              const Text('Recomendaciones').semiBold().large(),
            ],
          ),
          const Gap(16),
          Text(
            recommendation,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const Gap(16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LightModeColors.lightError.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: LightModeColors.lightError.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  material.Icons.warning_amber,
                  size: 20,
                  color: LightModeColors.lightError,
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    'Nota: Esta evaluación no sustituye un diagnóstico profesional. '
                    'Consulte con un especialista en salud mental.',
                    style: TextStyle(
                      fontSize: 13,
                      color: LightModeColors.lightError,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseDetailsCard extends StatelessWidget {
  final List responses;
  final int surveyType;

  const _ResponseDetailsCard({
    required this.responses,
    required this.surveyType,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  material.Icons.assignment_outlined,
                  color: LightModeColors.lightPrimary,
                ),
                const Gap(12),
                Expanded(
                  child: Text('Detalle de Respuestas').semiBold().large(),
                ),
                const Gap(8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: LightModeColors.lightPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${responses.length} preg.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: LightModeColors.lightPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            const Divider(),
            const Gap(16),
            Text(
              'Total de respuestas: ${responses.length}',
              style: const TextStyle(fontSize: 14),
            ).muted(),
            const Gap(8),
            Text(
              'Puntaje promedio por pregunta: ${(responses.fold<int>(0, (sum, r) => sum + (r['answer_value'] as int? ?? 0)) / responses.length).toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 14),
            ).muted(),
          ],
        ),
      ),
    );
  }
}

class _AssistResultsCard extends StatelessWidget {
  final AssistComputedResults results;

  const _AssistResultsCard({required this.results});

  Color _riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'bajo':
        return LightModeColors.lightTertiary;
      case 'moderado':
        return const Color(0xFFF59E0B);
      case 'alto':
        return LightModeColors.lightError;
      default:
        return LightModeColors.lightSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderedResults = AssistQuestions.substances
        .where((item) => results.resultsBySubstance.containsKey(item.id))
        .map((item) => results.resultsBySubstance[item.id]!)
        .toList();

    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(material.Icons.medication_outlined, color: LightModeColors.lightSecondary),
                const Gap(10),
                Expanded(child: Text('Resultados OMS-ASSIST V3.0').semiBold().large()),
              ],
            ),
            const Gap(14),
            if (!results.hasAnyLifetimeUse)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: LightModeColors.lightTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: LightModeColors.lightTertiary.withValues(alpha: 0.4),
                  ),
                ),
                child: const Text('No se reporta consumo de sustancias alguna vez en la vida. Recomendación: Sin intervención.'),
              ),
            ...orderedResults.map((item) {
              final color = _riskColor(item.riskLevel);
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.substance.label,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.riskLevel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(6),
                    Text('Puntaje: ${item.score}'),
                    const Gap(2),
                    Text('Intervención: ${item.recommendation}'),
                  ],
                ),
              );
            }),
            if (results.hasInjectedInLast3Months)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: LightModeColors.lightError.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: LightModeColors.lightError.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      material.Icons.warning_amber,
                      color: LightModeColors.lightError,
                      size: 20,
                    ),
                    const Gap(10),
                    const Expanded(
                      child: Text(
                        'Advertencia: uso por vía inyectada en los últimos 3 meses. Se recomienda valoración clínica prioritaria.',
                        style: TextStyle(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

