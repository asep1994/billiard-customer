/// A billiard venue found near the customer via Google Places that hasn't
/// signed up as a Unity Billiard partner yet - purely informational, feeds
/// the "Ajak Gabung" lead-gen flow (see [NearbyPlaceRepository]).
class NearbyPlace {
  final String id;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? rating;
  final int? ratingCount;

  const NearbyPlace({
    required this.id,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.rating,
    this.ratingCount,
  });

  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    return NearbyPlace(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: json['rating_count'] as int?,
    );
  }
}
