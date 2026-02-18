import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/utils/theme.dart';

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
      default:
        return material.Icons.help_outline;
    }
  }

  String _getScoreLevel(int score, int surveyType) {
    if (surveyType == 1) {
      // BDI-II
      if (score <= 13) return 'Mínima';
      if (score <= 19) return 'Leve';
      if (score <= 28) return 'Moderada';
      return 'Severa';
    } else {
      // BAI
      if (score <= 7) return 'Mínima';
      if (score <= 15) return 'Leve';
      if (score <= 25) return 'Moderada';
      return 'Severa';
    }
  }

  String _getRecommendation(String level, int surveyType) {
    final surveyTypeName = surveyType == 1 ? 'depresión' : 'ansiedad';

    switch (level.toLowerCase()) {
      case 'mínima':
      case 'minima':
        return 'Los resultados indican ausencia de síntomas clínicamente relevantes de $surveyTypeName. '
            'Se recomienda mantener hábitos saludables y seguimiento preventivo.';
      case 'leve':
        return 'Los resultados sugieren síntomas leves de $surveyTypeName. '
            'Se recomienda evaluación con un profesional de salud mental y considerar intervenciones psicoterapéuticas.';
      case 'moderada':
        return 'Los resultados indican $surveyTypeName moderada. '
            'Es importante buscar atención profesional. Se recomienda evaluación psiquiátrica y psicoterapia.';
      case 'severa':
        return 'Los resultados sugieren $surveyTypeName severa. '
            'Se requiere atención profesional inmediata. Consulte con un psiquiatra para evaluación y tratamiento integral.';
      default:
        return 'Se recomienda consultar con un profesional de salud mental para una evaluación completa.';
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
    final surveyTypeName = surveyType == 1 ? 'BDI-II' : 'BAI';
    final surveyFullName = surveyType == 1
        ? 'Inventario de Depresión de Beck II'
        : 'Inventario de Ansiedad de Beck';
    final level = _getScoreLevel(score, surveyType);
    final color = _getLevelColor(level);
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
                showToast(
                  context: context,
                  builder: (context, overlay) => SurfaceCard(
                    child: Basic(
                      title: const Text('Compartir resultados'),
                      subtitle: const Text('Función próximamente disponible'),
                      leading: Icon(
                        material.Icons.info,
                        color: LightModeColors.lightPrimary,
                      ),
                    ),
                  ),
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
                    _getLevelIcon(level),
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
              recommendation: _getRecommendation(level, surveyType),
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
    final ranges = surveyType == 1
        ? [
            {'range': '0-13', 'label': 'Depresión mínima', 'color': LightModeColors.lightTertiary},
            {'range': '14-19', 'label': 'Depresión leve', 'color': const Color(0xFFFBBF24)},
            {'range': '20-28', 'label': 'Depresión moderada', 'color': const Color(0xFFF97316)},
            {'range': '29-63', 'label': 'Depresión severa', 'color': LightModeColors.lightError},
          ]
        : [
            {'range': '0-7', 'label': 'Ansiedad mínima', 'color': LightModeColors.lightTertiary},
            {'range': '8-15', 'label': 'Ansiedad leve', 'color': const Color(0xFFFBBF24)},
            {'range': '16-25', 'label': 'Ansiedad moderada', 'color': const Color(0xFFF97316)},
            {'range': '26-63', 'label': 'Ansiedad severa', 'color': LightModeColors.lightError},
          ];

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
                const Text('Interpretación de Puntajes').semiBold().large(),
              ],
            ),
            const Gap(20),
            ...ranges.map((range) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: range['color'] as Color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          '${range['range']}: ${range['label']}',
                          style: const TextStyle(fontSize: 15),
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
                const Text('Detalle de Respuestas').semiBold().large(),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: LightModeColors.lightPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${responses.length} preguntas',
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

