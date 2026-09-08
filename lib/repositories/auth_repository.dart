import '../core/api_client.dart';

class AuthRepository {
  AuthRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<String> forgotPassword(String email) async {
    final response = await _api.post('/customer/forgot-password', data: {'email': email});
    return response['message'] as String? ?? 'Kode reset password telah dikirim.';
  }

  Future<String> resetPassword({required String email, required String code, required String password}) async {
    final response = await _api.post('/customer/reset-password', data: {
      'email': email,
      'code': code,
      'password': password,
      'password_confirmation': password,
    });
    return response['message'] as String? ?? 'Password berhasil direset.';
  }
}
