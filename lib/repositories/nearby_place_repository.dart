import '../core/api_client.dart';
import '../models/nearby_place.dart';

class NearbyPlaceRepository {
  NearbyPlaceRepository({ApiClient? apiClient})
    : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  /// Billiard venues found near [lat]/[lng] via Google Places that aren't
  /// partnered with Unity Billiard yet.
  Future<List<NearbyPlace>> nearby({
    required double lat,
    required double lng,
  }) async {
    final response = await _api.get(
      '/customer/nearby-places',
      query: {'lat': lat, 'lng': lng},
    );
    final data = response['data'] as List<dynamic>? ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(NearbyPlace.fromJson)
        .toList();
  }

  /// Submits [place] as a lead for the platform's business-dev team to
  /// follow up on - the "Ajak Gabung" action. Safe to call more than once
  /// for the same place; the backend just returns the existing lead.
  Future<void> submitLead(NearbyPlace place) async {
    await _api.post(
      '/customer/partner-leads',
      data: {
        'google_place_id': place.id,
        'name': place.name,
        if (place.address != null) 'address': place.address,
        if (place.latitude != null) 'latitude': place.latitude,
        if (place.longitude != null) 'longitude': place.longitude,
        if (place.rating != null) 'google_rating': place.rating,
        if (place.ratingCount != null) 'google_rating_count': place.ratingCount,
      },
    );
  }
}
