import '../core/formatters.dart';

class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.bookingId,
    required this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      bookingId: json['booking_id'] as int?,
      readAt: json['read_at'] != null ? parseApiTimestamp(json['read_at'] as String) : null,
      createdAt: parseApiTimestamp(json['created_at'] as String),
    );
  }

  final String id;
  final String? type;
  final String? title;
  final String? message;
  final int? bookingId;
  DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;
}
