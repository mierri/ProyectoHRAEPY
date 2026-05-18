import 'package:ssapp/features/surveys/shared/form/form_survey_controller.dart';
import 'package:ssapp/features/surveys/types/sociodemographic/domain/sociodemographic_fields.dart';

class SociodemographicController extends FormSurveyController {
  SociodemographicController({
    required super.patientId,
    required super.surveyService,
    super.investigationId,
  }) : super(surveyType: 'sociodemographic');

  @override
  Map<int, String> get requiredFields => SociodemographicRequiredFields.labels;

  @override
  List<String> missingRequiredLabels() {
    final missing = super.missingRequiredLabels();

    final sexo = intAnswer(SociodemographicFieldIds.sexo);
    if (sexo == 2 && (textAnswer(SociodemographicFieldIds.sexoOtro) ?? '').isEmpty) {
      missing.add('Sexo (especifique)');
    }

    final grupo = intAnswer(SociodemographicFieldIds.grupoEtnico);
    if (grupo == 1 && (textAnswer(SociodemographicFieldIds.grupoEtnicoNombre) ?? '').isEmpty) {
      missing.add('Grupo étnico (nombre)');
    }

    return missing;
  }
}

