import 'package:ssapp/features/surveys/domain/survey_catalog.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/presentation/base_survey_controller.dart';
import 'package:ssapp/features/surveys/presentation/survey_controller.dart';
import 'package:ssapp/shared/models/response_model.dart';
import 'package:ssapp/shared/models/survey_model.dart';

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
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      _textAnswers.remove(id);
    } else {
      _textAnswers[id] = trimmed;
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

        final survey = SurveyModel(
          surveyId: DateTime.now().millisecondsSinceEpoch,
          surveyType: surveyTypeId,
          patientId: patientId,
          investigationId: investigationId,
          responses: responses,
          synced: false,
          risk_level: null,
          score: null,
        );

        final saveResult = await surveyService.saveSurvey(survey);

        return SurveySaveResult(
          success: true,
          wasSynced: saveResult.wasSynced,
          totalScore: null,
          interpretation: null,
          severityLevel: null,
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

