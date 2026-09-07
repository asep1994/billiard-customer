class BilliardTable {
  final int id;
  final int venueId;
  final String name;
  final String type;
  final double hourlyRate;
  final Map<int, double> durationPrices;
  final String status;

  BilliardTable({
    required this.id,
    required this.venueId,
    required this.name,
    required this.type,
    required this.hourlyRate,
    this.durationPrices = const {},
    required this.status,
  });

  factory BilliardTable.fromJson(Map<String, dynamic> json) {
    // An empty PHP array and an empty PHP map both serialize to JSON `[]`
    // (json_encode can't tell them apart when there's nothing in them), so
    // an unset duration_prices arrives as an empty *list*, not `{}` - only
    // a populated one arrives as the object this cast expects.
    final rawDurationPricesJson = json['duration_prices'];
    final rawDurationPrices = rawDurationPricesJson is Map<String, dynamic> ? rawDurationPricesJson : <String, dynamic>{};

    return BilliardTable(
      id: json['id'] as int,
      venueId: json['venue_id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      hourlyRate: double.tryParse(json['hourly_rate'].toString()) ?? 0,
      durationPrices: rawDurationPrices.map(
        (hours, price) => MapEntry(int.parse(hours), double.tryParse(price.toString()) ?? 0),
      ),
      status: json['status'] as String,
    );
  }

  /// The package price for a whole-hour duration if the vendor set one,
  /// otherwise the linear hourly_rate * hours.
  double priceForHours(int hours) => durationPrices[hours] ?? hourlyRate * hours;

  static const _typeLabels = {
    '8_ball': '8-Ball',
    '9_ball': '9-Ball',
    'snooker': 'Snooker',
    'carom': 'Carom',
  };

  String get typeLabel => _typeLabels[type] ?? type;
}
