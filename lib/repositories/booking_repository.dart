import '../core/api_client.dart';
import '../models/booking.dart';

class BookingRepository {
  BookingRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<Booking>> myBookings() async {
    final response = await _api.get('/customer/bookings', query: {'per_page': 100});
    final data = response['data'] as List<dynamic>? ?? [];
    return data.whereType<Map<String, dynamic>>().map(Booking.fromJson).toList();
  }

  Future<Booking> show(int bookingId) async {
    final response = await _api.get('/customer/bookings/$bookingId');
    return Booking.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Booking> create({
    required int venueId,
    required int billiardTableId,
    required DateTime start,
    required DateTime end,
    String? promoCode,
    String? notes,
  }) async {
    final response = await _api.post('/customer/bookings', data: {
      'venue_id': venueId,
      'billiard_table_id': billiardTableId,
      'start_time': start.toIso8601String(),
      'end_time': end.toIso8601String(),
      if (promoCode != null && promoCode.isNotEmpty) 'promo_code': promoCode,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });

    return Booking.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Initiates a Duitku transaction for [bookingId] and returns the payment
  /// URL to open in an external browser.
  Future<String?> pay({required int bookingId, required String paymentMethod}) async {
    final response = await _api.post('/customer/bookings/$bookingId/pay', data: {
      'payment_method': paymentMethod,
    });

    return response['payment_url'] as String?;
  }
}
