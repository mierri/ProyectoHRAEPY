import 'package:flutter/foundation.dart';

/// Authentication service to handle login logic
class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userRole;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;

  /// Test credentials
  final Map<String, Map<String, String>> _testUsers = {
    'admin@hraepy.com': {
      'password': 'admin123',
      'role': 'admin',
    },
    'maria@hraepy.com': {
      'password': 'student123',
      'role': 'student',
    },
  };

  /// Simulate login process
  Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check credentials
    if (_testUsers.containsKey(email) &&
        _testUsers[email]!['password'] == password) {
      _isAuthenticated = true;
      _userEmail = email;
      _userRole = _testUsers[email]!['role'];
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Logout user
  void logout() {
    _isAuthenticated = false;
    _userEmail = null;
    _userRole = null;
    notifyListeners();
  }
}
