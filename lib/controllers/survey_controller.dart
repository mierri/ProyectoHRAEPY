import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ssapp/models/bdi_questions.dart';
import 'package:ssapp/models/gds_questions.dart';
import 'package:ssapp/models/response_model.dart';
import 'package:ssapp/models/survey_model.dart';
import 'package:ssapp/Services/survey_service.dart';

/// Controller for BDI/BAI survey logic
/// Handles responses, navigation, saving, and score calculations
class SurveyController extends ChangeNotifier {
  final int patientId;
  final String surveyType; // 'bdi', 'bai' or 'gds'
  final SurveyService surveyService;

  int _currentQuestionIndex = 0;
  final Map<int, int> _responses = {};
  int? _selectedOptionIndex;
  bool _isSaving = false;

  SurveyController({
    required this.patientId,
    required this.surveyType,
    required this.surveyService,
  });

  // Getters
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<int, int> get responses => Map.unmodifiable(_responses);
  int? get selectedOptionIndex => _selectedOptionIndex;
  bool get isSaving => _isSaving;
  
  int get surveyTypeId {
    switch (surveyType) {
      case 'bai':
        return 2;
      case 'gds':
        return 7;
      case 'bdi':
      default:
        return 1;
    }
  } // 1=BDI, 2=BAI, 7=GDS-15
  
  List<SurveyQuestion> get questions {
    if (surveyType == 'bai') {
      return BAIQuestions.questions;
    }
    if (surveyType == 'gds') {
      return GDSQuestions.questions;
    }
    return BDIQuestions.questions;
  }
  
  SurveyQuestion get currentQuestion => questions[_currentQuestionIndex];
  double get progress => (_currentQuestionIndex + 1) / questions.length;
  bool get canGoNext => _responses.containsKey(currentQuestion.number);
  bool get canGoPrevious => _currentQuestionIndex > 0;
  bool get isLastQuestion => _currentQuestionIndex >= questions.length - 1;

  /// Select an option for the current question
  void selectOption(int questionNumber, int score, int optionIndex) {
    _responses[questionNumber] = score;
    _selectedOptionIndex = optionIndex;
    notifyListeners();
  }

  /// Navigate to next question
  bool nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      _currentQuestionIndex++;
      _updateSelectedOption();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Navigate to previous question
  bool previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      _updateSelectedOption();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Go to specific question by index
  void goToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      _currentQuestionIndex = index;
      _updateSelectedOption();
      notifyListeners();
    }
  }

  /// Update selected option based on current question
  void _updateSelectedOption() {
    final currentQ = currentQuestion;
    _selectedOptionIndex = null;
    
    if (_responses.containsKey(currentQ.number)) {
      final score = _responses[currentQ.number]!;
      for (int i = 0; i < currentQ.options.length; i++) {
        if (currentQ.options[i].score == score) {
          _selectedOptionIndex = i;
          break;
        }
      }
    }
  }

  /// Calculate total score
  int calculateTotalScore() {
    return _responses.values.fold(0, (sum, score) => sum + score);
  }

  /// Get interpretation based on score
  String getInterpretation() {
    final score = calculateTotalScore();
    if (surveyType == 'bai') {
      // BAI interpretation
      if (score <= 7) return 'Los síntomas de ansiedad son mínimos o inexistentes.';
      if (score <= 15) return 'Presenta síntomas leves de ansiedad.';
      if (score <= 25) return 'Presenta síntomas moderados de ansiedad.';
      return 'Presenta síntomas severos de ansiedad.';
    } else if (surveyType == 'gds') {
      if (score <= 4) return 'Resultado dentro de la normalidad.';
      return 'Presenta síntomas depresivos.';
    } else {
      // BDI interpretation
      if (score <= 13) return 'Los síntomas depresivos son mínimos o inexistentes.';
      if (score <= 19) return 'Presenta síntomas leves de depresión.';
      if (score <= 28) return 'Presenta síntomas moderados de depresión.';
      return 'Presenta síntomas graves de depresión.';
    }
  }

  /// Get severity level
  String getSeverityLevel() {
    final score = calculateTotalScore();
    if (surveyType == 'bai') {
      // BAI levels
      if (score <= 7) return 'Ansiedad Mínima';
      if (score <= 15) return 'Ansiedad Leve';
      if (score <= 25) return 'Ansiedad Moderada';
      return 'Ansiedad Severa';
    } else if (surveyType == 'gds') {
      if (score <= 4) return 'Normal';
      return 'Síntomas depresivos';
    } else {
      // BDI levels
      if (score <= 13) return 'Depresión Mínima';
      if (score <= 19) return 'Depresión Leve';
      if (score <= 28) return 'Depresión Moderada';
      return 'Depresión Grave';
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
      if (responseModels.length != questions.length) {
        throw Exception('Faltan respuestas. Por favor, responda todas las preguntas.');
      }

      // Create survey
      final survey = SurveyModel(
        surveyId: DateTime.now().millisecondsSinceEpoch,
        surveyType: surveyTypeId,
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

      final totalScore = calculateTotalScore();
      return SurveySaveResult(
        success: true,
        wasSynced: wasSynced,
        totalScore: totalScore,
        interpretation: getInterpretation(),
        severityLevel: getSeverityLevel(),
      );
    } catch (e, stackTrace) {
      print('Error al guardar encuesta: $e');
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
  final int? totalScore;
  final String? interpretation;
  final String? severityLevel;

  SurveySaveResult({
    required this.success,
    required this.wasSynced,
    this.error,
    this.totalScore,
    this.interpretation,
    this.severityLevel,
  });
}
