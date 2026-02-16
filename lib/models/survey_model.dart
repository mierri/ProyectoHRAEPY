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
  int surveyType; // 1=BDI, 2=BAI (tipo de encuesta)

  SurveyModel({
    required this.surveyId,
    required this.responses,
    required this.surveyType,
    this.patientId,
    this.synced = false,
  });

  // Métodos para sincronización con backend
  Map<String, dynamic> toJson() => {
    'survey_id': surveyId,
    'patient_id': patientId,
    'synced': synced,
    // El tipo no se guarda en Supabase, solo localmente
  };

  factory SurveyModel.fromJson(Map<String, dynamic> json, {int? surveyType}) => SurveyModel(
    surveyId: json['survey_id'],
    patientId: json['patient_id'],
    surveyType: surveyType ?? 1, // Default BDI
    responses: [], // Las respuestas se cargan por separado
    synced: json['synced'] ?? true,
  );
}