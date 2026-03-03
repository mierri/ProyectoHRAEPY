import 'package:flutter/material.dart' as material show Icons, Material;
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/models/bdi_questions.dart';
import 'package:ssapp/models/response_model.dart';
import 'package:ssapp/models/survey_model.dart';
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
  int _currentQuestionIndex = 0;
  final Map<int, int> _responses = {};
  int? _selectedOptionIndex;
  bool _isSaving = false; // Track saving state

  // Get survey type ID based on type string
  int get _surveyTypeId {
    return widget.surveyType == 'bai' ? 2 : 1; // 1=BDI, 2=BAI
  }

  // Get questions based on survey type
  List<SurveyQuestion> get _questions {
    return widget.surveyType == 'bai'
        ? BAIQuestions.questions
        : BDIQuestions.questions;
  }

  // Get survey color based on type
  Color get _surveyColor {
    return widget.surveyType == 'bai'
        ? LightModeColors.lightTertiary
        : LightModeColors.lightPrimary;
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveSurvey() async {
    // Prevent multiple saves
    if (_isSaving) return;

    setState(() => _isSaving = true);

    // Show loading dialog
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

    bool wasSynced = false;

    try {
      // Validate patientId
      if (widget.patientId == 0) {
        throw Exception('ID de paciente inválido. Por favor, reinicie el proceso.');
      }

      // Create response models from the responses map
      final List<ResponseModel> responses = _responses.entries.map((entry) {
        return ResponseModel(
          questionId: entry.key,
          answerValue: entry.value,
        );
      }).toList();

      if (responses.length != 21) {
        throw Exception('Faltan respuestas. Por favor, responda todas las preguntas.');
      }

      final survey = SurveyModel(
        surveyId: DateTime.now().millisecondsSinceEpoch,
        surveyType: _surveyTypeId,
        patientId: widget.patientId,
        responses: responses,
        synced: false,
      );

      Box<SurveyModel> box;
      try {
        box = await Hive.openBox<SurveyModel>('surveys');
      } catch (e) {
        await Hive.deleteBoxFromDisk('surveys');
        box = await Hive.openBox<SurveyModel>('surveys');
      }

      await box.add(survey);

      // Try to sync with Supabase (with timeout to prevent freezing)
      if (mounted) {
        try {
          final surveyService = context.read<SurveyService>();

          // Add timeout to prevent hanging
          wasSynced = await surveyService.syncSurveyToSupabase(survey)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  return false;
                },
              );

          if (wasSynced) {
            survey.synced = true;
            await survey.save();
          } else {
            print('No se pudo sincronizar con Supabase');
          }
        } catch (e) {
          wasSynced = false;
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }

      // Small delay to ensure dialog is closed
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        _showCompletionDialog(wasSynced);
      }
    } catch (e, stackTrace) {
      print('Stack trace: $stackTrace');

      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (popError) {
          print('Error al cerrar diálogo: $popError');
        }
      }

      if (mounted) {
        showCenteredToast(
          context,
          title: 'Error al guardar',
          subtitle: 'Error: ${e.toString()}',
          icon: material.Icons.error_outline,
          iconColor: LightModeColors.lightError,
          location: ToastLocation.topCenter,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _selectOption(int questionNumber, int score, int optionIndex) {
    setState(() {
      _responses[questionNumber] = score;
      _selectedOptionIndex = optionIndex;
    });

    showCenteredToast(
      context,
      title: 'Respuesta guardada',
      icon: material.Icons.check_circle,
      iconColor: LightModeColors.lightPrimary,
      location: ToastLocation.topCenter,
    );

    if (_currentQuestionIndex < _questions.length - 1) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _nextQuestion();
        }
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        final questionNumber = _currentQuestionIndex + 1;
        if (_responses.containsKey(questionNumber)) {
          final savedScore = _responses[questionNumber];
          final question = _questions[_currentQuestionIndex];
          for (int i = 0; i < question.options.length; i++) {
            if (question.options[i].score == savedScore) {
              _selectedOptionIndex = i;
              break;
            }
          }
        }
      });
    } else {
      _saveSurvey();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedOptionIndex = null;
        // Check if this question was already answered
        final questionNumber = _currentQuestionIndex + 1;
        if (_responses.containsKey(questionNumber)) {
          // Find the option index for the saved response
          final savedScore = _responses[questionNumber];
          final question = _questions[_currentQuestionIndex];
          for (int i = 0; i < question.options.length; i++) {
            if (question.options[i].score == savedScore) {
              _selectedOptionIndex = i;
              break;
            }
          }
        }
      });
    }
  }

  void _showCompletionDialog(bool wasSynced) {
    final totalScore = _responses.values.fold<int>(0, (sum, score) => sum + score);

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
                            _showResultDialog(totalScore);
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

  void _showResultDialog(int totalScore) {

    final String level;
    final String levelDescription;
    final Color levelColor;

    if (widget.surveyType == 'bai') {
      // BAI levels
      if (totalScore <= 7) {
        level = 'Ansiedad Mínima';
        levelDescription = 'Los síntomas de ansiedad son mínimos o inexistentes.';
        levelColor = LightModeColors.lightTertiary;
      } else if (totalScore <= 15) {
        level = 'Ansiedad Leve';
        levelDescription = 'Presenta síntomas leves de ansiedad.';
        levelColor = const Color(0xFFFFA726);
      } else if (totalScore <= 25) {
        level = 'Ansiedad Moderada';
        levelDescription = 'Presenta síntomas moderados de ansiedad.';
        levelColor = const Color(0xFFFF7043);
      } else {
        level = 'Ansiedad Severa';
        levelDescription = 'Presenta síntomas severos de ansiedad.';
        levelColor = LightModeColors.lightError;
      }
    } else {
      // BDI-II levels
      if (totalScore <= 13) {
        level = 'Depresión Mínima';
        levelDescription = 'Los síntomas depresivos son mínimos o inexistentes.';
        levelColor = LightModeColors.lightTertiary;
      } else if (totalScore <= 19) {
        level = 'Depresión Leve';
        levelDescription = 'Presenta síntomas leves de depresión.';
        levelColor = const Color(0xFFFFA726);
      } else if (totalScore <= 28) {
        level = 'Depresión Moderada';
        levelDescription = 'Presenta síntomas moderados de depresión.';
        levelColor = const Color(0xFFFF7043);
      } else {
        level = 'Depresión Grave';
        levelDescription = 'Presenta síntomas graves de depresión.';
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
                                level,
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
                            levelDescription,
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
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      headers: [
        AppBar(
          title: Text('Pregunta ${_currentQuestionIndex + 1} de ${_questions.length}'),
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
          // Progress bar
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
                              '${_currentQuestionIndex + 1}',
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
                  // Options
                  ...question.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = _selectedOptionIndex == index;
                    // Sentiment icons from Material Symbols (0=best → 3=worst)
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
                  // rom a ation
                  _SurveyPagination(
                    currentIndex: _currentQuestionIndex,
                    totalQuestions: _questions.length,
                    responses: _responses,
                    questions: _questions,
                    surveyColor: _surveyColor,
                    onPageChanged: (index) {
                      setState(() {
                        _currentQuestionIndex = index;
                        _selectedOptionIndex = null;
                        final questionNumber = index + 1;
                        if (_responses.containsKey(questionNumber)) {
                          final savedScore = _responses[questionNumber];
                          final q = _questions[index];
                          for (int i = 0; i < q.options.length; i++) {
                            if (q.options[i].score == savedScore) {
                              _selectedOptionIndex = i;
                              break;
                            }
                          }
                        }
                      });
                    },
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
                if (_currentQuestionIndex > 0)
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
                      if (_currentQuestionIndex > 0) const Gap(12),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: (_responses.containsKey(_currentQuestionIndex + 1) && !_isSaving)
                              ? _nextQuestion
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isSaving) ...[
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
                                _isSaving
                                    ? 'Guardando...'
                                    : (_currentQuestionIndex < _questions.length - 1
                                        ? 'Siguiente'
                                        : 'Finalizar'),
                              ),
                              if (!_isSaving) ...[
                                const Gap(8),
                                Icon(
                                  _currentQuestionIndex < _questions.length - 1
                                      ? material.Icons.arrow_forward
                                      : material.Icons.check,
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
              // Sentiment face icon
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

