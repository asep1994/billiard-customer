import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/venue.dart';
import '../../repositories/venue_repository.dart';
import '../../widgets/eight_ball_icon.dart';
import '../../widgets/state_views.dart';

class VenueDetailScreen extends StatefulWidget {
  const VenueDetailScreen({super.key, required this.venueId});

  final int venueId;

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  final _repository = VenueRepository();
  late Future<Venue> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.show(widget.venueId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Detail Venue')),
      body: FutureBuilder<Venue>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            final message =
                snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Gagal memuat venue.';
            return ErrorView(message: message, onRetry: () => setState(() => _future = _repository.show(widget.venueId)));
          }

          final venue = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primarySoft, AppColors.surface],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(child: EightBallIcon(size: 72)),
                    ),
                    const SizedBox(height: 16),
                    Text(venue.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
                    if (venue.vendorName != null) ...[
                      const SizedBox(height: 4),
                      Text('oleh ${venue.vendorName}', style: const TextStyle(color: AppColors.textFaint, fontSize: 13)),
                    ],
                    const SizedBox(height: 16),
                    _InfoRow(icon: Icons.location_on_outlined, text: venue.address ?? venue.city ?? '-'),
                    const SizedBox(height: 8),
                    _InfoRow(icon: Icons.access_time, text: 'Jam operasional: ${venue.hoursLabel}'),
                    if (venue.phone != null) ...[
                      const SizedBox(height: 8),
                      _InfoRow(icon: Icons.phone_outlined, text: venue.phone!),
                    ],
                    const SizedBox(height: 24),
                    const Text('Meja Tersedia', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                    const SizedBox(height: 12),
                    if (venue.tables.isEmpty)
                      const Text('Belum ada meja terdaftar.', style: TextStyle(color: AppColors.textMuted))
                    else
                      ...venue.tables.map(
                        (table) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(table.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w500)),
                                    Text(table.typeLabel, style: const TextStyle(color: AppColors.textFaint, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text(
                                '${formatCurrency(table.hourlyRate)}/jam',
                                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
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
                      onPressed: () => context.push('/venues/${venue.id}/book'),
                      child: const Text('Booking Sekarang'),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textFaint),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.textMuted, fontSize: 13))),
      ],
    );
  }
}
