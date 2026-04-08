import 'dart:async';

class NetworkExecutor {
  static const Duration defaultTimeout = Duration(seconds: 12);
  static const int maxRetries = 2;

  static Future<T> runWithRetry<T>(
    Future<T> Function() action, {
    Duration timeout = defaultTimeout,
    int retries = maxRetries,
    String operationName = 'network operation',
  }) async {
    Object? lastError;

    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        return await action().timeout(timeout);
      } catch (error) {
        lastError = error;
        final isLastAttempt = attempt == retries;
        final isRetriable = isTransientError(error) || error is TimeoutException;

        if (isLastAttempt || !isRetriable) {
          rethrow;
        }

        final backoff = Duration(milliseconds: 400 * (attempt + 1));
        await Future.delayed(backoff);
      }
    }

    throw lastError ?? Exception('Error desconocido en $operationName');
  }

  static bool isTransientError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('connection timed out') ||
        message.contains('timed out') ||
        message.contains('network is unreachable') ||
        message.contains('failed host lookup') ||
        message.contains('connection reset');
  }
}
