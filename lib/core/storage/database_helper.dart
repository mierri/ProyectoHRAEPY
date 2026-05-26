import 'package:hive_flutter/hive_flutter.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/shared/models/patient_model.dart';
import 'package:ssapp/shared/models/response_model.dart';
import 'package:ssapp/shared/models/survey_model.dart';
import 'package:ssapp/shared/services/sync_service.dart';
import 'package:ssapp/features/surveys/data/survey_repository.dart';
import 'package:ssapp/core/logger/app_logger.dart';

/// Helper para inicializar la base de datos local (Hive) y providers
// Responsabilidad: inicializar Hive y utilidades auxiliares de datos/sincronizacion.
class DatabaseHelper {
  static bool _initialized = false;

  static SyncService? _syncService;
  static PatientService? _patientService;
  static SurveyRepository? _surveyRepository;

  /// Inicializa Hive y registra todos los adaptadores
  static Future<void> initializeHive() async {
    if (_initialized) return;

    await Hive.initFlutter();
    
    // Registrar adaptadores
    Hive.registerAdapter(PatientModelAdapter());
    Hive.registerAdapter(SurveyModelAdapter());
    Hive.registerAdapter(ResponseModelAdapter());
    Hive.registerAdapter(InvestigationModelAdapter());
    
    _initialized = true;
  }

  /// Inicializa servicios de sincronización
  static Future<void> initializeProviders() async {
    if (!_initialized) {
      await initializeHive();
    }

    // Inicializar SyncService
    _patientService = PatientService();
    _surveyRepository = SurveyRepository();
    _syncService = SyncService(
      patientService: _patientService!,
      surveyRepository: _surveyRepository!,
    );
  }

  /// Obtiene el SyncService (debe llamarse después de initializeProviders)
  static SyncService get syncService {
    if (_syncService == null) {
      throw StateError('SyncService no inicializado. Llama a initializeProviders() primero.');
    }
    return _syncService!;
  }

  /// Realiza sincronización inicial al arrancar la app
  static Future<void> initialSync() async {
    try {
      // Intentar descargar datos del servidor
      await syncService.downloadFromServer();
      AppLogger.info('Sincronización inicial completada');
    } catch (e) {
      AppLogger.error('Error en sincronización inicial', e);
      // No es crítico, la app funciona offline
    }
  }

  /// Cierra todos los providers y cajas de Hive
  static Future<void> dispose() async {
    _syncService = null;
    _patientService = null;
    _surveyRepository = null;
  }

  /// Verifica si hay datos pendientes de sincronizar
  static Future<bool> get hasPendingSync async {
    if (_syncService == null) return false;
    return _syncService!.hasPendingSync();
  }

  /// Obtiene estadísticas de sincronización
  static Future<SyncStats?> get syncStats async {
    if (_syncService == null) return null;
    return _syncService!.getStats();
  }
}
