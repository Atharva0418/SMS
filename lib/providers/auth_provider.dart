import 'package:flutter/material.dart';

import '../core/local/secure_storage.dart';
import '../core/network/auth_service.dart';

enum AuthState { unknown, unauthenticated, pendingApproval, authenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.unknown;
  String? _role;
  String? _name;
  int? _userId;
  int? _flatNumber;
  String? _errorMessage;
  bool _isLoading = false;

  AuthState get state => _state;
  String? get role => _role;
  String? get name => _name;
  int? get userId => _userId;
  int? get flatNumber => _flatNumber;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  bool get isAdmin => _role == 'ADMIN';
  bool get isStaff => _role == 'STAFF';
  bool get isResident => _role == 'RESIDENT';

  /// Called from main() to restore session from secure storage.
  Future<void> init() async {
    final hasToken = await SecureStorage.hasToken();
    if (!hasToken) {
      _state = AuthState.unauthenticated;
    } else {
      _role = await SecureStorage.getRole();
      _name = await SecureStorage.getName();
      _userId = await SecureStorage.getUserId();
      _flatNumber = await SecureStorage.getFlatNumber();
      _state = AuthState.authenticated;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _role = await _authService.login(email, password);
      _name = await SecureStorage.getName();
      _userId = await SecureStorage.getUserId();
      _flatNumber = await SecureStorage.getFlatNumber();
      _state = AuthState.authenticated;
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('approved')) {
        _state = AuthState.pendingApproval;
      } else {
        _errorMessage = _humanize(msg);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    int? flatNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
        role: role,
        flatNumber: flatNumber,
      );
      _state = AuthState.pendingApproval;
      return true;
    } on Exception catch (e) {
      _errorMessage = _humanize(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _role = null;
    _name = null;
    _userId = null;
    _flatNumber = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  String _humanize(String raw) {
    if (raw.contains('400')) return 'Invalid request. Check your details.';
    if (raw.contains('401') || raw.contains('credentials'))
      return 'Incorrect email or password.';
    if (raw.contains('409') || raw.contains('already'))
      return 'Email already registered.';
    if (raw.contains('SocketException') || raw.contains('connect'))
      return 'Cannot reach server.';
    return 'Something went wrong. Please try again.';
  }
}
