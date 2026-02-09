import 'package:flutter/foundation.dart';
import 'package:ssapp/models/patient_model.dart';
import 'package:uuid/uuid.dart';

/// checa este iwal tenkiu c:

class PatientService extends ChangeNotifier {
  final List<PatientModel> _patients = [];
  final _uuid = const Uuid();

  List<PatientModel> get patients => _patients;

  Future<PatientModel> createPatient({
    required String name,
    required DateTime dateOfBirth,
    required Gender gender,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final patient = PatientModel(
      id: _uuid.v4(),
      name: name,
      dateOfBirth: dateOfBirth,
      gender: gender,
    );

    _patients.add(patient);
    notifyListeners();

    return patient;
  }

  void addPatient(PatientModel patient) {
    _patients.add(patient);
    notifyListeners();
  }

  void updatePatient(int index, PatientModel patient) {
    if (index >= 0 && index < _patients.length) {
      _patients[index] = patient;
      notifyListeners();
    }
  }

  void deletePatient(int index) {
    if (index >= 0 && index < _patients.length) {
      _patients.removeAt(index);
      notifyListeners();
    }
  }

  PatientModel? findPatientById(String id) {
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
