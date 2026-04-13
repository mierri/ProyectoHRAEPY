import 'package:ssapp/features/surveys/presentation/survey_controller.dart';
import 'package:ssapp/features/surveys/types/osteoporosis/domain/save_osteoporosis_survey_use_case.dart';
import 'package:ssapp/shared/models/response_model.dart';
import 'package:ssapp/shared/models/survey_model.dart';

class OsteoporosisSurveyController extends SurveyController {
  OsteoporosisSurveyController({
    required super.patientId,
    required super.surveyService,
    super.investigationId,
    required super.initialWeight,
    required super.initialHeight,
  }) : super(surveyType: 'osteoporosis');

  @override
  Future<SurveySaveResult> saveSurvey() {
    return executeWithSavingState<SurveySaveResult>(
      alreadySavingResult: SurveySaveResult(
        success: false,
        wasSynced: false,
        error: 'Ya se esta guardando la encuesta',
      ),
      action: () async {
        if (patientId == 0) {
          throw Exception('ID de paciente invalido. Por favor, reinicie el proceso.');
        }

        final List<ResponseModel> responseModels = buildResponseModels(responses);

        if (responseModels.length != questions.length) {
          throw Exception('Faltan respuestas. Por favor, responda todas las preguntas.');
        }

        final weight = initialWeight;
        final height = initialHeight;

        if (weight == null || height == null) {
          throw Exception('Peso y altura son obligatorios para osteoporosis.');
        }

        final uc = SaveOsteoporosisSurveyUseCase();
        final result = await uc.execute(
          patientId: patientId,
          weightKg: weight,
          heightMeters: height,
          answers: List<bool>.generate(7, (index) => (responses[index + 1] ?? 0) == 1),
          surveyService: surveyService,
        );

        if (!result.success) {
          throw Exception(result.error ?? 'No se pudo procesar el riesgo de osteoporosis.');
        }

        setOsteoporosisRiskResult(result.riskResult);
        final riskLevel = result.riskResult?.riskLevel.name == 'notApplicable'
            ? 'not_applicable'
            : result.riskResult?.riskLevel.name;

        final totalScore = calculateTotalScore();
        final survey = SurveyModel(
          surveyId: DateTime.now().millisecondsSinceEpoch,
          surveyType: surveyTypeId,
          patientId: patientId,
          investigationId: investigationId,
          responses: responseModels,
          synced: false,
          risk_level: riskLevel,
          score: totalScore,
        );

        final saveResult = await surveyService.saveSurvey(survey);

        return SurveySaveResult(
          success: true,
          wasSynced: saveResult.wasSynced,
          totalScore: totalScore,
          interpretation: getInterpretation(),
          severityLevel: getSeverityLevel(),
          riskResult: osteoporosisRiskResult,
          weight: weight,
          height: height,
        );
      },
      onError: (error, stackTrace) {
        return SurveySaveResult(
          success: false,
          wasSynced: false,
          error: error.toString(),
        );
      },
      operation: 'guardar encuesta de osteoporosis',
    );
  }
}
