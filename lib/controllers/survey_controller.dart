import 'package:flutter/material.dart';
import 'package:ssapp/Services/surveys/survey_catalog.dart';
import 'package:ssapp/Services/surveys/survey_rules.dart';
import 'package:ssapp/models/bdi_questions.dart';
import 'package:ssapp/models/iciq_sf_questions.dart';
import 'package:ssapp/models/katz_questions.dart';
import 'package:ssapp/models/response_model.dart';
import 'package:ssapp/models/survey_model.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/models/osteoporosis_risk_model.dart';
import 'package:ssapp/Services/osteoporosis_risk_service.dart';
import 'package:ssapp/models/patient_model.dart';
import 'package:ssapp/config/supabase_config.dart';
import 'package:hive/hive.dart';

/// Controller for BDI/BAI survey logic
/// Handles responses, navigation, saving, and score calculations
class SurveyController extends ChangeNotifier {
  final int patientId;
  final String surveyType; // 'bdi', 'bai', 'gds', 'lawton', 'katz', 'iciqsf', or 'osteoporosis'
  final SurveyService surveyService;
  final double? initialWeight; // For osteoporosis
  final double? initialHeight; // For osteoporosis

    int _currentQuestionIndex = 0;
    final Map<int, int> _responses = {};
    int? _selectedOptionIndex;
    bool _isSaving = false;

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
   bool get isSaving => _isSaving;
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

       // Calculate total score
       final totalScore = calculateTotalScore();

       // For osteoporosis, calculate risk level
       String? riskLevel;
       int? scoreForDb;
       double? osteoWeight;
       double? osteoHeight;
       if (surveyType == 'osteoporosis') {
         scoreForDb = totalScore;
         try {
           // Use initialWeight and initialHeight if provided, otherwise get from patient
           double? weight = initialWeight;
           double? height = initialHeight;

           // Store for returning in result
           osteoWeight = weight;
           osteoHeight = height;

           if (weight != null && height != null) {
             // Get patient data from Hive for age and gender
             try {
               final patientsBox = await Hive.openBox<PatientModel>('patients');
               final patients = patientsBox.values.where((p) => p.patientId == patientId).toList();

                if (patients.isNotEmpty) {
                  final patient = patients.first;

                  // Save weight and height to patient if not already set
                  if (patient.weight == null) {
                    patient.weight = weight;
                  }
                  if (patient.height == null) {
                    patient.height = height;
                  }

                  // Calculate and save IMC
                  if (weight != null && height != null && height > 0) {
                    final imc = OsteoporosisRiskService.calculateBMI(weight, height);
                    patient.imc = imc;
                  }

                  await patient.save();

                  // Calculate age from birthDate
                  final now = DateTime.now();
                  final age = (now.year - patient.birthDate.year) as int;

                  // Get sex (convert 'M'/'F' from model)
                 final sexEnum = (patient.gender == 'M') ? Sex.male : Sex.female;

                 // Convert responses to bool answers (true = 1, false = 0)
                 final answersList = <bool>[];
                 for (int q = 1; q <= 7; q++) {
                   answersList.add((_responses[q] ?? 0) == 1);
                 }

                 final patientData = PatientData(
                   age: age,
                   weightKg: weight,
                   heightMeters: height,
                   sex: sexEnum,
                   answers: answersList,
                 );
                 final result = OsteoporosisRiskService.calculateRisk(patientData);
                 _osteoporosisRiskResult = result;
                 // Convert enum name to database format: notApplicable -> not_applicable
                 riskLevel = result.riskLevel.name == 'notApplicable' ? 'not_applicable' : result.riskLevel.name;
               } else {
                 print('Paciente con ID $patientId no encontrado en Hive. Buscando en Supabase...');
                 // Si no está en Hive, buscar en Supabase
                 try {
                   final supabase = SupabaseConfig.client;
                   final response = await supabase
                       .from('patients')
                       .select()
                       .eq('patient_id', patientId)
                       .maybeSingle();

                   if (response != null) {
                     final patientData = PatientModel.fromJson(response);

                     // Calculate age from birthDate
                     final now = DateTime.now();
                     final age = (now.year - patientData.birthDate.year) as int;

                     // Get sex (convert 'M'/'F' from model)
                     final sexEnum = (patientData.gender == 'M') ? Sex.male : Sex.female;

                     // Convert responses to bool answers (true = 1, false = 0)
                     final answersList = <bool>[];
                     for (int q = 1; q <= 7; q++) {
                       answersList.add((_responses[q] ?? 0) == 1);
                     }

                     final osteopatientData = PatientData(
                       age: age,
                       weightKg: weight,
                       heightMeters: height,
                       sex: sexEnum,
                       answers: answersList,
                     );
                     final result = OsteoporosisRiskService.calculateRisk(osteopatientData);
                     _osteoporosisRiskResult = result;
                     riskLevel = result.riskLevel.name == 'notApplicable' ? 'not_applicable' : result.riskLevel.name;
                   } else {
                     print('Paciente no encontrado en Supabase tampoco');
                   }
                 } catch (supabaseError) {
                   print('Error buscando en Supabase: $supabaseError');
                 }
               }
             } catch (e) {
               print('Error al acceder a Hive: $e');
             }
           } else {
             print('Peso y talla no disponibles. Peso: $weight, Talla: $height');
           }
         } catch (e, stackTrace) {
           print('Error calculating osteoporosis risk: $e');
           print('Stack trace: $stackTrace');
         }
       }

       // Create survey
       final survey = SurveyModel(
         surveyId: DateTime.now().millisecondsSinceEpoch,
         surveyType: surveyTypeId,
         patientId: patientId,
         responses: responseModels,
         synced: false,
         risk_level: surveyType == 'osteoporosis' ? riskLevel : null,
         score: surveyType == 'osteoporosis' ? scoreForDb : null,
       );

       final saveResult = await surveyService.saveSurvey(survey);
       final wasSynced = saveResult.wasSynced;

       // For osteoporosis, also sync patient data to Supabase
       if (surveyType == 'osteoporosis') {
         try {
           final patientsBox = await Hive.openBox<PatientModel>('patients');
           final patients = patientsBox.values.where((p) => p.patientId == patientId).toList();

           if (patients.isNotEmpty) {
             final patient = patients.first;
             // Sync patient to Supabase to save weight/height
             await surveyService.syncPatientToSupabase(patient);
           }
         } catch (e) {
           print('Error al sincronizar paciente: $e');
         }
       }

        return SurveySaveResult(
          success: true,
          wasSynced: wasSynced,
          totalScore: totalScore,
          interpretation: getInterpretation(),
          severityLevel: getSeverityLevel(),
          riskResult: _osteoporosisRiskResult,
          weight: surveyType == 'osteoporosis' ? osteoWeight : null,
          height: surveyType == 'osteoporosis' ? osteoHeight : null,
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
