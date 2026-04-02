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
  int? patientId;
  @HiveField(4)
  int surveyType;
  // Campos adicionales para osteoporosis (risk_level y score)
  @HiveField(5)
  String? risk_level;
  @HiveField(6)
  int? score;

  SurveyModel({
    required this.surveyId,
    required this.responses,
    required this.surveyType,
    this.patientId,
    this.synced = false,
    this.risk_level,
    this.score,
  });

  // Métodos para sincronización con backend
  Map<String, dynamic> toJson() => {
    'survey_id': surveyId,
    'patient_id': patientId,
    'synced': synced,
    'survey_type': surveyType,
    if (risk_level != null) 'risk_level': risk_level,
    if (score != null) 'score': score,
  };

  factory SurveyModel.fromJson(Map<String, dynamic> json, {int? surveyType}) => SurveyModel(
    surveyId: json['survey_id'],
    patientId: json['patient_id'],
    surveyType: surveyType ?? 1, // Default BDI
    responses: [], // Las respuestas se cargan por separado
    synced: json['synced'] ?? true,
    risk_level: json['risk_level'] as String?,
    score: json['score'] as int?,
  );
}