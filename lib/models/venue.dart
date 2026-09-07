import '../core/api_client.dart';
import 'billiard_table.dart';

class Venue {
  final int id;
  final int vendorId;
  final String? vendorName;
  final String name;
  final String? address;
  final String? city;
  final String? phone;
  final String? openingTime;
  final String? closingTime;
  final String status;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final String? photoUrl;
  final double? rating;
  final int reviewsCount;
  final double? priceFrom;
  bool isFavorited;
  final List<BilliardTable> tables;

  Venue({
    required this.id,
    required this.vendorId,
    this.vendorName,
    required this.name,
    this.address,
    this.city,
    this.phone,
    this.openingTime,
    this.closingTime,
    required this.status,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.photoUrl,
    this.rating,
    this.reviewsCount = 0,
    this.priceFrom,
    this.isFavorited = false,
    this.tables = const [],
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'] as Map<String, dynamic>?;
    final tablesJson = json['tables'] as List<dynamic>?;

    return Venue(
      id: json['id'] as int,
      vendorId: json['vendor_id'] as int,
      vendorName: vendor?['name'] as String?,
      name: json['name'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      openingTime: json['opening_time'] as String?,
      closingTime: json['closing_time'] as String?,
      status: json['status'] as String? ?? 'active',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      photoUrl: (json['photo_url'] as String?) != null ? resolveMediaUrl(json['photo_url'] as String) : null,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      priceFrom: (json['price_from'] as num?)?.toDouble(),
      isFavorited: json['is_favorited'] as bool? ?? false,
      tables: (tablesJson ?? [])
          .whereType<Map<String, dynamic>>()
          .map(BilliardTable.fromJson)
          .toList(),
    );
  }

  String get hoursLabel {
    if (openingTime == null || closingTime == null) return 'Jam buka tidak diketahui';
    return '$openingTime - $closingTime';
  }
}
