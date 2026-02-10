import 'package:hive/hive.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:ssapp/models/patient_model.dart';

class PatientProvider {
  late Box<PatientModel> box;
  final PatientService _service = PatientService();

  Future<bool> initBox() async {
    box = await Hive.openBox<PatientModel>('patientBox');
    return box.isOpen;
  }

  Future<bool> addPatient(PatientModel patient) async {
    await box.add(patient);
    bool synced = await _service.syncPatientToSupabase(patient);
    patient.synced = synced;
    await patient.save();
    return true;
  }

  Map<dynamic, dynamic> getAllPatients() {
    Map<dynamic, dynamic> patients = box.toMap();
    return patients;
  }

  List<PatientModel> getAllPatientsAsList() {
    return box.values.toList();
  }

  PatientModel? getPatientByIndex(int index) {
    if (index < 0 || index >= box.length) return null;
    return box.getAt(index);
  }

  PatientModel? getPatientById(int patientId) {
    try {
      return box.values.firstWhere((patient) => patient.patientId == patientId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> deletePatient(int index) async {
    await box.deleteAt(index);
    return true;
  }

  Future<bool> updatePatient(int index, PatientModel patient) async {
    await box.putAt(index, patient);
    bool synced = await _service.updatePatient(patient);
    patient.synced = synced;
    await patient.save();
    return true;
  }

  Future<void> syncPendingPatients() async {
    var patients = getAllPatients();
    for (var entry in patients.entries) {
      PatientModel patient = entry.value;
      if (!patient.synced) {
        bool synced = await _service.syncPatientToSupabase(patient);
        if (synced) {
          patient.synced = true;
          await patient.save();
        }
      }
    }
  }

  Future<void> syncFromSupabase() async {
    try {
      List<PatientModel> remotePatients = await _service.getAllPatientsFromSupabase();
      
      // Actualizar o agregar pacientes del servidor
      for (var remotePatient in remotePatients) {
        // Buscar si ya existe localmente
        var localPatient = getPatientById(remotePatient.patientId);
        
        if (localPatient == null) {
          // No existe localmente, agregarlo
          remotePatient.synced = true;
          await box.add(remotePatient);
        } else {
          // Existe, actualizar si el remoto es más reciente
          // (en este caso simplemente actualizamos con los datos del servidor)
          var index = box.values.toList().indexOf(localPatient);
          if (index != -1) {
            remotePatient.synced = true;
            await box.putAt(index, remotePatient);
          }
        }
      }
    } catch (e) {
      print('Error al sincronizar desde Supabase: $e');
    }
  }

  Future<void> dispose() async {
    await box.close();
  }
}
