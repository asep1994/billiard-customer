import '../core/formatters.dart';

class Promotion {
  final int id;
  final String? vendorName;
  final String code;
  final String type;
  final double value;
  final double? maxDiscount;
  final DateTime? expiresAt;
  final bool isValidNow;

  Promotion({
    required this.id,
    this.vendorName,
    required this.code,
    required this.type,
    required this.value,
    this.maxDiscount,
    this.expiresAt,
    required this.isValidNow,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'] as Map<String, dynamic>?;

    return Promotion(
      id: json['id'] as int,
      vendorName: vendor?['name'] as String?,
      code: json['code'] as String,
      type: json['type'] as String,
      value: double.parse(json['value'].toString()),
      maxDiscount: json['max_discount'] != null ? double.parse(json['max_discount'].toString()) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      isValidNow: json['is_valid_now'] as bool? ?? false,
    );
  }

  String get discountLabel {
    return type == 'percentage' ? '${value.toStringAsFixed(0)}%' : formatCurrency(value);
  }
}
