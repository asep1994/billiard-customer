import '../core/formatters.dart';

class Booking {
  final int id;
  final int venueId;
  final String? venueName;
  final int billiardTableId;
  final String? tableName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String paymentStatus;
  final double totalPrice;
  final double discountAmount;
  final double payableAmount;
  final String? promoCode;
  final String? notes;

  Booking({
    required this.id,
    required this.venueId,
    this.venueName,
    required this.billiardTableId,
    this.tableName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.paymentStatus,
    required this.totalPrice,
    required this.discountAmount,
    required this.payableAmount,
    this.promoCode,
    this.notes,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final venue = json['venue'] as Map<String, dynamic>?;
    final table = json['billiard_table'] as Map<String, dynamic>?;
    final promotion = json['promotion'] as Map<String, dynamic>?;

    return Booking(
      id: json['id'] as int,
      venueId: json['venue_id'] as int,
      venueName: venue?['name'] as String?,
      billiardTableId: json['billiard_table_id'] as int,
      tableName: table?['name'] as String?,
      startTime: parseApiTimestamp(json['start_time'] as String),
      endTime: parseApiTimestamp(json['end_time'] as String),
      status: json['status'] as String,
      paymentStatus: json['payment_status'] as String,
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0,
      discountAmount: double.tryParse(json['discount_amount'].toString()) ?? 0,
      payableAmount: (json['payable_amount'] as num?)?.toDouble() ?? 0,
      promoCode: promotion?['code'] as String?,
      notes: json['notes'] as String?,
    );
  }

  static const _statusLabels = {
    'pending': 'Menunggu Konfirmasi',
    'confirmed': 'Dikonfirmasi',
    'ongoing': 'Berlangsung',
    'completed': 'Selesai',
    'cancelled': 'Dibatalkan',
  };

  static const _paymentLabels = {
    'unpaid': 'Belum Bayar',
    'partial': 'Sebagian',
    'paid': 'Lunas',
  };

  String get statusLabel => _statusLabels[status] ?? status;
  String get paymentStatusLabel => _paymentLabels[paymentStatus] ?? paymentStatus;
  bool get needsPayment => paymentStatus != 'paid' && status != 'cancelled';
}
