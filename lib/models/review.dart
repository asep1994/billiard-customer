import '../core/formatters.dart';

class Review {
  final int id;
  final int rating;
  final String? comment;
  final String? customerName;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.rating,
    this.comment,
    this.customerName,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      customerName: json['customer_name'] as String?,
      createdAt: parseApiTimestamp(json['created_at'] as String),
    );
  }
}
