import '../core/api_client.dart';

class ConfigRepository {
  ConfigRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<double> serviceFee() async {
    final response = await _api.get('/customer/config');
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return (data['service_fee'] as num?)?.toDouble() ?? 0;
  }
}
