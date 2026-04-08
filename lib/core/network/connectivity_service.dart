import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ssapp/core/logger/app_logger.dart';

/// Servicio para verificar conectividad de red
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Verifica si hay conexión a internet
  Future<bool> hasConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.any((conn) => 
        conn == ConnectivityResult.mobile || 
        conn == ConnectivityResult.wifi ||
        conn == ConnectivityResult.ethernet
      );
    } catch (e) {
      AppLogger.error('Error al verificar conectividad', e);
      return false;
    }
  }

  /// Stream para escuchar cambios en la conectividad
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }

  /// Verifica si hay conexión de tipo específico
  Future<bool> hasConnectionType(ConnectivityResult type) async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.contains(type);
    } catch (e) {
      AppLogger.error('Error al verificar tipo de conectividad', e);
      return false;
    }
  }
}
