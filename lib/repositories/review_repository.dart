import '../core/api_client.dart';
import '../models/review.dart';

class ReviewRepository {
  ReviewRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<Review>> forVenue(int venueId) async {
    final response = await _api.get('/customer/venues/$venueId/reviews', query: {'per_page': 50});
    final data = response['data'] as List<dynamic>? ?? [];
    return data.whereType<Map<String, dynamic>>().map(Review.fromJson).toList();
  }

  Future<Review> submit({required int bookingId, required int rating, String? comment}) async {
    final response = await _api.post('/customer/bookings/$bookingId/review', data: {
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
    return Review.fromJson(response['data'] as Map<String, dynamic>);
  }
}
