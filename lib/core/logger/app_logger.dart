import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  static void debug(String message, [Object? error]) =>
      _log(LogLevel.debug, message, error);
  static void info(String message, [Object? error]) =>
      _log(LogLevel.info, message, error);
  static void warning(String message, [Object? error]) =>
      _log(LogLevel.warning, message, error);
  static void error(String message, [Object? error, StackTrace? stack]) =>
      _log(LogLevel.error, message, error, stack);

  static void _log(LogLevel level, String message,
      [Object? error, StackTrace? stack]) {
    if (kReleaseMode && level == LogLevel.debug) return;
    final prefix = switch (level) {
      LogLevel.debug => '🔍 DEBUG',
      LogLevel.info => '✅ INFO ',
      LogLevel.warning => '⚠️  WARN ',
      LogLevel.error => '🔴 ERROR',
    };
    debugPrint('$prefix | $message');
    if (error != null) debugPrint('       ↳ $error');
    if (stack != null) debugPrint('       ↳ $stack');
  }
}
