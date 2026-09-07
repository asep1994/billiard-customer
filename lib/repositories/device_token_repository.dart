import '../core/api_client.dart';

class DeviceTokenRepository {
  DeviceTokenRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<void> register(String token) async {
    await _api.post('/customer/device-tokens', data: {
      'token': token,
      'platform': 'android',
    });
  }

  Future<void> unregister(String token) async {
    await _api.delete('/customer/device-tokens?token=${Uri.encodeComponent(token)}');
  }
}
