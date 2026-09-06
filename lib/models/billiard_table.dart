class BilliardTable {
  final int id;
  final int venueId;
  final String name;
  final String type;
  final double hourlyRate;
  final String status;

  BilliardTable({
    required this.id,
    required this.venueId,
    required this.name,
    required this.type,
    required this.hourlyRate,
    required this.status,
  });

  factory BilliardTable.fromJson(Map<String, dynamic> json) {
    return BilliardTable(
      id: json['id'] as int,
      venueId: json['venue_id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      hourlyRate: double.tryParse(json['hourly_rate'].toString()) ?? 0,
      status: json['status'] as String,
    );
  }

  static const _typeLabels = {
    '8_ball': '8-Ball',
    '9_ball': '9-Ball',
    'snooker': 'Snooker',
    'carom': 'Carom',
  };

  String get typeLabel => _typeLabels[type] ?? type;
}
