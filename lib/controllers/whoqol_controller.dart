import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ssapp/models/response_model.dart';
import 'package:ssapp/models/survey_model.dart';
import 'package:ssapp/models/whoqol_questions.dart';
import 'package:ssapp/Services/survey_service.dart';

/// Controller for WHOQOL-BREF survey logic
/// Handles responses, navigation, saving, and calculations
class WhoqolController extends ChangeNotifier {
  final int patientId;
  final SurveyService surveyService;

  int _currentIndex = 0;
  final Map<int, int> _responses = {};
  int? _selectedOptionIndex;
  bool _isSaving = false;

  WhoqolController({
    required this.patientId,
    required this.surveyService,
  });

  // Getters
  int get currentIndex => _currentIndex;
  Map<int, int> get responses => Map.unmodifiable(_responses);
  int? get selectedOptionIndex => _selectedOptionIndex;
  bool get isSaving => _isSaving;
  
  List<WhoqolQuestion> get questions => WhoqolQuestions.questions;
  WhoqolQuestion get currentQuestion => questions[_currentIndex];
  double get progress => (_currentIndex + 1) / questions.length;
  bool get canGoNext => _responses.containsKey(currentQuestion.number);
  bool get canGoPrevious => _currentIndex > 0;
  bool get isLastQuestion => _currentIndex >= questions.length - 1;

  /// Select an option for the current question
  void selectOption(int questionNumber, int rawScore, int optionIndex) {
    _responses[questionNumber] = rawScore;
    _selectedOptionIndex = optionIndex;
    notifyListeners();
  }

  /// Navigate to next question
  bool nextQuestion() {
    if (_currentIndex < questions.length - 1) {
      _currentIndex++;
      _updateSelectedOption();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Navigate to previous question
  bool previousQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _updateSelectedOption();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Go to specific question by index
  void goToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      _currentIndex = index;
      _updateSelectedOption();
      notifyListeners();
    }
  }

  /// Update selected option based on current question
  void _updateSelectedOption() {
    _selectedOptionIndex = null;
    final questionNumber = _currentIndex + 1;
    if (_responses.containsKey(questionNumber)) {
      _selectedOptionIndex = _responses[questionNumber]! - 1;
    }
  }

  /// Save survey to Hive and sync with Supabase
  Future<SurveySaveResult> saveSurvey() async {
    if (_isSaving) {
      return SurveySaveResult(
        success: false,
        wasSynced: false,
        error: 'Ya se está guardando la encuesta',
      );
    }

    _isSaving = true;
    notifyListeners();

    try {
      // Validate patient ID
      if (patientId == 0) {
        throw Exception('ID de paciente inválido. Por favor, reinicie el proceso.');
      }

      // Convert responses to ResponseModel list
      final List<ResponseModel> responseModels = _responses.entries.map((entry) {
        return ResponseModel(
          questionId: entry.key,
          answerValue: entry.value,
        );
      }).toList();

      // Validate all questions answered
      if (responseModels.length != 26) {
        throw Exception('Faltan respuestas. Por favor, responda todas las preguntas.');
      }

      // Create survey with surveyType = 3 for WHOQOL
      final survey = SurveyModel(
        surveyId: DateTime.now().millisecondsSinceEpoch,
        surveyType: 3, // 3 = WHOQOL-BREF
        patientId: patientId,
        responses: responseModels,
        synced: false,
      );

      // Save locally in Hive
      Box<SurveyModel> box;
      try {
        box = await Hive.openBox<SurveyModel>('surveys');
      } catch (e) {
        await Hive.deleteBoxFromDisk('surveys');
        box = await Hive.openBox<SurveyModel>('surveys');
      }

      await box.add(survey);

      // Try to sync with Supabase
      bool wasSynced = false;
      try {
        wasSynced = await surveyService
            .syncSurveyToSupabase(survey)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => false,
            );

        if (wasSynced) {
          survey.synced = true;
          await survey.save();
        }
      } catch (e) {
        print('Error al sincronizar: $e');
        wasSynced = false;
      }

      return SurveySaveResult(
        success: true,
        wasSynced: wasSynced,
        results: calculateResults(),
      );
    } catch (e, stackTrace) {
      print('Error al guardar encuesta WHOQOL: $e');
      print('Stack trace: $stackTrace');

      return SurveySaveResult(
        success: false,
        wasSynced: false,
        error: e.toString(),
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Calculate WHOQOL-BREF results
  WhoqolResults calculateResults() {
    final q1 = _responses[1];
    final q2 = _responses[2];
    
    final dom1 = WhoqolQuestions.domainScore(
      domainQuestions: WhoqolQuestions.domain1Questions,
      responses: _responses,
    );
    
    final dom2 = WhoqolQuestions.domainScore(
      domainQuestions: WhoqolQuestions.domain2Questions,
      responses: _responses,
    );
    
    final dom3 = WhoqolQuestions.domainScore(
      domainQuestions: WhoqolQuestions.domain3Questions,
      responses: _responses,
    );
    
    final dom4 = WhoqolQuestions.domainScore(
      domainQuestions: WhoqolQuestions.domain4Questions,
      responses: _responses,
    );

    return WhoqolResults(
      globalQ1: q1,
      globalQ2: q2,
      domain1Score: dom1,
      domain2Score: dom2,
      domain3Score: dom3,
      domain4Score: dom4,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Result of survey save operation
class SurveySaveResult {
  final bool success;
  final bool wasSynced;
  final String? error;
  final WhoqolResults? results;

  SurveySaveResult({
    required this.success,
    required this.wasSynced,
    this.error,
    this.results,
  });
}

/// WHOQOL-BREF calculated results
class WhoqolResults {
  final int? globalQ1;
  final int? globalQ2;
  final int? domain1Score;
  final int? domain2Score;
  final int? domain3Score;
  final int? domain4Score;

  WhoqolResults({
    this.globalQ1,
    this.globalQ2,
    this.domain1Score,
    this.domain2Score,
    this.domain3Score,
    this.domain4Score,
  });

  String get q1Interpretation {
    if (globalQ1 == null) return 'Sin respuesta';
    return '${globalQ1}/5 — ${WhoqolQuestions.interpretQ1(globalQ1!)}';
  }

  String get q2Display {
    if (globalQ2 == null) return 'Sin respuesta';
    return '${globalQ2}/5';
  }

  String domain1Display() {
    if (domain1Score == null) return 'Incompleto';
    return '$domain1Score / ${WhoqolQuestions.domain1Questions.length * 5}';
  }

  String domain2Display() {
    if (domain2Score == null) return 'Incompleto';
    return '$domain2Score / ${WhoqolQuestions.domain2Questions.length * 5}';
  }

  String domain3Display() {
    if (domain3Score == null) return 'Incompleto';
    return '$domain3Score / ${WhoqolQuestions.domain3Questions.length * 5}';
  }

  String domain4Display() {
    if (domain4Score == null) return 'Incompleto';
    return '$domain4Score / ${WhoqolQuestions.domain4Questions.length * 5}';
  }
}
