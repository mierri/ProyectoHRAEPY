import 'package:flutter/material.dart' as material show Icons, Material;
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/core/logger/app_logger.dart';
import 'package:ssapp/features/surveys/presentation/survey_controller.dart';
import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';
import 'package:ssapp/features/surveys/types/iciq_sf/domain/iciq_sf_questions.dart';
import 'package:ssapp/features/surveys/types/osteoporosis/presentation/osteoporosis_survey_controller.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/presentation/survey_screen/components/multi_select_option_card.dart';
import 'package:ssapp/features/surveys/presentation/survey_screen/components/option_card.dart';
import 'package:ssapp/features/surveys/presentation/survey_screen/components/survey_completion_dialog.dart';
import 'package:ssapp/features/surveys/presentation/survey_screen/components/survey_pagination.dart';
import 'package:ssapp/features/surveys/presentation/survey_screen/components/survey_question_card.dart';
import 'package:ssapp/features/surveys/presentation/survey_screen/components/survey_result_dialog.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';
import 'package:ssapp/shared/widgets/tts/survey_question_tts_bar.dart';

class SurveyScreen extends StatefulWidget {
  final int patientId;
  final String surveyType; // 'bdi', 'bai', 'gds', 'ghq12', 'phq9', 'lawton', 'katz', 'iciqsf' or 'osteoporosis'

  const SurveyScreen({
    super.key,
    required this.patientId,
    this.surveyType = 'bdi',
  });

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  late SurveyController _controller;
  final Set<int> _iciqSelectedIndices = <int>{};
  bool _isControllerInitialized = false;

  int? _fromInvestigationIdFromParams() {
    final params = GoRouterState.of(context).uri.queryParameters;
    final fromInvestigationStr = params['fromInvestigation'] ?? params['from_investigation'] ?? params['fromInvestigationId'] ?? params['from_investigation_id'];
    return int.tryParse(fromInvestigationStr ?? '');
  }

  @override
  void initState() {
    super.initState();
    // Do not access context here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isControllerInitialized) {
      final surveyService = context.read<SurveyService>();
      double? weight;
      double? height;
      if (widget.surveyType == 'osteoporosis') {
        final params = GoRouterState.of(context).uri.queryParameters;
        final weightStr = params['weight'];
        final heightStr = params['height'];

        if (weightStr != null && weightStr.isNotEmpty) {
          weight = double.tryParse(weightStr);
        }
        if (heightStr != null && heightStr.isNotEmpty) {
          height = double.tryParse(heightStr);
        }

          AppLogger.debug('Extracted weight=$weight, height=$height from params');
      }
      final fromInvestigationId = _fromInvestigationIdFromParams();
      _controller = widget.surveyType == 'osteoporosis'
          ? OsteoporosisSurveyController(
              patientId: widget.patientId,
              surveyService: surveyService,
              investigationId: fromInvestigationId,
              initialWeight: weight,
              initialHeight: height,
            )
          : SurveyController(
              patientId: widget.patientId,
              surveyType: widget.surveyType,
              surveyService: surveyService,
              investigationId: fromInvestigationId,
              initialWeight: weight,
              initialHeight: height,
            );
      _controller.addListener(_onControllerUpdate);
      _isControllerInitialized = true;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    final isIciqQ4 = widget.surveyType == 'iciqsf' &&
        _controller.currentQuestion.number == 4;
    if (isIciqQ4) {
      final mask = _controller.responses[4] ?? 0;
      final selected = <int>{};
      for (final situation in IciqSfLeakSituation.values) {
        if ((mask & (1 << situation.index)) != 0) {
          selected.add(situation.index);
        }
      }
      _iciqSelectedIndices
        ..clear()
        ..addAll(selected);
    }
    if (mounted) setState(() {});
  }

  Color get _surveyColor {
    if (widget.surveyType == 'bai') {
      return LightModeColors.lightTertiary;
    }
    if (widget.surveyType == 'gds') {
      return const Color(0xFF0EA5E9);
    }
    if (widget.surveyType == 'ghq12') {
      return const Color(0xFF0284C7);
    }
    if (widget.surveyType == 'phq9') {
      return const Color(0xFF9333EA);
    }
    if (widget.surveyType == 'lawton') {
      return const Color(0xFF14B8A6);
    }
    if (widget.surveyType == 'katz') {
      return const Color(0xFF0D9488);
    }
    if (widget.surveyType == 'iciqsf') {
      return const Color(0xFF2563EB);
    }
    if (widget.surveyType == 'osteoporosis') {
      return const Color(0xFF145374);
    }
    return LightModeColors.lightPrimary;
  }

  Future<void> _saveSurvey() async {
    if (!_isControllerInitialized) {
      if (mounted) {
        showCenteredToast(
          context,
          title: 'Error',
          subtitle: 'El controlador de la encuesta no está listo. Intenta de nuevo.',
          icon: material.Icons.error_outline,
          iconColor: LightModeColors.lightError,
          location: ToastLocation.topCenter,
        );
      }
      return;
    }
    if (_controller.isSaving) return;

    if (mounted) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const Gap(16),
                const Text(
                  'Guardando encuesta...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final result = await _controller.saveSurvey();

    if (mounted) {
      Navigator.of(context).pop();
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

    if (mounted && result.totalScore != null) {
      _showCompletionDialog(result.wasSynced, result.totalScore!, result.interpretation!, result.severityLevel!, result.riskResult, result.weight, result.height);
    }
  }

  void _selectOption(int questionNumber, int score, int optionIndex) {
    _controller.selectOption(questionNumber, score, optionIndex);

    showCenteredToast(
      context,
      title: 'Respuesta guardada',
      icon: material.Icons.check_circle,
      iconColor: LightModeColors.lightPrimary,
      location: ToastLocation.topCenter,
    );

    if (!_controller.isLastQuestion) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _controller.nextQuestion();
        }
      });
    }
  }

  void _toggleIciqSituation(int index) {
    if (_iciqSelectedIndices.contains(index)) {
      _iciqSelectedIndices.remove(index);
    } else {
      _iciqSelectedIndices.add(index);
    }

    var mask = 0;
    for (final selected in _iciqSelectedIndices) {
      mask |= (1 << selected);
    }

    if (mask == 0) {
      _controller.clearResponse(4);
    } else {
      _controller.setRawResponse(4, mask);
    }
  }

  void _nextQuestion() {
    if (!_controller.isLastQuestion) {
      _controller.nextQuestion();
    } else {
      _saveSurvey();
    }
  }

  void _previousQuestion() {
    _controller.previousQuestion();
  }

  void _showCompletionDialog(bool wasSynced, int totalScore, String interpretation, String severityLevel, dynamic riskResult, double? weight, double? height) {
    final params = GoRouterState.of(context).uri.queryParameters;
    final fromInvestigationStr = params['fromInvestigation'] ?? params['from_investigation'] ?? params['fromInvestigationId'] ?? params['from_investigation_id'];
    final fromInvestigationId = int.tryParse(fromInvestigationStr ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SurveyCompletionDialogContent(
        wasSynced: wasSynced,
        onNo: () {
          Navigator.of(ctx).pop();
          if (fromInvestigationId != null) {
            Future.microtask(() => context.go('/investigations/$fromInvestigationId/apply?completedSurvey=${widget.surveyType}&patientId=${widget.patientId}'));
          } else {
            Future.microtask(() => context.go('/new-survey'));
          }
        },
        onYes: () {
          Navigator.of(ctx).pop();
          _showResultDialog(totalScore, interpretation, severityLevel, riskResult, weight, height, fromInvestigationId: fromInvestigationId);
        },
      ),
    );
  }

  void _showResultDialog(int totalScore, String interpretation, String severityLevel, dynamic riskResult, double? weight, double? height, {int? fromInvestigationId}) {
    final Color levelColor;

    if (widget.surveyType == 'bai') {
      // BAI levels
      if (totalScore <= 7) {
        levelColor = LightModeColors.lightTertiary;
      } else if (totalScore <= 15) {
        levelColor = const Color(0xFFFFA726);
      } else if (totalScore <= 25) {
        levelColor = const Color(0xFFFF7043);
      } else {
        levelColor = LightModeColors.lightError;
      }
    } else if (widget.surveyType == 'gds') {
      if (totalScore <= 4) {
        levelColor = LightModeColors.lightTertiary;
      } else {
        levelColor = LightModeColors.lightError;
      }
    } else if (widget.surveyType == 'ghq12') {
      if (totalScore <= 11) {
        levelColor = LightModeColors.lightTertiary;
      } else if (totalScore <= 20) {
        levelColor = const Color(0xFFF59E0B);
      } else if (totalScore <= 27) {
        levelColor = const Color(0xFFF97316);
      } else {
        levelColor = LightModeColors.lightError;
      }
    } else if (widget.surveyType == 'phq9') {
      if (totalScore <= 4) {
        levelColor = LightModeColors.lightTertiary;
      } else if (totalScore <= 9) {
        levelColor = const Color(0xFFFBBF24);
      } else if (totalScore <= 14) {
        levelColor = const Color(0xFFF97316);
      } else if (totalScore <= 19) {
        levelColor = const Color(0xFFDC2626);
      } else {
        levelColor = const Color(0xFFB91C1C);
      }
    } else if (widget.surveyType == 'lawton') {
      if (totalScore == 8) {
        levelColor = LightModeColors.lightTertiary;
      } else {
        levelColor = const Color(0xFFF59E0B);
      }
    } else if (widget.surveyType == 'katz') {
      if (totalScore == 6) {
        levelColor = LightModeColors.lightTertiary;
      } else {
        levelColor = const Color(0xFFF59E0B);
      }
    } else if (widget.surveyType == 'osteoporosis') {
      // Osteoporosis: use risk result to determine color
      if (riskResult != null && riskResult.isApplicable) {
        levelColor = riskResult.isHighRisk ? LightModeColors.lightError : LightModeColors.lightTertiary;
      } else {
        levelColor = const Color(0xFF0EA5E9);
      }
    } else if (widget.surveyType == 'iciqsf') {
      if (totalScore == 0) {
        levelColor = LightModeColors.lightTertiary;
      } else if (totalScore <= 5) {
        levelColor = const Color(0xFFFBBF24);
      } else if (totalScore <= 12) {
        levelColor = const Color(0xFFF97316);
      } else {
        levelColor = LightModeColors.lightError;
      }
    } else {
      // BDI-II levels
      if (totalScore <= 13) {
        levelColor = LightModeColors.lightTertiary;
      } else if (totalScore <= 19) {
        levelColor = const Color(0xFFFFA726);
      } else if (totalScore <= 28) {
        levelColor = const Color(0xFFFF7043);
      } else {
        levelColor = LightModeColors.lightError;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SurveyResultDialogContent(
        totalScore: totalScore,
        interpretation: interpretation,
        severityLevel: severityLevel,
        levelColor: levelColor,
        surveyType: widget.surveyType,
        riskResult: riskResult,
        weight: weight,
        height: height,
        onDismiss: () {
          Navigator.of(ctx).pop();
          if (fromInvestigationId != null) {
            Future.microtask(() => context.go('/investigations/$fromInvestigationId/apply?completedSurvey=${widget.surveyType}&patientId=${widget.patientId}'));
          } else {
            Future.microtask(() => context.go('/new-survey'));
          }
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final question = _controller.currentQuestion;
    final progress = _controller.progress;

    return Scaffold(
      headers: [
        AppBar(
          title: Text('Pregunta ${_controller.currentQuestionIndex + 1} de ${_controller.questions.length}'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              onPressed: () {
                // Mostrar diálogo de confirmación antes de salir
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('¿Salir de la encuesta?'),
                    content: const Text(
                      'Si sales ahora, perderás el progreso de la encuesta. ¿Estás seguro?',
                    ),
                    actions: [
                      OutlineButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Cancelar'),
                      ),
                      DestructiveButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          final fromInvestigationId = _fromInvestigationIdFromParams();
                          if (fromInvestigationId != null) {
                            context.go('/investigations/$fromInvestigationId/apply');
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
        ),
      ],
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: LightModeColors.lightSurfaceVariant,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: _surveyColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SurveyQuestionCard(
                    category: question.category,
                    surveyType: widget.surveyType,
                    questionIndex: _controller.currentQuestionIndex,
                    surveyColor: _surveyColor,
                  ),
                  const Gap(32),
                  Text(
                    widget.surveyType == 'iciqsf' && question.number == 4
                        ? 'Seleccione una o varias situaciones:'
                        : 'Seleccione la opción que mejor describa cómo se ha sentido:',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(24),
                  if (!(widget.surveyType == 'iciqsf' && question.number == 4))
                    SurveyQuestionTtsBar(
                      questionNumber: _controller.currentQuestionIndex + 1,
                      totalQuestions: _controller.questions.length,
                      category: question.category,
                      options: question.options,
                      surveyType: widget.surveyType,
                    ),
                  const Gap(12),
                  if (widget.surveyType == 'iciqsf' && question.number == 4)
                    ...question.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = _iciqSelectedIndices.contains(index);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MultiSelectOptionCard(
                          text: option.text,
                          isSelected: isSelected,
                          surveyColor: _surveyColor,
                          onTap: () => _toggleIciqSituation(index),
                        ),
                      );
                    })
                  else
                    ...question.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = _controller.selectedOptionIndex == index;
                      IconData faceIcon;
                      Color faceColor;

                      if (widget.surveyType == 'osteoporosis') {
                        if (option.score == 1) {
                          faceIcon = Symbols.sentiment_very_dissatisfied;
                          faceColor = const Color(0xFFDC2626);
                        } else {
                          faceIcon = Symbols.sentiment_very_satisfied;
                          faceColor = const Color(0xFF16A34A);
                        }
                      } else {
                        const faceIcons = [
                          Symbols.sentiment_very_satisfied,
                          Symbols.sentiment_satisfied,
                          Symbols.sentiment_dissatisfied,
                          Symbols.sentiment_very_dissatisfied,
                        ];
                        const faceColors = [
                          Color(0xFF16A34A),
                          Color(0xFF65A30D),
                          Color(0xFFF59E0B),
                          Color(0xFFDC2626),
                        ];
                        faceIcon = index < faceIcons.length ? faceIcons[index] : Symbols.sentiment_neutral;
                        faceColor = index < faceColors.length ? faceColors[index] : const Color(0xFF6B7280);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SurveyOptionCard(
                          option: option,
                          isSelected: isSelected,
                          faceIcon: faceIcon,
                          faceColor: faceColor,
                          surveyColor: _surveyColor,
                          onTap: () => _selectOption(
                            question.number,
                            option.score,
                            index,
                          ),
                        ),
                      );
                   }),
                  const Gap(24),
                  // Pagination
                  SurveyPagination(
                    currentIndex: _controller.currentQuestionIndex,
                    totalQuestions: _controller.questions.length,
                    responses: _controller.responses,
                    questions: _controller.questions,
                    surveyColor: _surveyColor,
                    onPageChanged: (index) => _controller.goToQuestion(index),
                  ),
                ],
              ),
            ),
          ),
          SurveyNavBar(
            canGoPrevious: _controller.canGoPrevious,
            canGoNext: _controller.canGoNext,
            isLastQuestion: _controller.isLastQuestion,
            isSaving: _controller.isSaving,
            surveyColor: _surveyColor,
            onPrevious: _previousQuestion,
            onNext: _nextQuestion,
          ),
        ],
      ),
    );
  }
}


