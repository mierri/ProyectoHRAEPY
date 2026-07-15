import 'package:ssapp/features/surveys/presentation/survey_controller.dart';
import 'package:ssapp/features/surveys/types/fantastic_mexa/domain/fantastic_mexa_questions.dart';
import 'package:ssapp/shared/models/response_model.dart';
import 'package:ssapp/shared/models/survey_model.dart';
import 'package:ssapp/shared/utils/id_generator.dart';

/// Datos generales del cuestionario FANTASTIC MEX-A capturados en el
/// consentimiento informado, previos a las 46 preguntas puntuadas.
class FantasticMexaGeneralData {
  final String fecha;
  final String iniciales;
  final String escolaridad;
  final String ocupacion;
  final String estadoCivil;
  final String habitantesCasa;
  final String numHabitantes;
  final String anosLaborando;
  final String horarioLaboral;
  final String pesoKg;
  final String estaturaM;

  const FantasticMexaGeneralData({
    this.fecha = '',
    this.iniciales = '',
    this.escolaridad = '',
    this.ocupacion = '',
    this.estadoCivil = '',
    this.habitantesCasa = '',
    this.numHabitantes = '',
    this.anosLaborando = '',
    this.horarioLaboral = '',
    this.pesoKg = '',
    this.estaturaM = '',
  });

  Map<int, String> get byFieldId => {
        FantasticMexaGeneralDataFields.fecha: fecha,
        FantasticMexaGeneralDataFields.iniciales: iniciales,
        FantasticMexaGeneralDataFields.escolaridad: escolaridad,
        FantasticMexaGeneralDataFields.ocupacion: ocupacion,
        FantasticMexaGeneralDataFields.estadoCivil: estadoCivil,
        FantasticMexaGeneralDataFields.habitantesCasa: habitantesCasa,
        FantasticMexaGeneralDataFields.numHabitantes: numHabitantes,
        FantasticMexaGeneralDataFields.anosLaborando: anosLaborando,
        FantasticMexaGeneralDataFields.horarioLaboral: horarioLaboral,
        FantasticMexaGeneralDataFields.pesoKg: pesoKg,
        FantasticMexaGeneralDataFields.estaturaM: estaturaM,
      };
}

class FantasticMexaSurveyController extends SurveyController {
  final FantasticMexaGeneralData generalData;

  FantasticMexaSurveyController({
    required super.patientId,
    required super.surveyService,
    super.investigationId,
    this.generalData = const FantasticMexaGeneralData(),
  }) : super(surveyType: 'fantastic_mexa');

  List<ResponseModel> _buildGeneralDataResponses() {
    return generalData.byFieldId.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .map((entry) => ResponseModel(
              questionId: entry.key,
              answerValue: 0,
              answerText: entry.value.trim(),
            ))
        .toList();
  }

  @override
  Future<SurveySaveResult> saveSurvey() async {
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

        final scoredResponses = buildResponseModels(responses);
        if (scoredResponses.length != questions.length) {
          throw Exception('Faltan respuestas. Por favor, responda todas las preguntas.');
        }

        final allResponses = [...scoredResponses, ..._buildGeneralDataResponses()];
        final totalScore = calculateTotalScore();

        final survey = SurveyModel(
          surveyId: generateId(),
          surveyType: surveyTypeId,
          patientId: patientId,
          investigationId: investigationId,
          responses: allResponses,
          synced: false,
          risk_level: getSeverityLevel(),
          score: totalScore,
        );

        final saveResult = await surveyService.saveSurvey(survey);

        return SurveySaveResult(
          success: true,
          wasSynced: saveResult.wasSynced,
          totalScore: totalScore,
          interpretation: getInterpretation(),
          severityLevel: getSeverityLevel(),
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
      operation: 'guardar encuesta FANTASTIC MEX-A',
    );
  }
}
