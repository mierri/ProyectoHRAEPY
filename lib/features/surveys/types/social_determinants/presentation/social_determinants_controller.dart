import 'package:ssapp/features/surveys/shared/form/form_survey_controller.dart';
import 'package:ssapp/features/surveys/types/social_determinants/domain/social_determinants_fields.dart';

class SocialDeterminantsController extends FormSurveyController {
  SocialDeterminantsController({
    required super.patientId,
    required super.surveyService,
    super.investigationId,
  }) : super(surveyType: 'social_determinants');

  @override
  Map<int, String> get requiredFields => SocialDeterminantsRequiredFields.labels;

  @override
  List<String> missingRequiredLabels() {
    final missing = super.missingRequiredLabels();

    final tipoVivienda = intAnswer(SocialDeterminantsFieldIds.tipoVivienda);
    if (tipoVivienda == 4 && (textAnswer(SocialDeterminantsFieldIds.tipoViviendaOtro) ?? '').isEmpty) {
      missing.add('Tipo de vivienda (otro)');
    }

    final materialMuros = intAnswer(SocialDeterminantsFieldIds.materialMuros);
    if (materialMuros == 4 && (textAnswer(SocialDeterminantsFieldIds.materialMurosOtro) ?? '').isEmpty) {
      missing.add('Material de muros (otro)');
    }

    final programas = multiAnswer(SocialDeterminantsFieldIds.programasSociales);
    if (programas.contains(5) && (textAnswer(SocialDeterminantsFieldIds.programasSocialesOtro) ?? '').isEmpty) {
      missing.add('Programas sociales (otro)');
    }

    return missing;
  }
}

