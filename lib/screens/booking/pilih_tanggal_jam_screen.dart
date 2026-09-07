import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/billiard_table.dart';
import '../../models/venue.dart';

class PilihTanggalJamScreen extends StatefulWidget {
  const PilihTanggalJamScreen({super.key, required this.venue, required this.table, required this.date});

  final Venue venue;
  final BilliardTable table;

  /// The date already chosen on the Pilih Meja screen - shown as the
  /// starting point here, but still adjustable via the inline calendar.
  final DateTime date;

  @override
  State<PilihTanggalJamScreen> createState() => _PilihTanggalJamScreenState();
}

class _PilihTanggalJamScreenState extends State<PilihTanggalJamScreen> {
  late DateTime _date;
  int? _startHour;
  int _duration = 1;

  @override
  void initState() {
    super.initState();
    _date = widget.date;
  }

  bool get _isToday {
    final now = nowInJakarta();
    return _date.year == now.year && _date.month == now.month && _date.day == now.day;
  }

  List<int> get _hourOptions {
    final opening = int.parse((widget.venue.openingTime ?? '10:00').split(':')[0]);
    final closing = int.parse((widget.venue.closingTime ?? '23:00').split(':')[0]);
    final hours = [for (var h = opening; h < closing; h++) h];

    if (!_isToday) return hours;

    final nowHour = nowInJakarta().hour;
    return hours.where((h) => h > nowHour).toList();
  }

  int get _closingHour => int.parse((widget.venue.closingTime ?? '23:00').split(':')[0]);

  bool _durationFits(int hours) => _startHour != null && _startHour! + hours <= _closingHour;

  void _onDateChanged(DateTime picked) {
    setState(() {
      _date = picked;
      _startHour = null;
    });
  }

  void _continue() {
    if (_startHour == null) return;

    context.push('/venues/${widget.venue.id}/book/summary', extra: {
      'venue': widget.venue,
      'table': widget.table,
      'date': _date,
      'startHour': _startHour,
      'duration': _duration,
      'price': widget.table.priceForHours(_duration),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Pilih Tanggal & Jam')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surface),
                    ),
                    child: CalendarDatePicker(
                      initialDate: _date,
                      firstDate: nowInJakarta().subtract(const Duration(days: 1)),
                      lastDate: nowInJakarta().add(const Duration(days: 60)),
                      onDateChanged: _onDateChanged,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Pilih Jam', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                const SizedBox(height: 12),
                if (_hourOptions.isEmpty)
                  const Text('Tidak ada jam tersedia untuk tanggal ini.', style: TextStyle(color: AppColors.textMuted))
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _hourOptions.map((hour) {
                      final label = '${hour.toString().padLeft(2, '0')}:00';
                      final selected = hour == _startHour;
                      return _SelectableChip(
                        label: label,
                        selected: selected,
                        onTap: () => setState(() => _startHour = hour),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.add_circle_outline, size: 16, color: AppColors.textFaint),
                    const SizedBox(width: 8),
                    const Text('Durasi Bermain', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [1, 2, 3].map((hours) {
                    final fits = _durationFits(hours);
                    final selected = hours == _duration;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: hours == 3 ? 0 : 10),
                        child: _DurationCard(
                          hours: hours,
                          price: widget.table.priceForHours(hours),
                          selected: selected,
                          enabled: fits,
                          onTap: fits ? () => setState(() => _duration = hours) : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startHour != null ? _continue : null,
                  child: const Text('Lanjut ke Pembayaran'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : AppColors.text,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _DurationCard extends StatelessWidget {
  const _DurationCard({
    required this.hours,
    required this.price,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final int hours;
  final double price;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Column(
            children: [
              Text(
                '$hours Jam',
                style: TextStyle(
                  color: selected ? Colors.black : AppColors.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatCurrency(price),
                style: TextStyle(
                  color: selected ? Colors.black87 : AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
