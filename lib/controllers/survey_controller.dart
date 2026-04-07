import 'package:flutter/material.dart';
import 'package:ssapp/Services/surveys/survey_catalog.dart';
import 'package:ssapp/Services/surveys/survey_rules.dart';
import 'package:ssapp/controllers/base_survey_controller.dart';
import 'package:ssapp/models/bdi_questions.dart';
import 'package:ssapp/models/iciq_sf_questions.dart';
import 'package:ssapp/models/katz_questions.dart';
import 'package:ssapp/models/response_model.dart';
import 'package:ssapp/models/survey_model.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/Services/surveys/survey_repository.dart';
import 'package:ssapp/models/osteoporosis_risk_model.dart';
import 'package:ssapp/Services/osteoporosis_risk_service.dart';
import 'package:ssapp/models/patient_model.dart';
import 'package:ssapp/config/supabase_config.dart';
import 'package:hive/hive.dart';

// Responsabilidad: coordinar estado, respuestas y guardado de encuestas BDI/BAI/GDS/Lawton/Katz/ICIQ-SF/Osteoporosis.
/// Controller for BDI/BAI survey logic
/// Handles responses, navigation, saving, and score calculations
class SurveyController extends BaseSurveyController {
  final int patientId;
  final String surveyType; // 'bdi', 'bai', 'gds', 'lawton', 'katz', 'iciqsf', or 'osteoporosis'
  final SurveyService surveyService;
  final double? initialWeight; // For osteoporosis
  final double? initialHeight; // For osteoporosis

    int _currentQuestionIndex = 0;
    final Map<int, int> _responses = {};
    int? _selectedOptionIndex;

    RiskResult? _osteoporosisRiskResult;

   SurveyController({
     required this.patientId,
     required this.surveyType,
     required this.surveyService,
     this.initialWeight,
     this.initialHeight,
   });

   // Getters
   int get currentQuestionIndex => _currentQuestionIndex;
   Map<int, int> get responses => Map.unmodifiable(_responses);
   int? get selectedOptionIndex => _selectedOptionIndex;
   RiskResult? get osteoporosisRiskResult => _osteoporosisRiskResult;

  int get surveyTypeId {
    return SurveyCatalog.idForType(surveyType);
  } // 1=BDI, 2=BAI, 7=GDS-15, 8=Lawton, 9=Osteoporosis, 10=Katz, 11=ICIQ-SF

  List<SurveyQuestion> get questions {
    return SurveyCatalog.questionsForType(surveyType);
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

  /// Set a raw response value (used by special multi-select questions)
  void setRawResponse(int questionNumber, int value) {
    _responses[questionNumber] = value;
    if (currentQuestion.number == questionNumber) {
      _updateSelectedOption();
    }
    notifyListeners();
  }

  /// Remove a response (used when multi-select question has no selected options)
  void clearResponse(int questionNumber) {
    _responses.remove(questionNumber);
    if (currentQuestion.number == questionNumber) {
      _updateSelectedOption();
    }
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
    return SurveyRules.totalScoreFromResponses(surveyType, _responses);
  }

  Map<String, dynamic> getKatzOutput() {
    if (surveyType != 'katz') {
      throw StateError('getKatzOutput solo aplica para surveyType = katz');
    }
    final result = KatzQuestions.evaluate(_responses);
    return result.toMap();
  }

  Map<String, dynamic> getIciqSfOutput() {
    if (surveyType != 'iciqsf') {
      throw StateError('getIciqSfOutput solo aplica para surveyType = iciqsf');
    }
    final result = IciqSfQuestions.evaluate(_responses);
    return result.toMap();
  }

  /// Get interpretation based on score
  String getInterpretation() {
    return SurveyRules.interpretation(surveyType, _responses, questions);
  }


  /// Get severity level
  String getSeverityLevel() {
    return SurveyRules.severityLevel(surveyType, _responses, questions);
  }

  Future<({String? riskLevel, double? weight, double? height})> _resolveOsteoporosisMeta() async {
    if (surveyType != 'osteoporosis') {
      return (riskLevel: null, weight: null, height: null);
    }

    final weight = initialWeight;
    final height = initialHeight;

    if (weight == null || height == null) {
      return (riskLevel: null, weight: weight, height: height);
    }

    final patient = await _loadPatientForOsteoporosis();
    if (patient == null) {
      return (riskLevel: null, weight: weight, height: height);
    }

    patient.weight ??= weight;
    patient.height ??= height;
    if (height > 0) {
      patient.imc = OsteoporosisRiskService.calculateBMI(weight, height);
    }
    await patient.save();

    final patientData = PatientData(
      age: patient.age,
      weightKg: weight,
      heightMeters: height,
      sex: patient.gender == 'M' ? Sex.male : Sex.female,
      answers: List<bool>.generate(7, (index) => (_responses[index + 1] ?? 0) == 1),
    );

    final result = OsteoporosisRiskService.calculateRisk(patientData);
    _osteoporosisRiskResult = result;

    final riskLevel =
        result.riskLevel.name == 'notApplicable' ? 'not_applicable' : result.riskLevel.name;
    return (riskLevel: riskLevel, weight: weight, height: height);
  }

  Future<PatientModel?> _loadPatientForOsteoporosis() async {
    try {
      final patientsBox = await Hive.openBox<PatientModel>('patients');
      final localPatients = patientsBox.values.where((p) => p.patientId == patientId).toList();
      if (localPatients.isNotEmpty) {
        return localPatients.first;
      }
    } catch (error, stackTrace) {
      logControllerError('cargar paciente de Hive', error, stackTrace);
    }

    try {
      final response = await SupabaseConfig.client
          .from('patients')
          .select()
          .eq('patient_id', patientId)
          .maybeSingle();

      if (response == null) return null;
      return PatientModel.fromJson(response);
    } catch (error, stackTrace) {
      logControllerError('cargar paciente de Supabase', error, stackTrace);
      return null;
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

        if (responseModels.length != questions.length) {
          throw Exception('Faltan respuestas. Por favor, responda todas las preguntas.');
        }

        final totalScore = calculateTotalScore();
        final osteoMeta = await _resolveOsteoporosisMeta();
        final scoreForDb = surveyType == 'osteoporosis' ? totalScore : null;

        final survey = SurveyModel(
          surveyId: DateTime.now().millisecondsSinceEpoch,
          surveyType: surveyTypeId,
          patientId: patientId,
          responses: responseModels,
          synced: false,
          risk_level: osteoMeta.riskLevel,
          score: scoreForDb,
        );

        final saveResult = await surveyService.saveSurvey(survey);

        if (surveyType == 'osteoporosis') {
          final patient = await _loadPatientForOsteoporosis();
          if (patient != null) {
            try {
              await SurveyRepository().syncPatientToSupabase(patient);
            } catch (error, stackTrace) {
              logControllerError('sincronizar paciente osteoporosis', error, stackTrace);
            }
          }
        }

        return SurveySaveResult(
          success: true,
          wasSynced: saveResult.wasSynced,
          totalScore: totalScore,
          interpretation: getInterpretation(),
          severityLevel: getSeverityLevel(),
          riskResult: _osteoporosisRiskResult,
          weight: osteoMeta.weight,
          height: osteoMeta.height,
        );
      },
      onError: (error, stackTrace) {
        return SurveySaveResult(
        success: false,
        wasSynced: false,
        error: error.toString(),
      );
      },
      operation: 'guardar encuesta',
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
  final int? totalScore;
  final String? interpretation;
  final String? severityLevel;
  final RiskResult? riskResult;
  final double? weight; // Para osteoporosis
  final double? height; // Para osteoporosis

  SurveySaveResult({
    required this.success,
    required this.wasSynced,
    this.error,
    this.totalScore,
    this.interpretation,
    this.severityLevel,
    this.riskResult,
    this.weight,
    this.height,
  });
}
