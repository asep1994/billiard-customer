import '../core/api_client.dart';
import '../models/billiard_table.dart';
import '../models/venue.dart';

class VenueRepository {
  VenueRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<Venue>> browse({String? city, String? search}) async {
    final response = await _api.get('/customer/venues', query: {
      'per_page': 100,
      if (city != null && city.isNotEmpty) 'city': city,
      if (search != null && search.isNotEmpty) 'search': search,
    });

    final data = response['data'] as List<dynamic>? ?? [];
    return data.whereType<Map<String, dynamic>>().map(Venue.fromJson).toList();
  }

  Future<Venue> show(int venueId) async {
    final response = await _api.get('/customer/venues/$venueId');
    return Venue.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<BilliardTable>> availableTables({
    required int venueId,
    required DateTime start,
    required DateTime end,
  }) async {
    final response = await _api.get('/customer/venues/$venueId/available-tables', query: {
      'start_time': start.toIso8601String(),
      'end_time': end.toIso8601String(),
    });

    final data = response['data'] as List<dynamic>? ?? [];
    return data.whereType<Map<String, dynamic>>().map(BilliardTable.fromJson).toList();
  }
}
