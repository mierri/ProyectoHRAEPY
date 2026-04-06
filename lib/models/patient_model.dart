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
  @HiveField(5)
  double? weight; // Peso en kg (para osteoporosis)
  @HiveField(6)
  double? height; // Altura en metros (para osteoporosis)
  @HiveField(7)
  double? imc; // IMC calculado


  PatientModel({
    required this.patientId,
    required this.name,
    required this.gender,
    required this.birthDate,
    this.synced = false,
    this.weight,
    this.height,
    this.imc,
  });

  static String _genderForDb(String value) {
    switch (value) {
      case 'M':
      case 'Masculino':
        return 'Masculino';
      case 'F':
      case 'Femenino':
        return 'Femenino';
      case 'O':
      case 'Otro':
        return 'Otro';
      case 'N':
      case 'Prefiero no decir':
        return 'Prefiero no decir';
      default:
        return value;
    }
  }

  static String _genderFromDb(String value) {
    switch (value) {
      case 'Masculino':
        return 'M';
      case 'Femenino':
        return 'F';
      case 'Otro':
        return 'O';
      case 'Prefiero no decir':
        return 'N';
      default:
        return value;
    }
  }

  // Métodos para sincronización con backend
  Map<String, dynamic> toJson() => {
    'patient_id': patientId,
    'name': name,
    'gender': _genderForDb(gender),
    'birth_date': birthDate.toIso8601String(),
    if (weight != null) 'weight': weight,
    if (height != null) 'height': height,
    if (imc != null) 'imc': imc,
  };

  factory PatientModel.fromJson(Map<String, dynamic> json) => PatientModel(
    patientId: json['patient_id'],
    name: json['name'],
    gender: _genderFromDb(json['gender']),
    birthDate: DateTime.parse(json['birth_date']),
    synced: json['synced'] ?? true, // true porque viene del backend
    weight: (json['weight'] as num?)?.toDouble(),
    height: (json['height'] as num?)?.toDouble(),
    imc: (json['imc'] as num?)?.toDouble(),
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
