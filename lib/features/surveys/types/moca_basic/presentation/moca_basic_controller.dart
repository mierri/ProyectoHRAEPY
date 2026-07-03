import 'package:ssapp/features/surveys/shared/form/form_survey_controller.dart';
import 'package:ssapp/features/surveys/types/moca_basic/domain/moca_basic_fields.dart';
import 'package:ssapp/features/surveys/types/moca_basic/domain/moca_basic_scoring.dart';
import 'package:ssapp/shared/models/response_model.dart';

class MocaBasicController extends FormSurveyController {
  MocaBasicController({
    required super.patientId,
    required super.surveyService,
    super.investigationId,
  }) : super(surveyType: 'moca_basic');

  @override
  Map<int, String> get requiredFields => MocaBasicRequiredFields.labels;

  @override
  int? computeScore(List<ResponseModel> responses) {
    final map = <int, int>{};
    for (final response in responses) {
      map[response.questionId] = response.answerValue;
    }
    return MocaBasicScoring.totalScore(map);
  }

  @override
  String? computeRiskLevel(int? score) {
    if (score == null) return null;
    return MocaBasicScoring.levelForScore(score);
  }
}
