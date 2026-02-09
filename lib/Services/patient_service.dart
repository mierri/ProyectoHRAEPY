import 'package:flutter/foundation.dart';

class PatientService extends ChangeNotifier {
  final List<Map<String, dynamic>> _patients = [];

  List<Map<String, dynamic>> get patients => _patients;

  /// Add a new patient
  void addPatient(Map<String, dynamic> patient) {
    _patients.add(patient);
    notifyListeners();
  }

  /// Update a patient
  void updatePatient(int index, Map<String, dynamic> patient) {
    if (index >= 0 && index < _patients.length) {
      _patients[index] = patient;
      notifyListeners();
    }
  }

  /// Delete a patient
  void deletePatient(int index) {
    if (index >= 0 && index < _patients.length) {
      _patients.removeAt(index);
      notifyListeners();
    }
  }

  /// Find patient by ID
  Map<String, dynamic>? findPatientById(String id) {
    try {
      return _patients.firstWhere((p) => p['id'] == id);
    } catch (e) {
      return null;
    }
  }
}
