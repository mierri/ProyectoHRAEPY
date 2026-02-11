import 'package:flutter/foundation.dart';
import 'package:ssapp/config/supabase_config.dart';
import 'package:ssapp/models/patient_model.dart';

class PatientService extends ChangeNotifier {
  List<PatientModel> _patients = [];
  
  List<PatientModel> get patients => _patients;
  
  /// Crea un nuevo paciente
  Future<PatientModel?> createPatient({
    required String name,
    required String gender,
    required DateTime birthDate,
  }) async {
    try {
      final patientId = DateTime.now().millisecondsSinceEpoch;
      final patient = PatientModel(
        patientId: patientId,
        name: name,
        gender: gender,
        birthDate: birthDate,
        synced: false,
      );
      
      // Sincronizar con Supabase
      final success = await syncPatientToSupabase(patient);
      if (success) {
        patient.synced = true;
        _patients.add(patient);
        notifyListeners();
        return patient;
      }
      return null;
    } catch (e) {
      print('Error al crear paciente: $e');
      return null;
    }
  }
  
  /// Carga todos los pacientes
  Future<void> loadPatients() async {
    _patients = await getAllPatientsFromSupabase();
    notifyListeners();
  }
  /// Sincroniza un paciente con Supabase
  Future<bool> syncPatientToSupabase(PatientModel patient) async {
    try {
      final supabase = SupabaseConfig.client;
      
      // Insertar o actualizar el paciente (upsert)
      await supabase
          .from('patients')
          .upsert(patient.toJson())
          .select()
          .single();

      return true;
    } catch (e) {
      print('Error al sincronizar paciente con Supabase: $e');
      return false;
    }
  }

  /// Obtiene todos los pacientes desde Supabase
  Future<List<PatientModel>> getAllPatientsFromSupabase() async {
    try {
      final supabase = SupabaseConfig.client;
      
      final data = await supabase
          .from('patients')
          .select()
          .order('created_at', ascending: false);

      return (data as List)
          .map((json) => PatientModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error al obtener pacientes de Supabase: $e');
      return [];
    }
  }

  /// Obtiene un paciente por ID
  Future<PatientModel?> getPatientById(int patientId) async {
    try {
      final supabase = SupabaseConfig.client;
      
      final data = await supabase
          .from('patients')
          .select()
          .eq('patient_id', patientId)
          .single();

      return PatientModel.fromJson(data);
    } catch (e) {
      print('Error al obtener paciente: $e');
      return null;
    }
  }

  /// Busca pacientes por nombre
  Future<List<PatientModel>> searchPatientsByName(String query) async {
    try {
      final supabase = SupabaseConfig.client;
      
      final data = await supabase
          .from('patients')
          .select()
          .ilike('name', '%$query%')
          .order('name');

      return (data as List)
          .map((json) => PatientModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error al buscar pacientes: $e');
      return [];
    }
  }

  /// Actualiza un paciente
  Future<bool> updatePatient(PatientModel patient) async {
    try {
      final supabase = SupabaseConfig.client;
      
      await supabase
          .from('patients')
          .update(patient.toJson())
          .eq('patient_id', patient.patientId);

      return true;
    } catch (e) {
      print('Error al actualizar paciente: $e');
      return false;
    }
  }

  /// Elimina un paciente
  Future<bool> deletePatient(int patientId) async {
    try {
      final supabase = SupabaseConfig.client;
      
      await supabase
          .from('patients')
          .delete()
          .eq('patient_id', patientId);

      return true;
    } catch (e) {
      print('Error al eliminar paciente: $e');
      return false;
    }
  }

  /// Obtiene las encuestas de un paciente
  Future<List<Map<String, dynamic>>> getPatientSurveys(int patientId) async {
    try {
      final supabase = SupabaseConfig.client;
      
      final data = await supabase
          .from('surveys')
          .select('*, responses(*)')
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error al obtener encuestas del paciente: $e');
      return [];
    }
  }
}
