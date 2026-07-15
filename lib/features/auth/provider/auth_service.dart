import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ssapp/core/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthLoginResult {
  const AuthLoginResult._({required this.success, this.message});

  final bool success;
  final String? message;

  const AuthLoginResult.success() : this._(success: true);

  const AuthLoginResult.failure(String message)
    : this._(success: false, message: message);
}

/// Authentication service backed by Supabase Auth.
class AuthService extends ChangeNotifier {
  late final SupabaseClient _client;
  late final StreamSubscription<AuthState> _authSubscription;

  bool _isAuthenticated = true;
  String? _userEmail;
  String? _userRole;
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;
  User? get currentUser => _client.auth.currentUser;

  AuthService() {
    _client = SupabaseConfig.client;
    _syncFromSession(_client.auth.currentSession);
    _authSubscription = _client.auth.onAuthStateChange.listen((event) {
      _syncFromSession(event.session);
    });
  }

  Future<AuthLoginResult> login(String email, String password) async {
    final lockedMessage = _currentLockMessage();
    if (lockedMessage != null) {
      return AuthLoginResult.failure(lockedMessage);
    }

    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (response.session == null) {
        _registerFailedAttempt();
        return const AuthLoginResult.failure(
          'No pudimos iniciar sesion. Revisa tus datos e intenta de nuevo.',
        );
      }

      _failedAttempts = 0;
      _lockedUntil = null;
      _syncFromSession(response.session);
      return const AuthLoginResult.success();
    } on AuthException catch (error) {
      _registerFailedAttempt();

      if (error.statusCode == '429') {
        return const AuthLoginResult.failure(
          'Demasiados intentos. Espera un momento antes de volver a intentar.',
        );
      }

      return const AuthLoginResult.failure('Correo o contrasena incorrectos.');
    } catch (_) {
      return const AuthLoginResult.failure(
        'No se pudo conectar con Supabase. Intenta nuevamente.',
      );
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    _isAuthenticated = false;
    _userEmail = null;
    _userRole = null;
    notifyListeners();
  }

  void _syncFromSession(Session? session) {
    final user = session?.user;
    _isAuthenticated = session != null;
    _userEmail = user?.email;
    _userRole = user?.appMetadata['role']?.toString();
    notifyListeners();
  }

  String? _currentLockMessage() {
    final lockedUntil = _lockedUntil;
    if (lockedUntil == null) return null;

    final remaining = lockedUntil.difference(DateTime.now());
    if (remaining.isNegative) {
      _lockedUntil = null;
      _failedAttempts = 0;
      return null;
    }

    return 'Demasiados intentos fallidos. Intenta de nuevo en '
        '${remaining.inSeconds + 1} segundos.';
  }

  void _registerFailedAttempt() {
    _failedAttempts += 1;
    if (_failedAttempts >= 5) {
      _lockedUntil = DateTime.now().add(const Duration(minutes: 1));
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
