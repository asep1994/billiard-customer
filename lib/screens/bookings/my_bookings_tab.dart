import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/booking.dart';
import '../../repositories/booking_repository.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_badge.dart';

class MyBookingsTab extends StatefulWidget {
  const MyBookingsTab({super.key});

  @override
  State<MyBookingsTab> createState() => _MyBookingsTabState();
}

class _MyBookingsTabState extends State<MyBookingsTab> {
  final _repository = BookingRepository();
  late Future<List<Booking>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.myBookings();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _repository.myBookings();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text('Booking Saya', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text)),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<Booking>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingView();
                  }
                  if (snapshot.hasError) {
                    final message = snapshot.error is ApiException
                        ? (snapshot.error as ApiException).message
                        : 'Gagal memuat booking.';
                    return ListView(children: [ErrorView(message: message, onRetry: _refresh)]);
                  }

                  final bookings = snapshot.data ?? [];
                  if (bookings.isEmpty) {
                    return ListView(
                      children: const [
                        EmptyView(message: 'Belum ada booking. Yuk cari venue dulu!', icon: Icons.event_busy),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: bookings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return _BookingCard(
                        booking: booking,
                        onTap: () => context.push('/bookings/${booking.id}'),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.onTap});

  final Booking booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.venueName ?? 'Venue',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(label: booking.statusLabel, status: booking.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${booking.tableName ?? 'Meja'} · ${formatDate(booking.startTime)}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            Text(
              formatTimeRange(booking.startTime, booking.endTime),
              style: const TextStyle(color: AppColors.textFaint, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatCurrency(booking.payableAmount),
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.text),
                ),
                StatusBadge(label: booking.paymentStatusLabel, status: booking.paymentStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
