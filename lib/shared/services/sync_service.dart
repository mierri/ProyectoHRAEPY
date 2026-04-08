import 'package:ssapp/core/network/connectivity_service.dart';
import 'package:ssapp/shared/services/syncable.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/features/surveys/data/survey_repository.dart';
import 'package:ssapp/core/logger/app_logger.dart';

// Responsabilidad: ser el unico punto de entrada para sincronizacion de pacientes y encuestas.
class SyncService {
  final PatientService patientService;
  final SurveyRepository surveyRepository;
  final ISyncable _patientSyncable;
  final ISyncable _surveySyncable;
  final ConnectivityService _connectivityService = ConnectivityService();

  SyncService({
    required this.patientService,
    required this.surveyRepository,
  })  : _patientSyncable = patientService,
        _surveySyncable = surveyRepository;

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

    final patientsSynced = await patientService.countPendingPatients();
    final surveysSynced = await _countPendingSurveys();
    bool patientsSuccess = true;
    bool surveysSuccess = true;

    // Sincronizar pacientes pendientes
    try {
      await _patientSyncable.syncPendingToServer();
      await _patientSyncable.downloadFromServer();
    } catch (e) {
      AppLogger.error('Error al sincronizar pacientes', e);
      patientsSuccess = false;
    }

    // Sincronizar encuestas pendientes
    try {
      await _surveySyncable.syncPendingToServer();
      await _surveySyncable.downloadFromServer();
    } catch (e) {
      AppLogger.error('Error al sincronizar encuestas', e);
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

    final patientsSynced = await patientService.countPendingPatients();
    final surveysSynced = await _countPendingSurveys();

    await _patientSyncable.syncPendingToServer();
    await _surveySyncable.syncPendingToServer();

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

    await _patientSyncable.downloadFromServer();
    await _surveySyncable.downloadFromServer();

    return SyncResult(
      success: true,
      message: 'Datos descargados del servidor',
      patientsSynced: 0,
      surveysSynced: 0,
    );
  }

  /// Obtiene estadísticas de sincronización
  Future<SyncStats> getStats() async {
    final patients = patientService.patients;
    final unsyncedSurveys = await _countPendingSurveys();
    final totalSurveys = await _countTotalSurveys();

    return SyncStats(
      totalPatients: patients.length,
      unsyncedPatients: patients.where((p) => !p.synced).length,
      totalSurveys: totalSurveys,
      unsyncedSurveys: unsyncedSurveys,
    );
  }

  /// Verifica si hay datos pendientes de sincronizar
  Future<bool> hasPendingSync() async {
    final stats = await getStats();
    return stats.unsyncedPatients > 0 || stats.unsyncedSurveys > 0;
  }

  Future<int> _countPendingSurveys() async {
    final surveys = await surveyRepository.loadSurveys();
    return surveys.where((s) => s['synced'] != true).length;
  }

  Future<int> _countTotalSurveys() async {
    final surveys = await surveyRepository.loadSurveys();
    return surveys.length;
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
