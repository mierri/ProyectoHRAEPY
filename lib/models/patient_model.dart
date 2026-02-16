import 'package:hive/hive.dart';
part 'patient_model.g.dart';

@HiveType(typeId: 2)
class PatientModel extends HiveObject {
  @HiveField(0)
  int patientId;
  @HiveField(1)
  String name;
  @HiveField(2)
  String gender;
  @HiveField(3)
  DateTime birthDate;
  @HiveField(4)
  bool synced;


  PatientModel({
    required this.patientId,
    required this.name,
    required this.gender,
    required this.birthDate,
    this.synced = false,
  });

  // Métodos para sincronización con backend
  Map<String, dynamic> toJson() => {
    'patient_id': patientId,
    'name': name,
    'gender': gender,
    'birth_date': birthDate.toIso8601String(),
  };

  factory PatientModel.fromJson(Map<String, dynamic> json) => PatientModel(
    patientId: json['patient_id'],
    name: json['name'],
    gender: json['gender'],
    birthDate: DateTime.parse(json['birth_date']),
    synced: json['synced'] ?? true, // true porque viene del backend
  );

  // Calcular edad
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
