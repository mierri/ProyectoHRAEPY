import 'package:ssapp/features/surveys/domain/survey_catalog.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/presentation/base_survey_controller.dart';
import 'package:ssapp/features/surveys/presentation/survey_controller.dart';
import 'package:ssapp/shared/models/response_model.dart';
import 'package:ssapp/shared/models/survey_model.dart';
import 'package:ssapp/shared/utils/id_generator.dart';

// Responsabilidad: manejar respuestas de formularios sin puntaje y guardar encuestas.
abstract class FormSurveyController extends BaseSurveyController {
  final int patientId;
  final String surveyType;
  final SurveyService surveyService;
  final int? investigationId;

  final Map<int, int> _intAnswers = {};
  final Map<int, String> _textAnswers = {};

  FormSurveyController({
    required this.patientId,
    required this.surveyType,
    required this.surveyService,
    this.investigationId,
  });

  Map<int, String> get requiredFields;

  int? intAnswer(int id) => _intAnswers[id];
  String? textAnswer(int id) => _textAnswers[id];

  void setIntAnswer(int id, int? value) {
    if (value == null) {
      _intAnswers.remove(id);
    } else {
      _intAnswers[id] = value;
    }
    notifyListeners();
  }

  void setTextAnswer(int id, String? value) {
    final raw = value ?? '';
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      _textAnswers.remove(id);
    } else {
      _textAnswers[id] = raw;
    }
    notifyListeners();
  }

  Set<int> multiAnswer(int id) {
    final mask = _intAnswers[id] ?? 0;
    final selected = <int>{};
    var index = 0;
    var currentMask = mask;
    while (currentMask > 0) {
      if ((currentMask & 1) == 1) {
        selected.add(index);
      }
      currentMask >>= 1;
      index++;
    }
    return selected;
  }

  void setMultiAnswer(int id, Set<int> selected) {
    if (selected.isEmpty) {
      _intAnswers.remove(id);
      notifyListeners();
      return;
    }

    var mask = 0;
    for (final value in selected) {
      mask |= (1 << value);
    }
    _intAnswers[id] = mask;
    notifyListeners();
  }

  bool isAnswered(int id) {
    final hasInt = _intAnswers.containsKey(id);
    final hasText = _textAnswers.containsKey(id) && _textAnswers[id]!.isNotEmpty;
    return hasInt || hasText;
  }

  List<String> missingRequiredLabels() {
    return requiredFields.entries
        .where((entry) => !isAnswered(entry.key))
        .map((entry) => entry.value)
        .toList();
  }

  int get surveyTypeId => SurveyCatalog.idForType(surveyType);

  /// ID de la encuesta personalizada (si aplica). Sobrescrito por
  /// DynamicSurveyController para encuestas creadas por la doctora.
  int? get customSurveyId => null;

  /// Calcula el puntaje total a partir de las respuestas. Por defecto no
  /// calcula puntaje (las encuestas sin score lo dejan en null).
  int? computeScore(List<ResponseModel> responses) => null;

  /// Calcula el nivel de riesgo/interpretacion a partir del puntaje.
  String? computeRiskLevel(int? score) => null;

  List<ResponseModel> buildResponseModelsWithText() {
    final ids = <int>{..._intAnswers.keys, ..._textAnswers.keys}.toList()..sort();
    return ids
        .map(
          (id) => ResponseModel(
            questionId: id,
            answerValue: _intAnswers[id] ?? 0,
            answerText: _textAnswers[id],
          ),
        )
        .toList();
  }

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

        final missing = missingRequiredLabels();
        if (missing.isNotEmpty) {
          throw Exception('Faltan respuestas: ${missing.join(', ')}');
        }

        final responses = buildResponseModelsWithText();
        if (responses.isEmpty) {
          throw Exception('No hay respuestas para guardar.');
        }

        final score = computeScore(responses);
        final riskLevel = computeRiskLevel(score);

        final survey = SurveyModel(
          surveyId: generateId(),
          surveyType: surveyTypeId,
          patientId: patientId,
          investigationId: investigationId,
          customSurveyId: customSurveyId,
          responses: responses,
          synced: false,
          risk_level: riskLevel,
          score: score,
        );

        final saveResult = await surveyService.saveSurvey(survey);

        return SurveySaveResult(
          success: true,
          wasSynced: saveResult.wasSynced,
          totalScore: score,
          interpretation: null,
          severityLevel: riskLevel,
          riskResult: null,
          weight: null,
          height: null,
        );
      },
      onError: (error, stackTrace) {
        return SurveySaveResult(
          success: false,
          wasSynced: false,
          error: error.toString(),
        );
      },
      operation: 'guardar encuesta sin puntaje',
    );
  }
}

