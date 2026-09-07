import '../core/api_client.dart';
import '../models/promotion.dart';

class PromotionRepository {
  PromotionRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<Promotion>> list() async {
    final response = await _api.get('/customer/promotions');
    final data = response['data'] as List<dynamic>? ?? [];
    return data.whereType<Map<String, dynamic>>().map(Promotion.fromJson).toList();
  }
}
