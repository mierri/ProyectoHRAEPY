import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:ssapp/config/supabase_config.dart';
import 'package:ssapp/models/patient_model.dart';

class PatientService extends ChangeNotifier {
  List<PatientModel> _patients = [];
  
  List<PatientModel> get patients => _patients;
  
  /// Crea un nuevo paciente (funciona offline)
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
      
      // Guardar en Hive primero (funciona offline)
      Box<PatientModel> box;
      try {
        box = await Hive.openBox<PatientModel>('patients');
      } catch (e) {
        print('⚠️ Error al abrir Hive box, limpiando datos antiguos: $e');
        await Hive.deleteBoxFromDisk('patients');
        box = await Hive.openBox<PatientModel>('patients');
      }

      await box.add(patient);
      _patients.add(patient);
      notifyListeners();

      // Intentar sincronizar con Supabase (si hay internet)
      final success = await syncPatientToSupabase(patient);
      if (success) {
        patient.synced = true;
        await patient.save(); // Actualizar en Hive
        notifyListeners();
        print('✅ Paciente sincronizado con Supabase');
      } else {
        print('⚠️ Paciente guardado localmente, pendiente de sincronización');
      }

      return patient;
    } catch (e) {
      print('❌ Error al crear paciente: $e');
      return null;
    }
  }
  
  /// Carga todos los pacientes (desde Hive y Supabase)
  Future<void> loadPatients() async {
    try {
      // Cargar desde Supabase
      final supabasePatients = await getAllPatientsFromSupabase();

      // Cargar desde Hive
      final hivePatients = await _getLocalPatients();

      // Combinar: priorizar Supabase, agregar los de Hive que no estén
      final Map<int, PatientModel> patientsMap = {};

      // Agregar pacientes de Supabase
      for (var patient in supabasePatients) {
        patientsMap[patient.patientId] = patient;
      }

      // Agregar pacientes locales que no estén en Supabase
      for (var patient in hivePatients) {
        if (!patientsMap.containsKey(patient.patientId)) {
          patientsMap[patient.patientId] = patient;
        }
      }

      _patients = patientsMap.values.toList()
        ..sort((a, b) => b.patientId.compareTo(a.patientId)); // Más reciente primero

      notifyListeners();
    } catch (e) {
      print('Error al cargar pacientes: $e');
      // Si falla Supabase, al menos cargar los locales
      _patients = await _getLocalPatients();
      notifyListeners();
    }
  }

  /// Obtiene pacientes desde Hive (almacenamiento local)
  Future<List<PatientModel>> _getLocalPatients() async {
    try {
      Box<PatientModel> box;
      try {
        box = await Hive.openBox<PatientModel>('patients');
      } catch (e) {
        print('⚠️ Error al abrir Hive box, limpiando datos antiguos: $e');
        await Hive.deleteBoxFromDisk('patients');
        box = await Hive.openBox<PatientModel>('patients');
      }

      return box.values.toList();
    } catch (e) {
      print('Error al cargar pacientes locales: $e');
      return [];
    }
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

  /// Sincroniza pacientes pendientes con Supabase
  Future<int> syncPendingPatients() async {
    int syncedCount = 0;

    try {
      final pendingPatients = _patients.where((p) => !p.synced).toList();

      if (pendingPatients.isEmpty) {
        print('✅ No hay pacientes pendientes de sincronización');
        return 0;
      }

      print('📤 Sincronizando ${pendingPatients.length} pacientes pendientes...');

      for (var patient in pendingPatients) {
        final success = await syncPatientToSupabase(patient);
        if (success) {
          patient.synced = true;
          await patient.save();
          syncedCount++;
          print('✅ Paciente ${patient.name} sincronizado');
        } else {
          print('⚠️ No se pudo sincronizar paciente ${patient.name}');
        }
      }

      notifyListeners();
      print('✅ Sincronización completada: $syncedCount/${ pendingPatients.length} pacientes');

    } catch (e) {
      print('❌ Error al sincronizar pacientes pendientes: $e');
    }

    return syncedCount;
  }
}
