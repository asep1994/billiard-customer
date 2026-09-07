import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/billiard_table.dart';
import '../../models/venue.dart';
import '../../repositories/venue_repository.dart';
import '../../widgets/state_views.dart';

enum _TableStatus { available, occupied }

class PilihMejaScreen extends StatefulWidget {
  const PilihMejaScreen({super.key, required this.venueId});

  final int venueId;

  @override
  State<PilihMejaScreen> createState() => _PilihMejaScreenState();
}

class _PilihMejaScreenState extends State<PilihMejaScreen> {
  final _repository = VenueRepository();

  late Future<Venue> _venueFuture;
  Venue? _venue;
  DateTime _date = nowInJakarta();

  Future<Set<int>>? _availableIdsFuture;
  int? _selectedTableId;

  @override
  void initState() {
    super.initState();
    _venueFuture = _repository.show(widget.venueId).then((venue) {
      _venue = venue;
      _refreshAvailability(venue);
      return venue;
    });
  }

  void _refreshAvailability(Venue venue) {
    final opening = venue.openingTime ?? '00:00';
    final closing = venue.closingTime ?? '23:59';
    final openingParts = opening.split(':').map(int.parse).toList();
    final closingParts = closing.split(':').map(int.parse).toList();

    final start = jakartaWallClockToApiInstant(_date, openingParts[0], openingParts[1]);
    final end = jakartaWallClockToApiInstant(_date, closingParts[0], closingParts[1]);

    setState(() {
      _selectedTableId = null;
      _availableIdsFuture = _repository
          .availableTables(venueId: widget.venueId, start: start, end: end)
          .then((tables) => tables.map((t) => t.id).toSet());
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: nowInJakarta(),
      lastDate: nowInJakarta().add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.surface),
        ),
        child: child!,
      ),
    );

    if (picked != null && _venue != null) {
      setState(() => _date = picked);
      _refreshAvailability(_venue!);
    }
  }

  bool get _isToday {
    final now = nowInJakarta();
    return _date.year == now.year && _date.month == now.month && _date.day == now.day;
  }

  void _continue() {
    if (_selectedTableId == null || _venue == null) return;

    final table = _venue!.tables.firstWhere((t) => t.id == _selectedTableId);
    context.push('/venues/${widget.venueId}/book/schedule', extra: {
      'venue': _venue,
      'table': table,
      'date': _date,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Pilih Meja')),
      body: FutureBuilder<Venue>(
        future: _venueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const ErrorView(message: 'Gagal memuat venue.');
          }

          final venue = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.textFaint),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _isToday ? 'Hari ini, ${formatDate(_date)}' : formatDate(_date),
                                style: const TextStyle(color: AppColors.text),
                              ),
                            ),
                            const Text('Ubah', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        _LegendDot(color: AppColors.primary, label: 'Tersedia'),
                        SizedBox(width: 16),
                        _LegendDot(color: AppColors.danger, label: 'Terpakai'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (venue.tables.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text('Belum ada meja terdaftar.', style: TextStyle(color: AppColors.textMuted)),
                      )
                    else
                      FutureBuilder<Set<int>>(
                        future: _availableIdsFuture,
                        builder: (context, availSnapshot) {
                          if (availSnapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (availSnapshot.hasError) {
                            final message = availSnapshot.error is ApiException
                                ? (availSnapshot.error as ApiException).message
                                : 'Gagal memuat status meja.';
                            return Text(message, style: const TextStyle(color: AppColors.danger));
                          }

                          final availableIds = availSnapshot.data ?? {};

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: venue.tables.length,
                            itemBuilder: (context, index) {
                              final table = venue.tables[index];
                              final status = availableIds.contains(table.id) ? _TableStatus.available : _TableStatus.occupied;
                              return _TableTile(
                                table: table,
                                status: status,
                                selected: table.id == _selectedTableId,
                                onTap: status == _TableStatus.available
                                    ? () => setState(() => _selectedTableId = table.id)
                                    : null,
                              );
                            },
                          );
                        },
                      ),
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
                      onPressed: _selectedTableId != null ? _continue : null,
                      child: const Text('Lanjut Pilih Waktu'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }
}

class _TableTile extends StatelessWidget {
  const _TableTile({required this.table, required this.status, required this.selected, required this.onTap});

  final BilliardTable table;
  final _TableStatus status;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = status == _TableStatus.available ? AppColors.primary : AppColors.danger;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.18), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(Icons.grid_view_rounded, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              table.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 12),
            ),
            Text(
              '${formatCurrency(table.hourlyRate)}/jam',
              style: const TextStyle(color: AppColors.textFaint, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
