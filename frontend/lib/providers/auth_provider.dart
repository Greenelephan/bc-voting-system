import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final ApiService apiService;
  final AuthService authService;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool _isLoggedIn = false;
  bool _isAdmin = false;
  String? _token;

  AuthProvider({required this.apiService})
      : authService = AuthService(apiService);

  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  String? get token => _token;

  Future<AuthResult> login(String userId, String password) async {
    final result = await authService.authenticate(userId, password);
    if (result == AuthResult.admin) {
      _isAdmin = true;
    } else {
      _isAdmin = false;
    }
    _isLoggedIn = result != AuthResult.error;
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _isAdmin = false;
    _token = null;

    await secureStorage.delete(key: 'token');
    await secureStorage.delete(key: 'isAdmin');
    await secureStorage.delete(key: 'registrationToken');
    await secureStorage.delete(key: 'selectedVote1');
    await secureStorage.delete(key: 'selectedVote2');

    notifyListeners();
  }
}