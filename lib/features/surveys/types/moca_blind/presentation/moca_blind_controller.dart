import 'package:ssapp/features/surveys/shared/form/form_survey_controller.dart';
import 'package:ssapp/features/surveys/types/moca_blind/domain/moca_blind_fields.dart';
import 'package:ssapp/features/surveys/types/moca_blind/domain/moca_blind_scoring.dart';
import 'package:ssapp/shared/models/response_model.dart';

class MocaBlindController extends FormSurveyController {
  MocaBlindController({
    required super.patientId,
    required super.surveyService,
    super.investigationId,
  }) : super(surveyType: 'moca_blind');

  @override
  Map<int, String> get requiredFields => MocaBlindRequiredFields.labels;

  @override
  int? computeScore(List<ResponseModel> responses) {
    final map = <int, int>{};
    for (final response in responses) {
      map[response.questionId] = response.answerValue;
    }
    return MocaBlindScoring.totalScore(map);
  }

  @override
  String? computeRiskLevel(int? score) {
    if (score == null) return null;
    return MocaBlindScoring.levelForScore(score);
  }
}
