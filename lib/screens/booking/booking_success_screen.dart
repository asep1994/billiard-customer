import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/booking.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                height: 96,
                width: 96,
                decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: AppColors.primary, size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                'Booking Berhasil!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
              ),
              const SizedBox(height: 8),
              const Text(
                'Terima kasih, booking kamu berhasil dibuat.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _Row(label: 'Booking ID', value: 'BK-${booking.id.toString().padLeft(4, '0')}'),
                    _Row(label: 'Venue', value: booking.venueName ?? '-'),
                    _Row(label: 'Meja', value: booking.tableName ?? '-'),
                    _Row(label: 'Tanggal', value: formatDate(booking.startTime)),
                    _Row(label: 'Waktu', value: formatTimeRange(booking.startTime, booking.endTime)),
                    const Divider(height: 24),
                    _Row(label: 'Total Bayar', value: formatCurrency(booking.payableAmount), emphasize: true),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pushReplacement('/bookings/${booking.id}'),
                  child: const Text('Bayar Sekarang'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: AppColors.text,
              fontSize: emphasize ? 16 : 13,
              fontWeight: emphasize ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
