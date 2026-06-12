import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/shared/form/form_survey_controller.dart';
import 'package:ssapp/shared/models/response_model.dart';

/// Controlador para encuestas personalizadas creadas por la doctora.
class DynamicSurveyController extends FormSurveyController {
  final CustomSurveyDefinition definition;

  DynamicSurveyController({
    required this.definition,
    required super.patientId,
    required super.surveyService,
    super.investigationId,
  }) : super(surveyType: 'custom');

  @override
  int? get customSurveyId => definition.id;

  @override
  Map<int, String> get requiredFields => {
        for (final q in definition.questions) q.fieldId: q.label,
      };

  @override
  int? computeScore(List<ResponseModel> responses) {
    return responses.fold<int>(0, (sum, r) => sum + r.answerValue);
  }

  @override
  String? computeRiskLevel(int? score) {
    if (score == null) return null;
    return definition.levelForScore(score)?.label;
  }
}
