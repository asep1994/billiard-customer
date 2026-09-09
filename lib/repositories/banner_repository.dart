import '../core/api_client.dart';
import '../models/app_banner.dart';

class BannerRepository {
  BannerRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<AppBanner>> list() async {
    final response = await _api.get('/customer/banners');
    final data = response['data'] as List<dynamic>? ?? [];
    return data.whereType<Map<String, dynamic>>().map(AppBanner.fromJson).toList();
  }
}
