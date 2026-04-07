import 'package:hive_flutter/hive_flutter.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:ssapp/models/patient_model.dart';
import 'package:ssapp/models/response_model.dart';
import 'package:ssapp/models/survey_model.dart';
import 'package:ssapp/provider/patient_provider.dart';
import 'package:ssapp/provider/survey_provider.dart';
import 'package:ssapp/Services/sync_service.dart';
import 'package:ssapp/Services/surveys/survey_repository.dart';

/// Helper para inicializar la base de datos local (Hive) y providers
// Responsabilidad: inicializar Hive y utilidades auxiliares de datos/sincronizacion.
class DatabaseHelper {
  static bool _initialized = false;
  
  static PatientProvider? _patientProvider;
  static SurveyProvider? _surveyProvider;
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
    
    _initialized = true;
  }

  /// Inicializa todos los providers
  static Future<void> initializeProviders() async {
    if (!_initialized) {
      await initializeHive();
    }

    // Inicializar PatientProvider
    _patientProvider = PatientProvider();
    await _patientProvider!.initBox();

    // Inicializar SurveyProvider
    _surveyProvider = SurveyProvider();
    await _surveyProvider!.initBox();

    // Inicializar SyncService
    _patientService = PatientService();
    _surveyRepository = SurveyRepository();
    _syncService = SyncService(
      patientService: _patientService!,
      surveyRepository: _surveyRepository!,
    );
  }

  /// Obtiene el PatientProvider (debe llamarse después de initializeProviders)
  static PatientProvider get patientProvider {
    if (_patientProvider == null) {
      throw StateError('PatientProvider no inicializado. Llama a initializeProviders() primero.');
    }
    return _patientProvider!;
  }

  /// Obtiene el SurveyProvider (debe llamarse después de initializeProviders)
  static SurveyProvider get surveyProvider {
    if (_surveyProvider == null) {
      throw StateError('SurveyProvider no inicializado. Llama a initializeProviders() primero.');
    }
    return _surveyProvider!;
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
      print('Sincronización inicial completada');
    } catch (e) {
      print('Error en sincronización inicial: $e');
      // No es crítico, la app funciona offline
    }
  }

  /// Cierra todos los providers y cajas de Hive
  static Future<void> dispose() async {
    if (_patientProvider != null) {
      await _patientProvider!.dispose();
      _patientProvider = null;
    }
    
    if (_surveyProvider != null) {
      await _surveyProvider!.dispose();
      _surveyProvider = null;
    }
    
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
