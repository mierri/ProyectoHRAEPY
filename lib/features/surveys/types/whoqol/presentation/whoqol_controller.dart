import 'package:ssapp/features/surveys/presentation/base_survey_controller.dart';
import 'package:ssapp/features/surveys/types/whoqol/domain/whoqol_questions.dart';
import 'package:ssapp/shared/models/response_model.dart';
import 'package:ssapp/shared/models/survey_model.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/shared/utils/id_generator.dart';

// Responsabilidad: gestionar estado y guardado de la encuesta WHOQOL-BREF.
/// Controller for WHOQOL-BREF survey logic
/// Handles responses, navigation, saving, and calculations
class WhoqolController extends BaseSurveyController {
  final int patientId;
  final SurveyService surveyService;
  final int? investigationId;

  int _currentIndex = 0;
  final Map<int, int> _responses = {};
  int? _selectedOptionIndex;

  WhoqolController({
    required this.patientId,
    required this.surveyService,
    this.investigationId,
  });

  // Getters
  int get currentIndex => _currentIndex;
  Map<int, int> get responses => Map.unmodifiable(_responses);
  int? get selectedOptionIndex => _selectedOptionIndex;
  
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
  @override
  Future<SurveySaveResult> saveSurvey() async {
    return executeWithSavingState<SurveySaveResult>(
      alreadySavingResult: SurveySaveResult(
        success: false,
        wasSynced: false,
        error: 'Ya se está guardando la encuesta',
      ),
      action: () async {
        if (patientId == 0) {
          throw Exception('ID de paciente inválido. Por favor, reinicie el proceso.');
        }

        final List<ResponseModel> responseModels = buildResponseModels(_responses);

        if (responseModels.length != 26) {
          throw Exception('Faltan respuestas. Por favor, responda todas las preguntas.');
        }

        final survey = SurveyModel(
          surveyId: generateId(),
          surveyType: 3,
          patientId: patientId,
          investigationId: investigationId,
          responses: responseModels,
          synced: false,
        );

        final saveResult = await surveyService.saveSurvey(survey);
        return SurveySaveResult(
          success: true,
          wasSynced: saveResult.wasSynced,
          results: calculateResults(),
        );
      },
      onError: (error, stackTrace) {
        return SurveySaveResult(
          success: false,
          wasSynced: false,
          error: error.toString(),
        );
      },
      operation: 'guardar encuesta WHOQOL',
    );
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
    return '$domain1Score / ${WhoqolQuestions.domain1Questions.length * 5} - ${_domainInterpretation(domain1Score!, WhoqolQuestions.domain1Questions.length * 5)}';
  }

  String domain2Display() {
    if (domain2Score == null) return 'Incompleto';
    return '$domain2Score / ${WhoqolQuestions.domain2Questions.length * 5} - ${_domainInterpretation(domain2Score!, WhoqolQuestions.domain2Questions.length * 5)}';
  }

  String domain3Display() {
    if (domain3Score == null) return 'Incompleto';
    return '$domain3Score / ${WhoqolQuestions.domain3Questions.length * 5} - ${_domainInterpretation(domain3Score!, WhoqolQuestions.domain3Questions.length * 5)}';
  }

  String domain4Display() {
    if (domain4Score == null) return 'Incompleto';
    return '$domain4Score / ${WhoqolQuestions.domain4Questions.length * 5} - ${_domainInterpretation(domain4Score!, WhoqolQuestions.domain4Questions.length * 5)}';
  }

  String _domainInterpretation(int score, int maxScore) {
    final pct = score / maxScore * 100;
    if (pct >= 75) return 'Alta calidad de vida';
    if (pct >= 50) return 'Calidad de vida media';
    return 'Calidad de vida baja';
  }
}
