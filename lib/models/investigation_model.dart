class InvestigationModel {
  final int id;
  final String investigationName;
  final String formConsent;
  final List<int> surveyTypeIds;
  final Set<int> participantIds;
  final DateTime createdAt;

  InvestigationModel({
    required this.id,
    required this.investigationName,
    required this.formConsent,
    required this.surveyTypeIds,
    this.participantIds = const <int>{},
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

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

