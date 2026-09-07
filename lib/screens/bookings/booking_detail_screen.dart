import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api_exception.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/booking.dart';
import '../../repositories/booking_repository.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_badge.dart';

const _paymentMethods = [
  {'value': 'VC', 'label': 'Kartu Kredit'},
  {'value': 'BT', 'label': 'VA Permata'},
  {'value': 'M2', 'label': 'QRIS'},
  {'value': 'OV', 'label': 'OVO'},
  {'value': 'SP', 'label': 'ShopeePay'},
];

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final int bookingId;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final _repository = BookingRepository();
  late Future<Booking> _future;

  String _paymentMethod = 'VC';
  bool _isPaying = false;
  String? _payError;

  @override
  void initState() {
    super.initState();
    _future = _repository.show(widget.bookingId);
  }

  Future<void> _pay() async {
    setState(() {
      _isPaying = true;
      _payError = null;
    });

    try {
      final url = await _repository.pay(bookingId: widget.bookingId, paymentMethod: _paymentMethod);
      if (url == null) {
        setState(() => _payError = 'Gagal membuka halaman pembayaran.');
        return;
      }

      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        setState(() => _payError = 'Tidak bisa membuka halaman pembayaran di perangkat ini.');
      }
    } on ApiException catch (error) {
      setState(() => _payError = error.message);
    } catch (_) {
      setState(() => _payError = 'Gagal memproses pembayaran. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Detail Booking')),
      body: FutureBuilder<Booking>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            final message =
                snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Gagal memuat booking.';
            return ErrorView(
              message: message,
              onRetry: () => setState(() {
                _future = _repository.show(widget.bookingId);
              }),
            );
          }

          final booking = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BK-${booking.id.toString().padLeft(4, '0')}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                  ),
                  StatusBadge(label: booking.statusLabel, status: booking.status),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _Row(label: 'Venue', value: booking.venueName ?? '-'),
                    _Row(label: 'Meja', value: booking.tableName ?? '-'),
                    _Row(label: 'Tanggal', value: formatDate(booking.startTime)),
                    _Row(label: 'Waktu', value: formatTimeRange(booking.startTime, booking.endTime)),
                    _Row(label: 'Durasi', value: formatDuration(booking.startTime, booking.endTime)),
                    if (booking.notes != null && booking.notes!.isNotEmpty)
                      _Row(label: 'Catatan', value: booking.notes!),
                    const Divider(height: 24),
                    _Row(label: 'Harga', value: formatCurrency(booking.totalPrice)),
                    if (booking.discountAmount > 0)
                      _Row(
                        label: 'Diskon${booking.promoCode != null ? ' (${booking.promoCode})' : ''}',
                        value: '-${formatCurrency(booking.discountAmount)}',
                        valueColor: AppColors.primary,
                      ),
                    _Row(label: 'Total Bayar', value: formatCurrency(booking.payableAmount), emphasize: true),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [StatusBadge(label: booking.paymentStatusLabel, status: booking.paymentStatus)],
                    ),
                  ],
                ),
              ),
              if (booking.needsPayment) ...[
                const SizedBox(height: 24),
                const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _paymentMethods.map((method) {
                    final selected = method['value'] == _paymentMethod;
                    return ChoiceChip(
                      label: Text(method['label']!),
                      selected: selected,
                      onSelected: (_) => setState(() => _paymentMethod = method['value']!),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primarySoft,
                      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                      labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.textMuted, fontSize: 12),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                if (_payError != null) ...[
                  Text(_payError!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                  const SizedBox(height: 12),
                ],
                PrimaryButton(label: 'Bayar Sekarang', isLoading: _isPaying, onPressed: _pay),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.emphasize = false, this.valueColor});

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? AppColors.text,
                fontSize: emphasize ? 16 : 13,
                fontWeight: emphasize ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
