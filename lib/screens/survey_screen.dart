import 'package:flutter/material.dart' as material show Icons, Material;
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/controllers/survey_controller.dart';
import 'package:ssapp/models/bdi_questions.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/utils/theme.dart';
import 'package:ssapp/utils/toast_helper.dart';

class SurveyScreen extends StatefulWidget {
  final int patientId;
  final String surveyType; // 'bdi' or 'bai' - solo para UI

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

  @override
  void initState() {
    super.initState();
    final surveyService = context.read<SurveyService>();
    _controller = SurveyController(
      patientId: widget.patientId,
      surveyType: widget.surveyType,
      surveyService: surveyService,
    );
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  Color get _surveyColor {
    return widget.surveyType == 'bai'
        ? LightModeColors.lightTertiary
        : LightModeColors.lightPrimary;
  }

  Future<void> _saveSurvey() async {
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
      _showCompletionDialog(result.wasSynced, result.totalScore!, result.interpretation!, result.severityLevel!);
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

  void _showCompletionDialog(bool wasSynced, int totalScore, String interpretation, String severityLevel) {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
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
                      Icon(
                        material.Icons.celebration,
                        color: LightModeColors.lightPrimary,
                        size: 32,
                      ),
                      const Gap(12),
                      const Expanded(
                        child: Text(
                          '¡Gracias por participar!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  const Text(
                    'La encuesta ha sido completada exitosamente.',
                    style: TextStyle(fontSize: 15),
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
                        const Gap(12),
                        Expanded(
                          child: Text(
                            wasSynced
                                ? 'Datos sincronizados'
                                : 'Pendiente de sincronización',
                            style: TextStyle(
                              fontSize: 13,
                              color: wasSynced
                                  ? LightModeColors.lightTertiary
                                  : LightModeColors.lightSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),
                  const Text(
                    '¿Desea ver su resultado?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlineButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.go('/new-survey');
                          },
                          child: const Text('No'),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showResultDialog(totalScore, interpretation, severityLevel);
                          },
                          child: const Text('Sí'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResultDialog(int totalScore, String interpretation, String severityLevel) {
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
      builder: (context) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          material.Icons.analytics,
                          color: LightModeColors.lightPrimary,
                          size: 32,
                        ),
                        const Gap(12),
                        const Expanded(
                          child: Text(
                            'Resultado de la Encuesta',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),
                    // Score card
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: levelColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: levelColor,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Puntuación Total',
                              style: TextStyle(
                                fontSize: 13,
                                color: LightModeColors.lightOnSurfaceVariant,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              '$totalScore',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: levelColor,
                              ),
                            ),
                            const Gap(8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: levelColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                severityLevel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(20),
                    // Description
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: LightModeColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                material.Icons.info_outline,
                                size: 20,
                                color: LightModeColors.lightPrimary,
                              ),
                              const Gap(8),
                              const Text(
                                'Interpretación',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const Gap(8),
                          Text(
                            interpretation,
                            style: const TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),
                    // Disclaimer
                    Text(
                      'Nota: Este resultado es orientativo. Para un diagnóstico profesional, consulte con un especialista en salud mental.',
                      style: TextStyle(
                        fontSize: 11,
                        color: LightModeColors.lightOnSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Gap(24),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go('/new-survey');
                        },
                        child: const Text('OK'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
                          context.go('/');
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
                  // Question header card
                  OutlinedContainer(
                    backgroundColor: _surveyColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _surveyColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${_controller.currentQuestionIndex + 1}',
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
                                question.category,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: _surveyColor.withValues(alpha: 0.9),
                                ),
                              ),
                              const Gap(4),
                              Text(
                                widget.surveyType == 'bai'
                                    ? 'Durante la última semana'
                                    : 'Últimas dos semanas incluyendo hoy',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _surveyColor.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(32),
                  const Text(
                    'Seleccione la opción que mejor describa cómo se ha sentido:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(24),
                  ...question.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = _controller.selectedOptionIndex == index;
                    const faceIcons = [
                      Symbols.sentiment_very_satisfied,
                      Symbols.sentiment_satisfied,
                      Symbols.sentiment_dissatisfied,
                      Symbols.sentiment_very_dissatisfied,
                    ];
                    const faceColors = [
                      Color(0xFF16A34A), // green
                      Color(0xFF65A30D), // lime
                      Color(0xFFF59E0B), // amber
                      Color(0xFFDC2626), // red
                    ];
                    final faceIcon = index < faceIcons.length ? faceIcons[index] : Symbols.sentiment_neutral;
                    final faceColor = index < faceColors.length ? faceColors[index] : const Color(0xFF6B7280);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _OptionCard(
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
                  _SurveyPagination(
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
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(24.0),
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
                                Icon(
                                  material.Icons.arrow_back,
                                  color: _surveyColor,
                                  size: 20,
                                ),
                                const Gap(8),
                                Text(
                                  'Anterior',
                                  style: TextStyle(
                                    color: _surveyColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_controller.canGoPrevious) const Gap(12),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: (_controller.canGoNext && !_controller.isSaving)
                              ? _nextQuestion
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_controller.isSaving) ...[
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const Gap(8),
                              ],
                              Text(
                                _controller.isSaving
                                    ? 'Guardando...'
                                    : (_controller.isLastQuestion
                                        ? 'Finalizar'
                                        : 'Siguiente'),
                              ),
                              if (!_controller.isSaving) ...[
                                const Gap(8),
                                Icon(
                                  _controller.isLastQuestion
                                      ? material.Icons.check
                                      : material.Icons.arrow_forward,
                                  size: 20,
                                ),
                              ],
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
}

class _SurveyPagination extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final Map<int, int> responses;
  final List<SurveyQuestion> questions;
  final Color surveyColor;
  final ValueChanged<int> onPageChanged;

  const _SurveyPagination({
    required this.currentIndex,
    required this.totalQuestions,
    required this.responses,
    required this.questions,
    required this.surveyColor,
    required this.onPageChanged,
  });

  static const _answered = Color(0xFF16A34A);
  static const _unanswered = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final answeredCount = responses.length;
    final unansweredCount = totalQuestions - answeredCount;

    return Column(
      children: [
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: _answered, label: '$answeredCount respondidas'),
            const Gap(16),
            _LegendDot(color: _unanswered, label: '$unansweredCount sin responder'),
          ],
        ),
        const Gap(10),
        // Question grid buttons
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: List.generate(totalQuestions, (i) {
            final questionNumber = i + 1;
            final isAnswered = responses.containsKey(questionNumber);
            final isCurrent = i == currentIndex;
            final bgColor = isAnswered ? _answered : _unanswered;

            return GestureDetector(
              onTap: () => onPageChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCurrent ? bgColor : bgColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: bgColor,
                    width: isCurrent ? 2.5 : 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$questionNumber',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isCurrent ? Colors.white : bgColor,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const Gap(5),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _OptionCard extends StatefulWidget {
  final SurveyOption option;
  final bool isSelected;
  final IconData faceIcon;
  final Color faceColor;
  final Color surveyColor;
  final VoidCallback onTap;

  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.faceIcon,
    required this.faceColor,
    required this.surveyColor,
    required this.onTap,
  });

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: OutlinedContainer(
          backgroundColor: widget.isSelected
              ? widget.surveyColor.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          borderColor: widget.isSelected
              ? widget.surveyColor
              : LightModeColors.lightOutline.withValues(alpha: 0.5),
          borderWidth: widget.isSelected ? 2.5 : 1.5,
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? widget.faceColor.withValues(alpha: 0.15)
                      : widget.faceColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isSelected
                        ? widget.faceColor
                        : widget.faceColor.withValues(alpha: 0.4),
                    width: widget.isSelected ? 2 : 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.faceIcon,
                    color: widget.faceColor,
                    size: 26,
                    fill: widget.isSelected ? 1 : 0,
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    widget.option.text,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: widget.isSelected
                          ? widget.surveyColor.withValues(alpha: 0.9)
                          : LightModeColors.lightOnSurface,
                    ),
                  ),
                ),
              ),
              if (widget.isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 6),
                  child: Icon(
                    material.Icons.check_circle,
                    color: widget.surveyColor,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

