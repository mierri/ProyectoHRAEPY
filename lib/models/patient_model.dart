import 'package:hive/hive.dart';
part 'patient_model.g.dart';

/// aiuda cámbialo a tu gusto plis plos plas c:

@HiveType(typeId: 2)
enum Gender {
  @HiveField(0)
  male,
  @HiveField(1)
  female,
  @HiveField(2)
  other,
}

@HiveType(typeId: 3)
class PatientModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  DateTime dateOfBirth;
  @HiveField(3)
  Gender gender;
  @HiveField(4)
  DateTime createdAt;

  PatientModel({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: Gender.values.firstWhere((e) => e.name == json['gender']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

