import 'package:flutter/material.dart';
import 'package:ssapp/models/assist_questions.dart';
import 'package:ssapp/models/response_model.dart';
import 'package:ssapp/models/survey_model.dart';
import 'package:ssapp/Services/survey_service.dart';

class AssistController extends ChangeNotifier {
  final int patientId;
  final SurveyService surveyService;

  int _currentIndex = 0;
  bool _isSaving = false;

  final Set<int> _selectedSubstances = {};
  final Map<int, Map<int, int>> _answersByQuestion = {
    2: {},
    3: {},
    4: {},
    5: {},
    6: {},
    7: {},
  };

  int? _injectionScore;

  AssistController({
    required this.patientId,
    required this.surveyService,
  });

  int get currentIndex => _currentIndex;
  bool get isSaving => _isSaving;
  Set<int> get selectedSubstances => Set.unmodifiable(_selectedSubstances);
  int? get injectionScore => _injectionScore;

  bool get hasAnySelectedSubstance => _selectedSubstances.isNotEmpty;

  bool get _isP2Complete {
    if (_selectedSubstances.isEmpty) return false;
    final answers = _answersByQuestion[2] ?? {};
    for (final substanceId in _selectedSubstances) {
      if (!answers.containsKey(substanceId)) return false;
    }
    return true;
  }

  Set<int> get p2PositiveSubstanceIds {
    final answers = _answersByQuestion[2] ?? {};
    return _selectedSubstances
        .where((substanceId) => (answers[substanceId] ?? 0) > 0)
        .toSet();
  }

  bool get hasAnyP2Use => p2PositiveSubstanceIds.isNotEmpty;

  bool get hasAnyP2SubstanceForP5 {
    final positiveIds = p2PositiveSubstanceIds;
    for (final item in AssistQuestions.substances) {
      if (positiveIds.contains(item.id) && item.appliesP5) {
        return true;
      }
    }
    return false;
  }

  List<int> get activeQuestions {
    if (_selectedSubstances.isEmpty) return const [1];

    // Hasta terminar P2 mantenemos la estructura completa para evitar saltos
    // mientras el usuario aún responde frecuencias.
    if (!_isP2Complete) {
      return const [1, 2, 3, 4, 5, 6, 7, 8];
    }

    // Si en P2 todas son Nunca, se salta a P6, P7, P8.
    if (!hasAnyP2Use) {
      return const [1, 2, 6, 7, 8];
    }

    // Si hay uso en P2, mostrar P3 y P4; P5 solo si hay sustancias aplicables.
    if (hasAnyP2SubstanceForP5) {
      return const [1, 2, 3, 4, 5, 6, 7, 8];
    }

    return const [1, 2, 3, 4, 6, 7, 8];
  }

  int get currentQuestionNumber => activeQuestions[_currentIndex];
  bool get canGoPrevious => _currentIndex > 0;
  bool get isLastQuestion => _currentIndex >= activeQuestions.length - 1;
  double get progress => (_currentIndex + 1) / activeQuestions.length;

  List<AssistSubstance> get selectedSubstanceDefinitions {
    return AssistQuestions.substances
        .where((item) => _selectedSubstances.contains(item.id))
        .toList();
  }

  List<AssistSubstance> requiredSubstancesForQuestion(int questionNumber) {
    if (_selectedSubstances.isEmpty) return const [];

    if (questionNumber == 5) {
      final positiveIds = p2PositiveSubstanceIds;
      return AssistQuestions.substances
          .where((item) => positiveIds.contains(item.id) && item.appliesP5)
          .toList();
    }

    if (questionNumber == 3 || questionNumber == 4) {
      final positiveIds = p2PositiveSubstanceIds;
      return AssistQuestions.substances
          .where((item) => positiveIds.contains(item.id))
          .toList();
    }

    if (questionNumber == 2 || questionNumber == 6 || questionNumber == 7) {
      return selectedSubstanceDefinitions;
    }

    return const [];
  }

  bool get canGoNext {
    final currentQuestion = currentQuestionNumber;

    if (currentQuestion == 1) {
      return true;
    }

    if (currentQuestion == 8) {
      return _injectionScore != null;
    }

    final requiredSubstances = requiredSubstancesForQuestion(currentQuestion);
    if (requiredSubstances.isEmpty) return true;

    final answers = _answersByQuestion[currentQuestion] ?? {};
    for (final substance in requiredSubstances) {
      if (!answers.containsKey(substance.id)) return false;
    }
    return true;
  }

  bool isSubstanceSelected(int substanceId) {
    return _selectedSubstances.contains(substanceId);
  }

  void setSubstanceSelection(int substanceId, bool selected) {
    if (selected) {
      _selectedSubstances.add(substanceId);
    } else {
      _selectedSubstances.remove(substanceId);
      for (final entry in _answersByQuestion.values) {
        entry.remove(substanceId);
      }
    }

    _normalizeCurrentIndex();

    notifyListeners();
  }

  int? getAnswerFor(int questionNumber, int substanceId) {
    return _answersByQuestion[questionNumber]?[substanceId];
  }

  void setAnswerFor(int questionNumber, int substanceId, int score) {
    _answersByQuestion.putIfAbsent(questionNumber, () => {});
    _answersByQuestion[questionNumber]![substanceId] = score;
    _normalizeCurrentIndex();
    notifyListeners();
  }

  void setInjectionScore(int score) {
    _injectionScore = score;
    notifyListeners();
  }

  bool nextQuestion() {
    if (_currentIndex < activeQuestions.length - 1) {
      _currentIndex++;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
      return true;
    }
    return false;
  }

  AssistComputedResults computeResults() {
    return AssistQuestions.computeFromMatrix(
      selectedSubstanceIds: _selectedSubstances,
      answersByQuestion: _answersByQuestion,
      injectionScore: _injectionScore,
    );
  }

  void _normalizeCurrentIndex() {
    final questions = activeQuestions;
    if (questions.isEmpty) {
      _currentIndex = 0;
      return;
    }

    if (_currentIndex >= questions.length) {
      _currentIndex = questions.length - 1;
    }
  }

  Future<AssistSaveResult> saveSurvey() async {
    if (_isSaving) {
      return AssistSaveResult(
        success: false,
        wasSynced: false,
        error: 'Ya se está guardando la encuesta',
      );
    }

    _isSaving = true;
    notifyListeners();

    try {
      if (patientId == 0) {
        throw Exception('ID de paciente inválido. Por favor, reinicie el proceso.');
      }

      if (!canGoNext && isLastQuestion) {
        throw Exception('Faltan respuestas. Por favor, complete el cuestionario.');
      }

      final responseModels = <ResponseModel>[];

      for (final substance in AssistQuestions.substances) {
        responseModels.add(
          ResponseModel(
            questionId: AssistQuestions.encodedQuestionId(questionNumber: 1, substanceId: substance.id),
            answerValue: _selectedSubstances.contains(substance.id) ? 1 : 0,
          ),
        );
      }

      for (final question in [2, 3, 4, 5, 6, 7]) {
        final answers = _answersByQuestion[question] ?? {};
        for (final entry in answers.entries) {
          responseModels.add(
            ResponseModel(
              questionId: AssistQuestions.encodedQuestionId(
                questionNumber: question,
                substanceId: entry.key,
              ),
              answerValue: entry.value,
            ),
          );
        }
      }

      if (_selectedSubstances.isNotEmpty && _injectionScore != null) {
        responseModels.add(
          ResponseModel(
            questionId: AssistQuestions.encodedQuestionId(questionNumber: 8, substanceId: 0),
            answerValue: _injectionScore!,
          ),
        );
      }

      final survey = SurveyModel(
        surveyId: DateTime.now().millisecondsSinceEpoch,
        surveyType: 6,
        patientId: patientId,
        responses: responseModels,
        synced: false,
      );

      final saveResult = await surveyService.saveSurvey(survey);
      final wasSynced = saveResult.wasSynced;

      return AssistSaveResult(
        success: true,
        wasSynced: wasSynced,
        results: computeResults(),
      );
    } catch (e, stackTrace) {
      print('Error al guardar encuesta ASSIST: $e');
      print('Stack trace: $stackTrace');

      return AssistSaveResult(
        success: false,
        wasSynced: false,
        error: e.toString(),
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}

class AssistSaveResult {
  final bool success;
  final bool wasSynced;
  final String? error;
  final AssistComputedResults? results;

  AssistSaveResult({
    required this.success,
    required this.wasSynced,
    this.error,
    this.results,
  });
}