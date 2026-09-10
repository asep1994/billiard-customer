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
  /// URL to open in the in-app payment WebView.
  Future<String?> pay({required int bookingId, required String paymentMethod}) async {
    final response = await _api.post('/customer/bookings/$bookingId/pay', data: {
      'payment_method': paymentMethod,
    });

    return response['payment_url'] as String?;
  }

  /// Actively re-checks a booking's payment status with the backend rather
  /// than waiting for Duitku's webhook - necessary in local dev (Duitku's
  /// servers can't reach a callback URL on localhost) and a useful safety
  /// net in production too if the webhook is ever delayed. Call this after
  /// the payment WebView closes.
  Future<Booking> refreshPayment(int bookingId) async {
    final response = await _api.post('/customer/bookings/$bookingId/refresh-payment');
    return Booking.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Cancels one of the customer's own bookings - only valid while it's
  /// still pending/confirmed and hasn't started yet (see [Booking.canCancel]).
  Future<Booking> cancel(int bookingId) async {
    final response = await _api.post('/customer/bookings/$bookingId/cancel');
    return Booking.fromJson(response['data'] as Map<String, dynamic>);
  }
}
