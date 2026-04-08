import 'package:ssapp/features/surveys/presentation/base_survey_controller.dart';
import 'package:ssapp/features/surveys/types/sf36/domain/sf36_questions.dart';
import 'package:ssapp/shared/models/response_model.dart';
import 'package:ssapp/shared/models/survey_model.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';

// Responsabilidad: gestionar estado, cálculo y guardado de la encuesta SF-36.
class SF36Controller extends BaseSurveyController {
  final int patientId;
  final SurveyService? surveyService;

  int _currentIndex = 0;
  final Map<int, double> _responses = {}; // numero de pregunta -> puntuación final
  final Map<int, int> _rawResponses = {}; // numero de pregunta -> índice de opción seleccionada (0 baseddd)
  int? _selectedOptionIndex;
  bool _showingResults = false;

  // variable para almacenar la respuesta del ítem 7, que afecta el cálculo del ítem 8
  int? _item7Response;

  SF36Controller({
    required this.patientId,
    this.surveyService,
  });

  int get currentIndex => _currentIndex;
  Map<int, double> get responses => Map.unmodifiable(_responses);
  Map<int, int> get rawResponses => Map.unmodifiable(_rawResponses);
  int? get selectedOptionIndex => _selectedOptionIndex;
  bool get showingResults => _showingResults;

  List<SF36Question> get questions => SF36Questions.questions;
  SF36Question get currentQuestion => questions[_currentIndex];
  double get progress => (_currentIndex + 1) / questions.length;
  bool get canGoNext => _responses.containsKey(currentQuestion.number);
  bool get canGoPrevious => _currentIndex > 0;
  bool get isLastQuestion => _currentIndex >= questions.length - 1;
  bool get allAnswered => _responses.length == questions.length;

  // seleccionar opción para la pregunta actual, calculando la puntuación final según la configuración de la pregunta
  void selectOption(int questionNumber, int optionIndex) {
    final question = currentQuestion;
    final rawScore = optionIndex + 1; // convertir índice 0-based a puntuación 1-based para cálculos

    _rawResponses[questionNumber] = optionIndex;

    double finalScore;

    if (question.customScoring != null) {
      finalScore = question.customScoring![optionIndex];
    } else if (question.useRawScore) {
      // usar el raw score directamente (1, 2, 3, etc.) sin invertir ni transformar
      finalScore = rawScore.toDouble();
    } else if (question.inverted) {
      // invertir la puntuación: si la opción más alta es la mejor, entonces el score final = maxScore - rawScore + 1
      final maxScore = question.options.length;
      finalScore = (maxScore - optionIndex).toDouble();
    } else {
      // sin configuración especial, usar el raw score directamente
      finalScore = rawScore.toDouble();
    }

    _responses[questionNumber] = finalScore;

    // guardar la respuesta del ítem 7 para usarla en el cálculo del ítem 8
    if (questionNumber == 21) {
      _item7Response = rawScore;
    }

    _selectedOptionIndex = optionIndex;
    notifyListeners();
  }

  bool nextQuestion() {
    if (_currentIndex < questions.length - 1) {
      _currentIndex++;
      _updateSelectedOption();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _updateSelectedOption();
      notifyListeners();
      return true;
    }
    return false;
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      _currentIndex = index;
      _updateSelectedOption();
      notifyListeners();
    }
  }

  void _updateSelectedOption() {
    final questionNumber = currentQuestion.number;
    if (_rawResponses.containsKey(questionNumber)) {
      _selectedOptionIndex = _rawResponses[questionNumber];
    } else {
      _selectedOptionIndex = null;
    }
  }

  // obtener puntuación para una dimensión específica, aplicando la fórmula de transformación SF-36
  double getDimensionScore(SF36Dimension dimension) {
    final dimensionQuestions = SF36Questions.getQuestionsForDimension(dimension);

    if (dimensionQuestions.isEmpty) {
      return 0.0;
    }

    double totalScore = 0;

    for (final q in dimensionQuestions) {
      // el ítem 8 (número 22) tiene una puntuación que depende de la respuesta del ítem 7, así que lo calculamos por separado
      if (q.number == 22 && _item7Response != null) {
        totalScore += _getItem8Score();
      } else if (_responses.containsKey(q.number)) {
        totalScore += _responses[q.number]!;
      }
    }

    // obtener el mínimo posible y el recorrido (rango) para la dimensión, necesarios para la fórmula de transformación
    final rawScoreRange = _getRawScoreRange(dimension);
    final minPossible = rawScoreRange['min'] as double;
    final maxRecorrido = rawScoreRange['recorrido'] as double;

    // aplicar la fórmula de transformación: ((totalScore - minPossible) / maxRecorrido) * 100
    final transformedScore = ((totalScore - minPossible) / maxRecorrido) * 100;

    return transformedScore.clamp(0, 100);
  }

  // obtener el mínimo posible y el recorrido (rango) para cada dimensión, basado en la configuración de los ítems que la componen
  Map<String, double> _getRawScoreRange(SF36Dimension dimension) {
    switch (dimension) {
      case SF36Dimension.physicalFunctioning:
        return {'min': 10.0, 'recorrido': 20.0}; // Sum of 10 items (1-3 each)
      case SF36Dimension.rolePhysical:
        return {'min': 4.0, 'recorrido': 4.0}; // Sum of 4 items (1-2 each)
      case SF36Dimension.bodilypain:
        return {'min': 2.0, 'recorrido': 10.0}; // Items 7+8 (1-6 range)
      case SF36Dimension.generalHealth:
        return {'min': 5.0, 'recorrido': 20.0}; // Items 1+11a+11b+11c+11d
      case SF36Dimension.vitality:
        return {'min': 4.0, 'recorrido': 20.0}; // Items 9a+9e+9g+9i
      case SF36Dimension.socialFunctioning:
        return {'min': 2.0, 'recorrido': 8.0}; // Items 6+10
      case SF36Dimension.roleEmotional:
        return {'min': 3.0, 'recorrido': 3.0}; // Items 5a+5b+5c
      case SF36Dimension.mentalHealth:
        return {'min': 5.0, 'recorrido': 25.0}; // Items 9b+9c+9d+9f+9h
      case SF36Dimension.healthTransition:
        return {'min': 1.0, 'recorrido': 4.0}; // Single item (Item 2)
    }
  }

  // calcular la puntuación del ítem 8, que depende de la respuesta del ítem 7
  double _getItem8Score() {
    if (_item7Response == null || !_responses.containsKey(22)) {
      return 0;
    }

    final item8Raw = _responses[22] ?? 1.0;

    // si el ítem 7 = 1 (no tiene dolor): score = 6
    // si el ítem 7 > 1 (tiene dolor): score = 6 - rawScore del ítem 8, para invertir la puntuación (si el dolor es alto, el score es bajo)
    if (_item7Response == 1) {
      return 6.0; // No pain = 6
    } else {
      // Pain exists: reverse the score
      return (6.0 - item8Raw).clamp(1.0, 6.0);
    }
  }

  Map<String, double> getAllDimensionScores() {
    return {
      'Función Física': getDimensionScore(SF36Dimension.physicalFunctioning),
      'Rol Físico': getDimensionScore(SF36Dimension.rolePhysical),
      'Dolor Corporal': getDimensionScore(SF36Dimension.bodilypain),
      'Salud General': getDimensionScore(SF36Dimension.generalHealth),
      'Vitalidad': getDimensionScore(SF36Dimension.vitality),
      'Función Social': getDimensionScore(SF36Dimension.socialFunctioning),
      'Rol Emocional': getDimensionScore(SF36Dimension.roleEmotional),
      'Salud Mental': getDimensionScore(SF36Dimension.mentalHealth),
    };
  }

  // calcular el score general como el promedio de las 8 dimensiones principales
  double getOverallScore() {
    final scores = getAllDimensionScores();
    final sum = scores.values.fold(0.0, (a, b) => a + b);
    return sum / scores.length;
  }

  // interpretar el score general en categorías de salud
  String getInterpretation() {
    final score = getOverallScore();
    if (score >= 80) {
      return 'Excelente estado de salud general';
    } else if (score >= 60) {
      return 'Buen estado de salud';
    } else if (score >= 40) {
      return 'Salud moderada';
    } else if (score >= 20) {
      return 'Salud deficiente';
    } else {
      return 'Salud muy deficiente';
    }
  }

  void showResults() {
    _showingResults = true;
    notifyListeners();
  }

  /// Save survey to Hive and sync with Supabase
  @override
  Future<SF36SaveResult> saveSurvey() async {
    return executeWithSavingState<SF36SaveResult>(
      alreadySavingResult: SF36SaveResult(
        success: false,
        wasSynced: false,
        error: 'Ya se está guardando la encuesta',
      ),
      action: () async {
        if (patientId == 0) {
          throw Exception('ID de paciente inválido. Por favor, reinicie el proceso.');
        }

        final intResponses = _responses.map(
          (questionId, value) => MapEntry(questionId, value.toInt()),
        );
        final List<ResponseModel> responseModels = buildResponseModels(intResponses);

        if (responseModels.length != questions.length) {
          throw Exception('Faltan respuestas. Por favor, responda todas las preguntas.');
        }

        final survey = SurveyModel(
          surveyId: DateTime.now().millisecondsSinceEpoch,
          surveyType: 5,
          patientId: patientId,
          responses: responseModels,
          synced: false,
        );

        bool wasSynced = false;
        if (surveyService != null) {
          try {
            final saveResult = await surveyService!.saveSurvey(survey);
            wasSynced = saveResult.wasSynced;
          } catch (error) {
            logControllerError('sincronizar encuesta SF-36', error, StackTrace.current);
          }
        }

        return SF36SaveResult(
          success: true,
          wasSynced: wasSynced,
        );
      },
      onError: (error, stackTrace) {
        return SF36SaveResult(
          success: false,
          wasSynced: false,
          error: error.toString(),
        );
      },
      operation: 'guardar encuesta SF-36',
    );
  }

  void resetSurvey() {
    _currentIndex = 0;
    _responses.clear();
    _rawResponses.clear();
    _selectedOptionIndex = null;
    _showingResults = false;
    _item7Response = null;
    notifyListeners();
  }
}

/// Result of survey save operation
class SF36SaveResult {
  final bool success;
  final bool wasSynced;
  final String? error;

  SF36SaveResult({
    required this.success,
    required this.wasSynced,
    this.error,
  });
}

