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
  // Campos antropométricos solo para osteoporosis
  @HiveField(5)
  double? weight;
  @HiveField(6)
  double? height;
  @HiveField(7)
  double? imc;

  SurveyModel({
    required this.surveyId,
    required this.responses,
    required this.surveyType,
    this.patientId,
    this.synced = false,
    this.weight,
    this.height,
    this.imc,
  });

  // Métodos para sincronización con backend
  Map<String, dynamic> toJson() => {
    'survey_id': surveyId,
    'patient_id': patientId,
    'synced': synced,
    'survey_type': surveyType,
    if (weight != null) 'weight': weight,
    if (height != null) 'height': height,
    if (imc != null) 'imc': imc,
  };

  factory SurveyModel.fromJson(Map<String, dynamic> json, {int? surveyType}) => SurveyModel(
    surveyId: json['survey_id'],
    patientId: json['patient_id'],
    surveyType: surveyType ?? 1, // Default BDI
    responses: [], // Las respuestas se cargan por separado
    synced: json['synced'] ?? true,
    weight: (json['weight'] as num?)?.toDouble(),
    height: (json['height'] as num?)?.toDouble(),
    imc: (json['imc'] as num?)?.toDouble(),
  );
}