import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ssapp/models/patient_model.dart';

/// Controller for Patients screen logic
/// Handles patient list, filtering, search, and CRUD operations
class PatientsController extends ChangeNotifier {
  List<PatientModel> _allPatients = [];
  List<PatientModel> _filteredPatients = [];
  String _searchQuery = '';
  String _filterStatus = 'todos'; // 'todos', 'activos', 'inactivos'
  bool _isLoading = false;

  PatientsController();

  // Getters
  List<PatientModel> get patients => _filteredPatients;
  List<PatientModel> get allPatients => _allPatients;
  String get searchQuery => _searchQuery;
  String get filterStatus => _filterStatus;
  bool get isLoading => _isLoading;
  int get totalPatients => _allPatients.length;
  int get syncedPatients => _allPatients.where((p) => p.synced).length;
  int get unsyncedPatients => _allPatients.where((p) => !p.synced).length;

  /// Load patients from Hive
  Future<void> loadPatients() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = await Hive.openBox<PatientModel>('patients');
      _allPatients = box.values.toList();
      _allPatients.sort((a, b) => b.patientId.compareTo(a.patientId)); // Sort by ID descending
      _applyFilters();
    } catch (e) {
      print('Error loading patients: $e');
      _allPatients = [];
      _filteredPatients = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search patients by name, CI, or phone
  void searchPatients(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
  }

  /// Filter patients by status
  void filterByStatus(String status) {
    _filterStatus = status;
    _applyFilters();
  }

  /// Apply search and filter logic
  void _applyFilters() {
    _filteredPatients = _allPatients.where((patient) {
      // Apply status filter
      final matchesStatus = _filterStatus == 'todos' ||
          (_filterStatus == 'sincronizados' && patient.synced) ||
          (_filterStatus == 'pendientes' && !patient.synced);

      if (!matchesStatus) return false;

      // Apply search filter
      if (_searchQuery.isEmpty) return true;

      final matchesName = patient.name.toLowerCase().contains(_searchQuery);
      final matchesId = patient.patientId.toString().contains(_searchQuery);

      return matchesName || matchesId;
    }).toList();

    notifyListeners();
  }

  /// Add new patient
  Future<bool> addPatient(PatientModel patient) async {
    try {
      final box = await Hive.openBox<PatientModel>('patients');
      await box.add(patient);
      await loadPatients();
      return true;
    } catch (e) {
      print('Error adding patient: $e');
      return false;
    }
  }

  /// Update existing patient
  Future<bool> updatePatient(PatientModel patient) async {
    try {
      await patient.save();
      await loadPatients();
      return true;
    } catch (e) {
      print('Error updating patient: $e');
      return false;
    }
  }

  /// Delete patient
  Future<bool> deletePatient(PatientModel patient) async {
    try {
      await patient.delete();
      await loadPatients();
      return true;
    } catch (e) {
      print('Error deleting patient: $e');
      return false;
    }
  }

  /// Toggle patient sync status
  Future<bool> toggleSyncStatus(PatientModel patient) async {
    try {
      patient.synced = !patient.synced;
      await patient.save();
      await loadPatients();
      return true;
    } catch (e) {
      print('Error toggling patient sync status: $e');
      return false;
    }
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _filterStatus = 'todos';
    _applyFilters();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
