import 'package:hive/hive.dart';
part 'investigation_model.g.dart';

@HiveType(typeId: 3)
class InvestigationModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String investigationName;
  @HiveField(2)
  final String formConsent;
  @HiveField(3)
  final List<int> surveyTypeIds;
  @HiveField(4)
  final List<int> participantIdsList;
  @HiveField(5)
  final DateTime createdAt;

  Set<int> get participantIds => participantIdsList.toSet();

  InvestigationModel({
    required this.id,
    required this.investigationName,
    required this.formConsent,
    required this.surveyTypeIds,
    Set<int> participantIds = const <int>{},
    List<int>? participantIdsList,
    DateTime? createdAt,
  })  : participantIdsList = participantIdsList ?? participantIds.toList(),
        createdAt = createdAt ?? DateTime.now();

  InvestigationModel copyWith({
    int? id,
    String? investigationName,
    String? formConsent,
    List<int>? surveyTypeIds,
    Set<int>? participantIds,
    DateTime? createdAt,
  }) {
    return InvestigationModel(
      id: id ?? this.id,
      investigationName: investigationName ?? this.investigationName,
      formConsent: formConsent ?? this.formConsent,
      surveyTypeIds: surveyTypeIds ?? this.surveyTypeIds,
      participantIds: participantIds ?? this.participantIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory InvestigationModel.fromJson(
    Map<String, dynamic> json, {
    List<int>? surveyTypeIds,
    Set<int>? participantIds,
  }) {
    final createdRaw = json['created_at'] as String?;

    return InvestigationModel(
      id: json['id'] as int,
      investigationName: (json['investigation_name'] ?? '') as String,
      formConsent: (json['form_consent'] ?? '') as String,
      surveyTypeIds: surveyTypeIds ?? const <int>[],
      participantIds: participantIds ?? const <int>{},
      createdAt: createdRaw == null
          ? DateTime.now()
          : DateTime.tryParse(createdRaw.toString()) ?? DateTime.now(),
    );
  }
}
