import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ssapp/models/bdi_questions.dart';
import 'package:ssapp/models/gds_questions.dart';
import 'package:ssapp/models/iciq_sf_questions.dart';
import 'package:ssapp/models/katz_questions.dart';
import 'package:ssapp/models/lawton_questions.dart';
import 'package:ssapp/models/response_model.dart';
import 'package:ssapp/models/survey_model.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/models/osteoporosis_risk_model.dart';
import 'package:ssapp/Services/osteoporosis_risk_service.dart';
import 'package:ssapp/models/patient_model.dart';
import 'package:ssapp/config/supabase_config.dart';

import '../models/osteoporosis_questions.dart';

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
    switch (surveyType) {
      case 'bai':
        return 2;
      case 'gds':
        return 7;
      case 'lawton':
        return 8;
      case 'katz':
        return 10;
      case 'iciqsf':
        return 11;
      case 'osteoporosis':
        return 9;
      case 'bdi':
      default:
        return 1;
    }
  } // 1=BDI, 2=BAI, 7=GDS-15, 8=Lawton, 9=Osteoporosis, 10=Katz, 11=ICIQ-SF

  List<SurveyQuestion> get questions {
    if (surveyType == 'bai') {
      return BAIQuestions.questions;
    }
    if (surveyType == 'gds') {
      return GDSQuestions.questions;
    }
    if (surveyType == 'lawton') {
      return LawtonQuestions.questions;
    }
    if (surveyType == 'katz') {
      return KatzQuestions.questions;
    }
    if (surveyType == 'iciqsf') {
      return IciqSfQuestions.questions;
    }
    if (surveyType == 'osteoporosis') {
      return OsteoporosisQuestions.questions;
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
    if (surveyType == 'iciqsf') {
      return IciqSfQuestions.calculateScore(_responses);
    }
    return _responses.values.fold(0, (sum, score) => sum + score);
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
    } else if (surveyType == 'lawton') {
      if (score == questions.length) {
        return 'Independencia total para las actividades instrumentales evaluadas.';
      }
      return 'Presenta deterioro funcional en una o más actividades instrumentales.';
    } else if (surveyType == 'katz') {
      return KatzQuestions.evaluate(_responses).interpretacion;
    } else if (surveyType == 'iciqsf') {
      return IciqSfQuestions.evaluate(_responses).interpretacion;
    } else if (surveyType == 'osteoporosis') {
      // Osteoporosis interpretation: instruct to cross with age, BMI, and score
      if (score >= 7) {
        return 'El puntaje máximo para comparación es 6. Cruce el puntaje, edad e IMC en la tabla correspondiente.';
      }
      return 'Cruce el puntaje, edad e IMC en la tabla correspondiente para determinar el riesgo.';
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
    } else if (surveyType == 'lawton') {
      if (score == questions.length) return 'Independencia total';
      return 'Deterioro funcional';
    } else if (surveyType == 'katz') {
      final result = KatzQuestions.evaluate(_responses);
      return 'Katz ${result.clasificacionKatz}';
    } else if (surveyType == 'iciqsf') {
      final result = IciqSfQuestions.evaluate(_responses);
      if (result.score == 0) return 'Sin incontinencia';
      return 'Impacto ${result.severidad}';
    } else if (surveyType == 'osteoporosis') {
      // Osteoporosis: just return the score (max 6)
      return 'Puntaje: ${score > 6 ? 6 : score}';
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
                 final age = now.year - patient.birthDate.year;

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
                     final age = now.year - patientData.birthDate.year;

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
