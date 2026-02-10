import 'package:ssapp/provider/patient_provider.dart';
import 'package:ssapp/provider/survey_provider.dart';
import 'package:ssapp/Services/connectivity_service.dart';

/// Servicio centralizado para gestionar sincronización de datos
class SyncService {
  final PatientProvider patientProvider;
  final SurveyProvider surveyProvider;
  final ConnectivityService _connectivityService = ConnectivityService();

  SyncService({
    required this.patientProvider,
    required this.surveyProvider,
  });

  /// Sincroniza todos los datos (pacientes y encuestas)
  /// Devuelve true si todo se sincronizó correctamente
  Future<SyncResult> syncAll() async {
    final hasConnection = await _connectivityService.hasConnection();
    
    if (!hasConnection) {
      return SyncResult(
        success: false,
        message: 'Sin conexión a internet',
        patientsSynced: 0,
        surveysSynced: 0,
      );
    }

    int patientsSynced = 0;
    int surveysSynced = 0;
    bool patientsSuccess = true;
    bool surveysSuccess = true;

    // Sincronizar pacientes pendientes
    try {
      await patientProvider.syncPendingPatients();
      // Contar pacientes no sincronizados antes
      final unsyncedPatients = patientProvider
          .getAllPatientsAsList()
          .where((p) => !p.synced)
          .length;
      patientsSynced = unsyncedPatients;
      
      // Descargar pacientes del servidor
      await patientProvider.syncFromSupabase();
    } catch (e) {
      print('Error al sincronizar pacientes: $e');
      patientsSuccess = false;
    }

    // Sincronizar encuestas pendientes
    try {
      // Contar encuestas no sincronizadas antes
      final unsyncedSurveys = surveyProvider
          .getAllSurveysAsList()
          .where((s) => !s.synced)
          .length;
      surveysSynced = unsyncedSurveys;
      
      await surveyProvider.syncPendingSurveys();
      
      // Descargar encuestas del servidor
      await surveyProvider.syncFromSupabase();
    } catch (e) {
      print('Error al sincronizar encuestas: $e');
      surveysSuccess = false;
    }

    final success = patientsSuccess && surveysSuccess;
    String message;
    
    if (success) {
      message = 'Sincronización completada: $patientsSynced pacientes, $surveysSynced encuestas';
    } else if (!patientsSuccess && !surveysSuccess) {
      message = 'Error al sincronizar pacientes y encuestas';
    } else if (!patientsSuccess) {
      message = 'Error al sincronizar pacientes';
    } else {
      message = 'Error al sincronizar encuestas';
    }

    return SyncResult(
      success: success,
      message: message,
      patientsSynced: patientsSynced,
      surveysSynced: surveysSynced,
    );
  }

  /// Solo sincroniza datos pendientes locales al servidor
  Future<SyncResult> syncPendingOnly() async {
    final hasConnection = await _connectivityService.hasConnection();
    
    if (!hasConnection) {
      return SyncResult(
        success: false,
        message: 'Sin conexión a internet',
        patientsSynced: 0,
        surveysSynced: 0,
      );
    }

    int patientsSynced = 0;
    int surveysSynced = 0;

    // Contar y sincronizar pacientes pendientes
    final unsyncedPatients = patientProvider
        .getAllPatientsAsList()
        .where((p) => !p.synced)
        .length;
    patientsSynced = unsyncedPatients;
    await patientProvider.syncPendingPatients();

    // Contar y sincronizar encuestas pendientes
    final unsyncedSurveys = surveyProvider
        .getAllSurveysAsList()
        .where((s) => !s.synced)
        .length;
    surveysSynced = unsyncedSurveys;
    await surveyProvider.syncPendingSurveys();

    return SyncResult(
      success: true,
      message: 'Datos locales sincronizados',
      patientsSynced: patientsSynced,
      surveysSynced: surveysSynced,
    );
  }

  /// Solo descarga datos del servidor
  Future<SyncResult> downloadFromServer() async {
    final hasConnection = await _connectivityService.hasConnection();
    
    if (!hasConnection) {
      return SyncResult(
        success: false,
        message: 'Sin conexión a internet',
        patientsSynced: 0,
        surveysSynced: 0,
      );
    }

    await patientProvider.syncFromSupabase();
    await surveyProvider.syncFromSupabase();

    return SyncResult(
      success: true,
      message: 'Datos descargados del servidor',
      patientsSynced: 0,
      surveysSynced: 0,
    );
  }

  /// Obtiene estadísticas de sincronización
  SyncStats getStats() {
    final patients = patientProvider.getAllPatientsAsList();
    final surveys = surveyProvider.getAllSurveysAsList();

    return SyncStats(
      totalPatients: patients.length,
      unsyncedPatients: patients.where((p) => !p.synced).length,
      totalSurveys: surveys.length,
      unsyncedSurveys: surveys.where((s) => !s.synced).length,
    );
  }

  /// Verifica si hay datos pendientes de sincronizar
  bool hasPendingSync() {
    final stats = getStats();
    return stats.unsyncedPatients > 0 || stats.unsyncedSurveys > 0;
  }
}

/// Resultado de una operación de sincronización
class SyncResult {
  final bool success;
  final String message;
  final int patientsSynced;
  final int surveysSynced;

  SyncResult({
    required this.success,
    required this.message,
    required this.patientsSynced,
    required this.surveysSynced,
  });

  @override
  String toString() => message;
}

/// Estadísticas de sincronización
class SyncStats {
  final int totalPatients;
  final int unsyncedPatients;
  final int totalSurveys;
  final int unsyncedSurveys;

  SyncStats({
    required this.totalPatients,
    required this.unsyncedPatients,
    required this.totalSurveys,
    required this.unsyncedSurveys,
  });

  bool get hasPending => unsyncedPatients > 0 || unsyncedSurveys > 0;
  int get totalPending => unsyncedPatients + unsyncedSurveys;

  @override
  String toString() {
    return 'Pacientes: $totalPatients ($unsyncedPatients pendientes) | '
           'Encuestas: $totalSurveys ($unsyncedSurveys pendientes)';
  }
}
