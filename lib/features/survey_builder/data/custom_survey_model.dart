import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';

part 'custom_survey_model.g.dart';

/// Encuesta personalizada creada por la doctora, persistida como JSON.
@HiveType(typeId: 4)
class CustomSurveyModel extends HiveObject {
  @HiveField(0)
  int id;
  @HiveField(1)
  String definitionJson;
  @HiveField(2)
  bool synced;
  @HiveField(3)
  DateTime updatedAt;

  CustomSurveyModel({
    required this.id,
    required this.definitionJson,
    this.synced = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  CustomSurveyDefinition get definition =>
      CustomSurveyDefinition.fromJson(jsonDecode(definitionJson) as Map<String, dynamic>);

  set definition(CustomSurveyDefinition value) {
    definitionJson = jsonEncode(value.toJson());
  }

  factory CustomSurveyModel.fromDefinition(
    CustomSurveyDefinition definition, {
    bool synced = false,
    DateTime? updatedAt,
  }) =>
      CustomSurveyModel(
        id: definition.id,
        definitionJson: jsonEncode(definition.toJson()),
        synced: synced,
        updatedAt: updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'definition': jsonDecode(definitionJson),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory CustomSurveyModel.fromJson(Map<String, dynamic> json) => CustomSurveyModel(
        id: json['id'] as int,
        definitionJson: jsonEncode(json['definition']),
        synced: true,
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      );
}
