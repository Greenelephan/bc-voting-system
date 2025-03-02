import 'package:frontend/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AuthResult { error, election, receipt, admin }

class AuthService {
  final ApiService apiService;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  AuthService(this.apiService);

  Future<AuthResult> authenticate(String userId, String password) async {
    try {
      // Login
      final response = await apiService.post('api/auth/login', {
        'userId': userId,
        'password': password,
      });

      final token = response['token'];
      final role = response['role'];
      await secureStorage.write(key: 'token', value: token);
      await secureStorage.write(key: 'userId', value: userId);

      if (role == 'admin') {
        await secureStorage.write(key: 'isAdmin', value: 'true');
        return AuthResult.admin;
      } else {
        await secureStorage.write(key: 'isAdmin', value: 'false');
        return await _handlePostAuthProcess(userId, token);
      }
    } catch (e) {
      return AuthResult.error;
    }
  }

  Future<AuthResult> _handlePostAuthProcess(String userId, String token) async {
    try {
      // Fetch voter data
      final voterData = await apiService.get('api/voters/$userId/status', useAuth: true);

      if (voterData['hasVoted']) {
        return AuthResult.receipt;
      } else if (!voterData['isRegistered']) {
        // Register voter
        final registrationResponse = await apiService.post('api/voters/register', {}, useAuth: true);
        final registrationToken = registrationResponse['registrationToken'];
        await secureStorage.write(key: 'registrationToken', value: registrationToken);
        return AuthResult.election;
      } else {
        return AuthResult.election;
      }
    } catch (e) {
      return AuthResult.error;
    }
  }
}
