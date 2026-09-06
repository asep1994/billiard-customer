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
