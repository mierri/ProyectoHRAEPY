import 'package:hive/hive.dart';
import 'package:ssapp/models/response_model.dart';
part 'survey_model.g.dart';

@HiveType(typeId: 0)
class SurveyModel extends HiveObject{
  @HiveField(0)
  int surveyId;
  @HiveField(1)
  bool synced;
  @HiveField(2)
  List<ResponseModel> responses;
  @HiveField(3)
  String surveyName;

  SurveyModel({
    required this.surveyId,
    required this.responses,
    required this.surveyName,
    this.synced = false,

  });
}