import 'package:flutter/material.dart' as material show Icons, Material;
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ssapp/features/surveys/presentation/sf36_controller.dart';
import 'package:ssapp/features/surveys/types/sf36/domain/sf36_questions.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';

class SF36Screen extends StatefulWidget {
  final int patientId;

  const SF36Screen({
    super.key,
    required this.patientId,
  });

  @override
  State<SF36Screen> createState() => _SF36ScreenState();
}

class _SF36ScreenState extends State<SF36Screen> {
  late SF36Controller _controller;

  @override
  void initState() {
    super.initState();
    final surveyService = context.read<SurveyService>();
    _controller = SF36Controller(
      patientId: widget.patientId,
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

  final Color _surveyColor = const Color(0xFF06B6D4); // Indigo 600

  void _selectOption(int questionNumber, int optionIndex) {
    _controller.selectOption(questionNumber, optionIndex);

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
      _showCompletionDialog();
    }
  }

  void _previousQuestion() {
    _controller.previousQuestion();
  }

  void _showCompletionDialog() {
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
                            _saveSurvey(showResults: false);
                          },
                          child: const Text('No'),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _saveSurvey(showResults: true);
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

  Future<void> _saveSurvey({required bool showResults}) async {
    // Mostrar diálogo de guardado
    if (!mounted) return;

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
                'Guardando encuesta SF-36...',
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

    final result = await _controller.saveSurvey();

    if (mounted) {
      Navigator.of(context).pop(); // Cerrar diálogo de carga
    }

    await Future.delayed(const Duration(milliseconds: 100));

    if (!result.success) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('No se pudo guardar la encuesta: ${result.error}'),
            actions: [
              PrimaryButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Guardar exitosamente
    if (mounted && showResults) {
      _showResultDialog();
    } else if (mounted) {
      context.go('/new-survey');
    }
  }

  void _showResultDialog() {
    final overallScore = _controller.getOverallScore();
    final interpretation = _controller.getInterpretation();
    final Color levelColor = _getColorForScore(overallScore);

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
                              'Puntuación General',
                              style: TextStyle(
                                fontSize: 13,
                                color: LightModeColors.lightOnSurfaceVariant,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              overallScore.toStringAsFixed(1),
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
                              child: const Text(
                                'Escala 0-100',
                                style: TextStyle(
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
                    Text(
                      'Dimensiones',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: LightModeColors.lightOnSurfaceVariant,
                      ),
                    ),
                    const Gap(12),
                    ..._buildDimensionsList(),
                    const Gap(16),
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
                    Text(
                      'Nota: Este resultado es orientativo. Para una evaluación profesional completa, consulte con un especialista en salud.',
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

  List<Widget> _buildDimensionsList() {
    final scores = _controller.getAllDimensionScores();
    return scores.entries.map((entry) {
      final color = _getColorForScore(entry.value);
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                entry.key,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color, width: 1),
              ),
              child: Center(
                child: Text(
                  entry.value.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getColorForScore(double score) {
    if (score >= 80) {
      return LightModeColors.lightTertiary;
    } else if (score >= 60) {
      return const Color(0xFFFFA726);
    } else if (score >= 40) {
      return const Color(0xFFFF7043);
    } else {
      return LightModeColors.lightError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _controller.currentQuestion;
    final progress = _controller.progress;

    return Scaffold(
      headers: [
        AppBar(
          title: Text('Pregunta ${_controller.currentIndex + 1} de ${_controller.questions.length}'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              onPressed: () {
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
                  // Dimension badge (igual que WHOQOL)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _surveyColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _surveyColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(material.Icons.category, color: _surveyColor, size: 16),
                        const Gap(6),
                        Text(
                          _getDimensionName(question.dimension),
                          style: TextStyle(
                            color: _surveyColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(16),
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
                                _getDimensionName(question.dimension),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: _surveyColor.withValues(alpha: 0.9),
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'Últimas 4 semanas',
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
                  Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  const Gap(24),
                  // Options
                  ..._buildOptions(),
                  const Gap(24),
                  // Pagination
                  _SurveyPagination(
                    currentIndex: _controller.currentIndex,
                    totalQuestions: _controller.questions.length,
                    responses: _controller.responses,
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
                    onPressed: _controller.canGoNext ? _nextQuestion : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _controller.isLastQuestion ? 'Finalizar' : 'Siguiente',
                        ),
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

  String _getDimensionName(SF36Dimension dimension) {
    switch (dimension) {
      case SF36Dimension.physicalFunctioning:
        return 'Función Física';
      case SF36Dimension.rolePhysical:
        return 'Rol Físico';
      case SF36Dimension.bodilypain:
        return 'Dolor Corporal';
      case SF36Dimension.generalHealth:
        return 'Salud General';
      case SF36Dimension.vitality:
        return 'Vitalidad';
      case SF36Dimension.socialFunctioning:
        return 'Función Social';
      case SF36Dimension.roleEmotional:
        return 'Rol Emocional';
      case SF36Dimension.mentalHealth:
        return 'Salud Mental';
      case SF36Dimension.healthTransition:
        return 'Evolución de Salud';
    }
  }

  // ...existing code...
  List<Widget> _buildOptions() {
    final options = _controller.currentQuestion.options;
    final questionNumber = _controller.currentQuestion.number;

    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      final isSelected = _controller.selectedOptionIndex == index;

      // determinar si la escala es triste-feliz o feliz-triste para esta pregunta
      final isSadScale = _shouldShowSadFirstScale(questionNumber);

      final faceIcon = _getFaceIcon(index, isSadScale);
      final faceColor = _getFaceColor(index, isSadScale);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _OptionCard(
          option: option,
          isSelected: isSelected,
          faceIcon: faceIcon,
          faceColor: faceColor,
          surveyColor: _surveyColor,
          onTap: () => _selectOption(questionNumber, index),
        ),
      );
    }).toList();
  }

  // determinar el orden de las caras (triste-feliz o feliz-triste) según el número de pregunta, basado en la estructura del cuestionario
  // usando el campo SF36Question.number para mapear cada pregunta a su escala correspondiente, ya que el orden de las opciones varía entre preguntas
  // devuelve true si la escala debe mostrar primero la cara triste (triste-feliz), o false si debe mostrar primero la cara feliz (feliz-triste)
  bool _shouldShowSadFirstScale(int questionNumber) {
    // mapeo basado en la estructura del cuestionario:
    // Q1-Q2 (1-2): feliz-triste (false)
    // Q3-Q12 (3-12): 3a-3j = triste-feliz (true)
    // Q13-Q16 (13-16): 4a-4d = triste-feliz (true)
    // Q17-Q19 (17-19): 5a-5c = triste-feliz (true)
    // Q20 (20): 6 = feliz-triste (false)
    // Q21 (21): 7 = feliz-triste (false)
    // Q22 (22): 8 = feliz-triste (false)
    // Q23 (23): 9a = feliz-triste (false) - pero inverted en modelo
    // Q24 (24): 9b = triste-feliz (true) - NOT inverted
    // Q25 (25): 9c = triste-feliz (true) - NOT inverted
    // Q26 (26): 9d = feliz-triste (false) - pero inverted en modelo
    // Q27 (27): 9e = feliz-triste (false) - pero inverted en modelo
    // Q28 (28): 9f = triste-feliz (true) - NOT inverted
    // Q29 (29): 9g = triste-feliz (true) - NOT inverted
    // Q30 (30): 9h = feliz-triste (false) - pero inverted en modelo
    // Q31 (31): 9i = triste-feliz (true) - NOT inverted
    // Q32 (32): 10 = triste-feliz (true) - NOT inverted
    // Q33 (33): 11a = triste-feliz (true) - NOT inverted
    // Q34 (34): 11b = feliz-triste (false) - pero inverted en modelo
    // Q35 (35): 11c = triste-feliz (true) - NOT inverted
    // Q36 (36): 11d = feliz-triste (false) - pero inverted en modelo

    switch (questionNumber) {
      // Q1-Q2: feliz-triste
      case 1:
      case 2:
        return false;
      // Q3-Q12 (3a-3j): triste-feliz
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      case 10:
      case 11:
      case 12:
        return true;
      // Q13-Q16 (4a-4d): triste-feliz (Sí=triste, No=feliz)
      case 13:
      case 14:
      case 15:
      case 16:
        return true;
      // Q17-Q19 (5a-5c): triste-feliz (Sí=triste, No=feliz)
      case 17:
      case 18:
      case 19:
        return true;
      // Q20 (6): feliz-triste
      case 20:
        return false;
      // Q21 (7): feliz-triste
      case 21:
        return false;
      // Q22 (8): feliz-triste
      case 22:
        return false;
      // Q23 (9a): feliz-triste (inverted in model)
      case 23:
        return false;
      // Q24 (9b): triste-feliz (NOT inverted)
      case 24:
        return true;
      // Q25 (9c): triste-feliz (NOT inverted)
      case 25:
        return true;
      // Q26 (9d): feliz-triste (inverted in model)
      case 26:
        return false;
      // Q27 (9e): feliz-triste (inverted in model)
      case 27:
        return false;
      // Q28 (9f): triste-feliz (NOT inverted)
      case 28:
        return true;
      // Q29 (9g): triste-feliz (NOT inverted)
      case 29:
        return true;
      // Q30 (9h): feliz-triste (inverted in model)
      case 30:
        return false;
      // Q31 (9i): triste-feliz (NOT inverted)
      case 31:
        return true;
      // Q32 (10): triste-feliz (NOT inverted)
      case 32:
        return true;
      // Q33 (11a): triste-feliz (NOT inverted)
      case 33:
        return true;
      // Q34 (11b): feliz-triste (inverted in model)
      case 34:
        return false;
      // Q35 (11c): triste-feliz (NOT inverted)
      case 35:
        return true;
      // Q36 (11d): feliz-triste (inverted in model)
      case 36:
        return false;
      default:
        return false;
    }
  }

  IconData _getFaceIcon(int optionIndex, bool isSadScale) {
    final question = _controller.currentQuestion;
    final isYesNo = question.options.length == 2;
    final isThreeOptions = question.options.length == 3;

    if (isYesNo) {
      // Para preguntas de Sí/No: solo dos caras extremas
      if (isSadScale) {
        // triste-feliz: No=triste, Sí=feliz
        return optionIndex == 0
          ? Symbols.sentiment_very_dissatisfied
          : Symbols.sentiment_very_satisfied;
      } else {
        // feliz-triste: Sí=feliz, No=triste
        return optionIndex == 0
          ? Symbols.sentiment_very_satisfied
          : Symbols.sentiment_very_dissatisfied;
      }
    }

    if (isThreeOptions) {
      // Para preguntas de 3 opciones (limitación): triste, neutral, feliz
      if (isSadScale) {
        // triste-feliz: 0=triste, 1=neutral, 2=feliz
        switch (optionIndex) {
          case 0: return Symbols.sentiment_dissatisfied;      // Triste
          case 1: return Symbols.sentiment_neutral;           // Neutral
          case 2: return Symbols.sentiment_satisfied;         // Feliz
          default: return Symbols.sentiment_neutral;
        }
      } else {
        // feliz-triste: 0=feliz, 1=neutral, 2=triste
        switch (optionIndex) {
          case 0: return Symbols.sentiment_satisfied;         // Feliz
          case 1: return Symbols.sentiment_neutral;           // Neutral
          case 2: return Symbols.sentiment_dissatisfied;      // Triste
          default: return Symbols.sentiment_neutral;
        }
      }
    }

    // Para preguntas con más opciones
    if (isSadScale) {
      // Escala: 1=triste, máx=feliz
      switch (optionIndex) {
        case 0: return Symbols.sentiment_very_dissatisfied;
        case 1: return Symbols.sentiment_dissatisfied;
        case 2: return Symbols.sentiment_neutral;
        case 3: return Symbols.sentiment_satisfied;
        case 4: return Symbols.sentiment_very_satisfied;
        case 5: return Symbols.sentiment_very_satisfied;
        default: return Symbols.sentiment_neutral;
      }
    } else {
      // Escala: 1=feliz, máx=triste
      switch (optionIndex) {
        case 0: return Symbols.sentiment_very_satisfied;
        case 1: return Symbols.sentiment_satisfied;
        case 2: return Symbols.sentiment_neutral;
        case 3: return Symbols.sentiment_dissatisfied;
        case 4: return Symbols.sentiment_very_dissatisfied;
        case 5: return Symbols.sentiment_very_dissatisfied;
        default: return Symbols.sentiment_neutral;
      }
    }
  }

  Color _getFaceColor(int optionIndex, bool isSadScale) {
    final question = _controller.currentQuestion;
    final isYesNo = question.options.length == 2;
    final isThreeOptions = question.options.length == 3;

    if (isYesNo) {
      // Para preguntas de Sí/No: colores extremos
      if (isSadScale) {
        // triste-feliz: No=rojo (muy malo), Sí=verde (muy bueno)
        return optionIndex == 0
          ? const Color(0xFFDC2626)  // Rojo: muy malo
          : LightModeColors.lightTertiary;  // Verde: muy bueno
      } else {
        // feliz-triste: Sí=verde (muy bueno), No=rojo (muy malo)
        return optionIndex == 0
          ? LightModeColors.lightTertiary  // Verde: muy bueno
          : const Color(0xFFDC2626);  // Rojo: muy malo
      }
    }

    if (isThreeOptions) {
      // Para preguntas de 3 opciones (limitación): rojo, naranja, verde
      if (isSadScale) {
        // triste-feliz: 0=rojo, 1=naranja, 2=verde
        switch (optionIndex) {
          case 0: return const Color(0xFFDC2626);     // Rojo: triste
          case 1: return const Color(0xFFFFA726);     // Naranja: neutral
          case 2: return LightModeColors.lightTertiary; // Verde: feliz
          default: return Colors.gray;
        }
      } else {
        // feliz-triste: 0=verde, 1=naranja, 2=rojo
        switch (optionIndex) {
          case 0: return LightModeColors.lightTertiary; // Verde: feliz
          case 1: return const Color(0xFFFFA726);     // Naranja: neutral
          case 2: return const Color(0xFFDC2626);     // Rojo: triste
          default: return Colors.gray;
        }
      }
    }

    // Para preguntas con más opciones
    if (isSadScale) {
      // Escala invertida: 1=rojo (malo), máx=verde (bueno)
      switch (optionIndex) {
        case 0: return const Color(0xFFDC2626); // Rojo: muy malo
        case 1: return const Color(0xFFFF7043); // Naranja oscuro: malo
        case 2: return const Color(0xFFFFA726); // Naranja: neutral
        case 3: return const Color(0xFF90EE90); // Verde claro: bueno
        case 4: return LightModeColors.lightTertiary; // Verde: muy bueno
        case 5: return LightModeColors.lightTertiary; // Verde: muy bueno
        default: return Colors.gray;
      }
    } else {
      // Escala normal: 1=verde (bueno), máx=rojo (malo)
      switch (optionIndex) {
        case 0: return LightModeColors.lightTertiary; // Verde: muy bueno
        case 1: return const Color(0xFF90EE90); // Verde claro: bueno
        case 2: return const Color(0xFFFFA726); // Naranja: neutral
        case 3: return const Color(0xFFFF7043); // Naranja oscuro: malo
        case 4: return const Color(0xFFDC2626); // Rojo: muy malo
        case 5: return const Color(0xFFDC2626); // Rojo: muy malo
        default: return Colors.gray;
      }
    }
  }
}

class _SurveyPagination extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final Map<int, double> responses;
  final Color surveyColor;
  final ValueChanged<int> onPageChanged;

  const _SurveyPagination({
    required this.currentIndex,
    required this.totalQuestions,
    required this.responses,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: _answered, label: '$answeredCount respondidas'),
            const Gap(16),
            _LegendDot(color: _unanswered, label: '$unansweredCount sin responder'),
          ],
        ),
        const Gap(10),
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
  final String option;
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
                    widget.option,
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
                  padding: const EdgeInsets.only(left: 8),
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

