import 'package:flutter/material.dart' as material show Icons, Material, Navigator, Switch;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/types/assist/presentation/assist_controller.dart';
import 'package:ssapp/features/surveys/types/assist/domain/assist_questions.dart';
import 'package:ssapp/shared/providers/font_size_provider.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';
import 'package:ssapp/shared/widgets/font_size_button.dart';
import 'package:ssapp/shared/widgets/tts/assist_question_tts_bar.dart';

class AssistScreen extends StatefulWidget {
  final int patientId;

  const AssistScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<AssistScreen> createState() => _AssistScreenState();
}

class _AssistScreenState extends State<AssistScreen> {
  late AssistController _controller;
  static const Color _assistColor = Color(0xFF0891B2);
  bool _initialized = false;

  int? _fromInvestigationId() {
    final params = GoRouterState.of(context).uri.queryParameters;
    final raw = params['fromInvestigation'] ?? params['from_investigation'] ?? params['fromInvestigationId'] ?? params['from_investigation_id'];
    return int.tryParse(raw ?? '');
  }

  void _goAfterFinish() {
    final investigationId = _fromInvestigationId();
    if (investigationId != null) {
      context.go('/investigations/$investigationId/apply?completedSurvey=assist&patientId=${widget.patientId}');
      return;
    }
    context.go('/new-survey');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final surveyService = context.read<SurveyService>();
      _controller = AssistController(
        patientId: widget.patientId,
        surveyService: surveyService,
        investigationId: _fromInvestigationId(),
      );
      _controller.addListener(_onControllerUpdate);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      _controller.removeListener(_onControllerUpdate);
      _controller.dispose();
    }
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  String _questionTitle(int questionNumber) {
    switch (questionNumber) {
      case 1:
        return 'P1. ¿Cuáles de estas sustancias ha consumido alguna vez en su vida?';
      case 2:
        return 'P2. Durante los últimos 3 meses, ¿con qué frecuencia ha consumido?';
      case 3:
        return 'P3. Durante los últimos 3 meses, ¿con qué frecuencia ha sentido un fuerte deseo o urgencia de consumir?';
      case 4:
        return 'P4. Durante los últimos 3 meses, ¿con qué frecuencia su consumo le ha causado problemas de salud, sociales, legales o económicos?';
      case 5:
        return 'P5. Durante los últimos 3 meses, ¿con qué frecuencia dejó de hacer lo que normalmente se esperaba de usted debido al consumo?';
      case 6:
        return 'P6. ¿Alguna vez un amigo, familiar o profesional de salud ha mostrado preocupación por su consumo?';
      case 7:
        return 'P7. ¿Alguna vez ha intentado y fallado en controlar, reducir o dejar su consumo?';
      case 8:
        return 'P8. ¿Ha consumido alguna droga por vía inyectada?';
      default:
        return 'Pregunta';
    }
  }

  String _questionSubtitle(int questionNumber) {
    switch (questionNumber) {
      case 1:
        return 'Seleccione Sí o No para cada sustancia';
      case 2:
        return 'Solo para sustancias marcadas en P1';
      case 3:
      case 4:
        return 'Solo para sustancias con frecuencia distinta de Nunca en P2';
      case 5:
        return 'Solo para sustancias con frecuencia distinta de Nunca en P2 (no aplica para tabaco)';
      case 6:
      case 7:
        return 'Aplica a todas las sustancias marcadas en P1';
      case 8:
        return 'Esta respuesta no se suma al puntaje por sustancia';
      default:
        return 'Seleccione una opción por sustancia';
    }
  }

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

  void _nextQuestion() {
    if (_controller.currentQuestionNumber == 1 && !_controller.hasAnySelectedSubstance) {
      _saveSurvey(showResultOption: false, forceNoScoreEnd: true);
      return;
    }

    if (!_controller.isLastQuestion) {
      _controller.nextQuestion();
      return;
    }
    _saveSurvey();
  }

  void _previousQuestion() {
    _controller.previousQuestion();
  }

  Future<void> _saveSurvey({
    bool showResultOption = true,
    bool forceNoScoreEnd = false,
  }) async {
    if (_controller.isSaving) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              Gap(16),
              Text(
                'Guardando encuesta ASSIST...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );

    final result = await _controller.saveSurvey();

    if (mounted) {
      material.Navigator.of(context).pop();
    }

    await Future.delayed(const Duration(milliseconds: 100));

    if (!result.success) {
      if (mounted) {
        showCenteredToast(
          context,
          title: 'Error al guardar',
          subtitle: 'Error: ${result.error}',
          icon: material.Icons.error_outline,
          iconColor: LightModeColors.lightError,
          location: ToastLocation.topCenter,
        );
      }
      return;
    }

    if (mounted && result.results != null) {
      if (forceNoScoreEnd || !_controller.hasAnySelectedSubstance) {
        _showNoScoreEndDialog(result.wasSynced);
      } else {
        _showCompletionDialog(
          result.wasSynced,
          result.results!,
          showResultOption: showResultOption,
        );
      }
    }
  }

  void _showCompletionDialog(
    bool wasSynced,
    AssistComputedResults results, {
    bool showResultOption = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: material.Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(material.Icons.celebration, color: _assistColor, size: 32),
                      const Gap(12),
                      const Expanded(
                        child: Text(
                          '¡Gracias por participar!',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  const Text('La encuesta OMS-ASSIST V3.0 ha sido completada exitosamente.'),
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: wasSynced
                          ? LightModeColors.lightTertiary.withValues(alpha: 0.1)
                          : LightModeColors.lightSecondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: wasSynced
                            ? LightModeColors.lightTertiary
                            : LightModeColors.lightSecondary,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          wasSynced ? material.Icons.cloud_done : material.Icons.cloud_upload,
                          color: wasSynced
                              ? LightModeColors.lightTertiary
                              : LightModeColors.lightSecondary,
                        ),
                        const Gap(10),
                        Expanded(
                          child: Text(
                            wasSynced ? 'Datos sincronizados' : 'Pendiente de sincronización',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),
                  if (showResultOption) ...[
                    const Text(
                      '¿Desea ver su resultado?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlineButton(
                            onPressed: () {
                              material.Navigator.of(context).pop();
                              _goAfterFinish();
                            },
                            child: const Text('No'),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: PrimaryButton(
                            onPressed: () {
                              material.Navigator.of(context).pop();
                              _showResultDialog(results);
                            },
                            child: const Text('Sí'),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        onPressed: () {
                          material.Navigator.of(context).pop();
                          _goAfterFinish();
                        },
                        child: const Text('Finalizar'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNoScoreEndDialog(bool wasSynced) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: material.Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(material.Icons.check_circle, color: _assistColor, size: 30),
                      const Gap(12),
                      const Expanded(
                        child: Text(
                          'Fin de entrevista',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const Gap(14),
                  const Text(
                    'No se reporta consumo de sustancias en P1. La entrevista finaliza sin puntaje.',
                    style: TextStyle(height: 1.5),
                  ),
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: wasSynced
                          ? LightModeColors.lightTertiary.withValues(alpha: 0.1)
                          : LightModeColors.lightSecondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: wasSynced
                            ? LightModeColors.lightTertiary
                            : LightModeColors.lightSecondary,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          wasSynced ? material.Icons.cloud_done : material.Icons.cloud_upload,
                          color: wasSynced
                              ? LightModeColors.lightTertiary
                              : LightModeColors.lightSecondary,
                        ),
                        const Gap(10),
                        Expanded(
                          child: Text(
                            wasSynced ? 'Datos sincronizados' : 'Pendiente de sincronización',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(18),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: () {
                        material.Navigator.of(context).pop();
                        _goAfterFinish();
                      },
                      child: const Text('Finalizar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResultDialog(AssistComputedResults results) {
    final sorted = AssistQuestions.substances
        .where((item) => results.resultsBySubstance.containsKey(item.id))
        .map((item) => results.resultsBySubstance[item.id]!)
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: material.Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(material.Icons.analytics, color: _assistColor, size: 32),
                      const Gap(12),
                      const Expanded(
                        child: Text(
                          'Resultado OMS-ASSIST V3.0',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const Gap(18),
                  if (!results.hasAnyLifetimeUse)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: LightModeColors.lightTertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: LightModeColors.lightTertiary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Text(
                        'No se reporta consumo de sustancias alguna vez en la vida.\nRecomendación: Sin intervención.',
                        style: TextStyle(height: 1.5),
                      ),
                    ),
                  if (results.hasAnyLifetimeUse) ...[
                    const Text(
                      'Puntajes por sustancia consumida',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const Gap(10),
                    ...sorted.map((item) {
                      final color = _riskColor(item.riskLevel);
                      return Container(
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
                  ],
                  if (results.hasInjectedInLast3Months) ...[
                    const Gap(8),
                    Container(
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
                          ),
                          const Gap(10),
                          const Expanded(
                            child: Text(
                              'Advertencia: se reporta uso por vía inyectada en los últimos 3 meses. Se recomienda valoración clínica prioritaria.',
                              style: TextStyle(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Gap(20),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: () {
                        material.Navigator.of(context).pop();
                        _goAfterFinish();
                      },
                      child: const Text('Finalizar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionNumber = _controller.currentQuestionNumber;
    final fs = context.watch<FontSizeProvider>();

    return Scaffold(
      headers: [
        AppBar(
          title: Text('ASSIST V3.0 · Pregunta ${_controller.currentIndex + 1} de ${_controller.activeQuestions.length}'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dlg) => AlertDialog(
                    title: const Text('¿Salir del cuestionario?'),
                    content: const Text('Si sales ahora perderás el progreso. ¿Estás seguro?'),
                    actions: [
                      OutlineButton(
                        onPressed: () => material.Navigator.of(dlg).pop(),
                        child: const Text('Cancelar'),
                      ),
                      DestructiveButton(
                        onPressed: () {
                          material.Navigator.of(dlg).pop();
                          final investigationId = _fromInvestigationId();
                          if (investigationId != null) {
                            context.go('/investigations/$investigationId/apply');
                          } else {
                            context.go('/');
                          }
                        },
                        child: const Text('Salir'),
                      ),
                    ],
                  ),
                );
              },
              variance: ButtonVariance.ghost,
            ),
          ],
          trailing: const [
            FontSizeButton(),
          ],
        ),
      ],
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: const BoxDecoration(color: Color(0xFFE0F2FE)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _controller.progress,
              child: Container(color: _assistColor),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedContainer(
                        backgroundColor: _assistColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.all(20),
                        borderColor: _assistColor.withValues(alpha: 0.3),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _assistColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${_controller.currentIndex + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _questionTitle(questionNumber),
                                    style: TextStyle(fontSize: fs.scaled(17), fontWeight: FontWeight.w600, height: 1.35),
                                  ),
                                  const Gap(6),
                                  Text(
                                    _questionSubtitle(questionNumber),
                                    style: TextStyle(fontSize: fs.scaled(13), color: const Color(0xFF4B5563)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(24),
                      AssistQuestionTtsBar(
                        questionNumber: _controller.currentIndex + 1,
                        totalQuestions: _controller.activeQuestions.length,
                        questionTitle: _questionTitle(questionNumber),
                        relevantSubstances: _controller.requiredSubstancesForQuestion(questionNumber)
                            .isNotEmpty
                            ? _controller.requiredSubstancesForQuestion(questionNumber)
                            : _controller.selectedSubstanceDefinitions,
                      ),
                      const Gap(8),
                      _buildQuestionBody(questionNumber),
                      const Gap(24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_controller.canGoPrevious)
                  Expanded(
                    child: OutlineButton(
                      onPressed: _previousQuestion,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(material.Icons.arrow_back, color: _assistColor, size: 20),
                          const Gap(8),
                          Text('Anterior', style: TextStyle(color: _assistColor)),
                        ],
                      ),
                    ),
                  ),
                if (_controller.canGoPrevious) const Gap(12),
                Expanded(
                  child: PrimaryButton(
                    onPressed: _controller.canGoNext ? _nextQuestion : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_controller.isLastQuestion ? 'Finalizar' : 'Siguiente'),
                        const Gap(8),
                        Icon(
                          _controller.isLastQuestion
                              ? material.Icons.check
                              : material.Icons.arrow_forward,
                          size: 20,
                        ),
                      ],
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

  Widget _buildQuestionBody(int questionNumber) {
    if (questionNumber == 1) {
      return Column(
        children: AssistQuestions.substances.map((substance) {
          final selected = _controller.isSubstanceSelected(substance.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? _assistColor : LightModeColors.lightOutline.withValues(alpha: 0.4),
                width: selected ? 1.6 : 1.0,
              ),
              color: selected ? _assistColor.withValues(alpha: 0.05) : Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(substance.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(2),
                      Text(
                        selected ? 'Sí, consumida alguna vez' : 'No consumida',
                        style: TextStyle(
                          fontSize: 12,
                          color: selected
                              ? _assistColor.withValues(alpha: 0.9)
                              : LightModeColors.lightOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                material.Switch(
                  value: selected,
                  activeThumbColor: _assistColor,
                  onChanged: (value) {
                    _controller.setSubstanceSelection(substance.id, value);
                    showCenteredToast(
                      context,
                      title: 'Respuesta guardada',
                      icon: material.Icons.check_circle,
                      iconColor: _assistColor,
                      location: ToastLocation.topCenter,
                    );
                  },
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    if (questionNumber == 8) {
      return Column(
        children: List.generate(AssistQuestions.p8Options.length, (index) {
          final score = AssistQuestions.p8Scores[index];
          final isSelected = _controller.injectionScore == score;
          return _AssistAnswerCard(
            label: AssistQuestions.p8Options[index],
            selected: isSelected,
            onTap: () {
              _controller.setInjectionScore(score);
              showCenteredToast(
                context,
                title: 'Respuesta guardada',
                icon: material.Icons.check_circle,
                iconColor: _assistColor,
                location: ToastLocation.topCenter,
              );
            },
          );
        }),
      );
    }

    final requiredSubstances = _controller.requiredSubstancesForQuestion(questionNumber);

    if (requiredSubstances.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: LightModeColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Esta pregunta no aplica según las sustancias seleccionadas.',
          style: TextStyle(height: 1.5),
        ),
      );
    }

    final options = (questionNumber == 6 || questionNumber == 7)
        ? AssistQuestions.p67Options
        : AssistQuestions.frequencyOptions;

    final scores = switch (questionNumber) {
      2 => AssistQuestions.p2Scores,
      3 => AssistQuestions.p3Scores,
      4 => AssistQuestions.p4Scores,
      5 => AssistQuestions.p5Scores,
      6 || 7 => AssistQuestions.p67Scores,
      _ => const <int>[],
    };

    return Column(
      children: requiredSubstances.map((substance) {
        final selectedScore = _controller.getAnswerFor(questionNumber, substance.id);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: LightModeColors.lightOutline.withValues(alpha: 0.35)),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(substance.label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Gap(10),
              Column(
                children: List.generate(options.length, (index) {
                  final score = scores[index];
                  final selected = selectedScore == score;
                  return _AssistAnswerCard(
                    label: options[index],
                    selected: selected,
                    onTap: () {
                      _controller.setAnswerFor(questionNumber, substance.id, score);
                      showCenteredToast(
                        context,
                        title: 'Respuesta guardada',
                        icon: material.Icons.check_circle,
                        iconColor: _assistColor,
                        location: ToastLocation.topCenter,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _AssistAnswerCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AssistAnswerCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FontSizeProvider>();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF0891B2) : LightModeColors.lightOutline.withValues(alpha: 0.35),
            width: selected ? 1.6 : 1,
          ),
          color: selected ? const Color(0xFF0891B2).withValues(alpha: 0.08) : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fs.scaled(14),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              const Icon(material.Icons.check_circle, color: Color(0xFF0891B2), size: 20),
          ],
        ),
      ),
    );
  }
}
