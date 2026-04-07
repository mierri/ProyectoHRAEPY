import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:ssapp/Services/contracts/syncable.dart';
import 'package:ssapp/config/supabase_config.dart';
import 'package:ssapp/models/patient_model.dart';

// Responsabilidad: gestionar CRUD y carga de pacientes locales/remotos.
class PatientService extends ChangeNotifier implements ISyncable {
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
        print('Error al abrir Hive box, limpiando datos antiguos: $e');
        await Hive.deleteBoxFromDisk('patients');
        box = await Hive.openBox<PatientModel>('patients');
      }

      await box.add(patient);
      _patients.add(patient);
      notifyListeners();

      return patient;
    } catch (e) {
      return null;
    }
  }

  Future<void> loadPatients() async {
    try {
      final supabasePatients = await getAllPatientsFromSupabase();
      final hivePatients = await _getLocalPatients();
      final Map<int, PatientModel> patientsMap = {};

      for (var patient in supabasePatients) {
        patientsMap[patient.patientId] = patient;
      }

      for (var patient in hivePatients) {
        if (!patientsMap.containsKey(patient.patientId)) {
          patientsMap[patient.patientId] = patient;
        }
      }

      _patients = patientsMap.values.toList()
        ..sort((a, b) => b.patientId.compareTo(a.patientId)); // Más reciente primero

      notifyListeners();
    } catch (e) {
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
        await Hive.deleteBoxFromDisk('patients');
        box = await Hive.openBox<PatientModel>('patients');
      }

      return box.values.toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> syncPatientToSupabase(PatientModel patient) async {
    try {
      final supabase = SupabaseConfig.client;

      await supabase
          .from('patients')
          .upsert(patient.toJson())
          .select()
          .single();

      return true;
    } catch (e) {
      return false;
    }
  }

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
      return [];
    }
  }

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
      return null;
    }
  }

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
      return [];
    }
  }

  Future<bool> updatePatient(PatientModel patient) async {
    try {
      final supabase = SupabaseConfig.client;
      
      await supabase
          .from('patients')
          .update(patient.toJson())
          .eq('patient_id', patient.patientId);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePatient(int patientId) async {
    try {
      // Eliminar de Supabase
      final supabase = SupabaseConfig.client;
      
      await supabase
          .from('patients')
          .delete()
          .eq('patient_id', patientId);

      // Eliminar de la lista local
      _patients.removeWhere((p) => p.patientId == patientId);

      // Eliminar de Hive
      try {
        final box = await Hive.openBox<PatientModel>('patients');
        final keys = box.keys.toList();
        for (var key in keys) {
          final patient = box.get(key);
          if (patient?.patientId == patientId) {
            await box.delete(key);
            break;
          }
        }
      } catch (e) {
        print('Error al eliminar de Hive: $e');
      }

      notifyListeners();
      return true;
    } catch (e) {
      print('Error al eliminar paciente: $e');
      return false;
    }
  }

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
      return [];
    }
  }

  Future<int> syncPendingPatients() async {
    return syncPendingToServer();
  }

  @override
  Future<int> syncPendingToServer() async {
    int syncedCount = 0;

    try {
      // Asegurar que también tomamos pendientes guardados en Hive,
      // incluso si la lista en memoria aún no fue cargada.
      if (_patients.isEmpty) {
        _patients = await _getLocalPatients();
      }

      final pendingPatients = _patients.where((p) => !p.synced).toList();

      if (pendingPatients.isEmpty) {
        final localPatients = await _getLocalPatients();
        final localPending = localPatients.where((p) => !p.synced).toList();
        if (localPending.isNotEmpty) {
          _patients = localPatients;
        }
      }

      final patientsToSync = _patients.where((p) => !p.synced).toList();

      if (patientsToSync.isEmpty) {
        return 0;
      }

      for (var patient in patientsToSync) {
        final success = await syncPatientToSupabase(patient);
        if (success) {
          patient.synced = true;
          await patient.save();
          syncedCount++;
        } else {
          print('No se pudo sincronizar paciente ${patient.name}');
        }
      }

      notifyListeners();

    } catch (e) {
      print('Error al sincronizar pacientes pendientes: $e');
    }

    return syncedCount;
  }

  @override
  Future<void> downloadFromServer() async {
    try {
      final remotePatients = await getAllPatientsFromSupabase();
      final box = await Hive.openBox<PatientModel>('patients');

      for (final remotePatient in remotePatients) {
        final localPatient = box.values
            .where((p) => p.patientId == remotePatient.patientId)
            .firstOrNull;

        if (localPatient == null) {
          remotePatient.synced = true;
          await box.add(remotePatient);
        }
      }

      _patients = box.values.toList()
        ..sort((a, b) => b.patientId.compareTo(a.patientId));
      notifyListeners();
    } catch (e) {
      print('Error al descargar pacientes desde servidor: $e');
    }
  }

  Future<int> countPendingPatients() async {
    if (_patients.isEmpty) {
      _patients = await _getLocalPatients();
    }
    return _patients.where((p) => !p.synced).length;
  }
}
