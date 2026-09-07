import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api_exception.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/billiard_table.dart';
import '../../models/venue.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/config_repository.dart';
import '../../widgets/eight_ball_icon.dart';
import '../../widgets/primary_button.dart';

const _paymentMethods = [
  {'value': 'M2', 'label': 'QRIS', 'description': 'Semua aplikasi e-wallet', 'icon': Icons.qr_code},
  {'value': 'BT', 'label': 'Transfer Bank', 'description': 'BCA, Mandiri, BNI, BRI, dll', 'icon': Icons.account_balance},
  {'value': 'VC', 'label': 'Kartu Kredit/Debit', 'description': 'Visa, Mastercard, JCB', 'icon': Icons.credit_card},
];

class RingkasanBookingScreen extends StatefulWidget {
  const RingkasanBookingScreen({
    super.key,
    required this.venue,
    required this.table,
    required this.date,
    required this.startHour,
    required this.duration,
    required this.price,
  });

  final Venue venue;
  final BilliardTable table;

  /// The Jakarta wall-clock date and start hour the customer picked. Kept as
  /// raw components (not a single DateTime) rather than resolved once,
  /// because "the instant to send the API" and "the hour to display" are two
  /// different conversions of the same wall-clock pick - collapsing them
  /// into one DateTime up front is exactly what caused a display bug here
  /// (a UTC-tagged API instant fed straight into a display formatter shows
  /// the UTC hour, not the WIB hour the customer actually chose).
  final DateTime date;
  final int startHour;
  final int duration;
  final double price;

  /// The Jakarta wall-clock instant to show in the UI - a plain local
  /// DateTime, never sent to the API directly.
  DateTime get displayStart => DateTime(date.year, date.month, date.day, startHour);

  DateTime get displayEnd => DateTime(date.year, date.month, date.day, startHour + duration);

  @override
  State<RingkasanBookingScreen> createState() => _RingkasanBookingScreenState();
}

class _RingkasanBookingScreenState extends State<RingkasanBookingScreen> {
  final _bookingRepository = BookingRepository();
  final _configRepository = ConfigRepository();
  final _promoController = TextEditingController();
  late Future<double> _serviceFeeFuture;

  String _paymentMethod = 'M2';
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _serviceFeeFuture = _configRepository.serviceFee();
  }

  Future<void> _payNow(double serviceFee) async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final booking = await _bookingRepository.create(
        venueId: widget.venue.id,
        billiardTableId: widget.table.id,
        start: jakartaWallClockToApiInstant(widget.date, widget.startHour, 0),
        end: jakartaWallClockToApiInstant(widget.date, widget.startHour + widget.duration, 0),
        promoCode: _promoController.text.trim(),
      );

      final paymentUrl = await _bookingRepository.pay(bookingId: booking.id, paymentMethod: _paymentMethod);

      if (paymentUrl != null) {
        await launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication);
      }

      if (mounted) context.pushReplacement('/bookings/${booking.id}');
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(() => _error = 'Gagal membuat booking. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Ringkasan Booking')),
      body: FutureBuilder<double>(
        future: _serviceFeeFuture,
        builder: (context, snapshot) {
          final serviceFee = snapshot.data ?? 0;
          final total = widget.price + serviceFee;
          final isLoadingFee = snapshot.connectionState == ConnectionState.waiting;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 64,
                              height: 64,
                              child: widget.venue.photoUrl != null
                                  ? Image.network(
                                      widget.venue.photoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const _CoverFallback(),
                                    )
                                  : const _CoverFallback(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.venue.name,
                                  style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.venue.address ?? widget.venue.city ?? '-',
                                  style: const TextStyle(color: AppColors.textFaint, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SummaryRow(label: 'Meja', value: widget.table.name),
                    _SummaryRow(label: 'Tanggal', value: formatDate(widget.displayStart)),
                    _SummaryRow(label: 'Waktu', value: formatTimeRange(widget.displayStart, widget.displayEnd)),
                    _SummaryRow(label: 'Durasi', value: '${widget.duration} Jam'),
                    const Divider(height: 28),
                    _SummaryRow(label: 'Harga / Jam', value: formatCurrency(widget.table.hourlyRate)),
                    _SummaryRow(label: 'Subtotal', value: formatCurrency(widget.price)),
                    _SummaryRow(
                      label: 'Biaya Layanan',
                      value: isLoadingFee ? '...' : formatCurrency(serviceFee),
                    ),
                    const Divider(height: 28),
                    _SummaryRow(
                      label: 'Total Pembayaran',
                      value: isLoadingFee ? '...' : formatCurrency(total),
                      emphasize: true,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _promoController,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(color: AppColors.text),
                      decoration: const InputDecoration(labelText: 'Kode Promo (opsional)', hintText: 'DISKON20'),
                    ),
                    const SizedBox(height: 24),
                    const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
                    const SizedBox(height: 12),
                    ..._paymentMethods.map((method) {
                      final selected = method['value'] == _paymentMethod;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => setState(() => _paymentMethod = method['value']! as String),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(method['icon']! as IconData, color: AppColors.primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method['label']! as String,
                                        style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                      Text(
                                        method['description']! as String,
                                        style: const TextStyle(color: AppColors.textFaint, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  selected ? Icons.check_circle : Icons.circle_outlined,
                                  color: selected ? AppColors.primary : AppColors.textFaint,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                    ],
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: PrimaryButton(
                    label: 'Bayar Sekarang',
                    isLoading: _isSubmitting,
                    onPressed: isLoadingFee ? null : () => _payNow(serviceFee),
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

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarySoft,
      alignment: Alignment.center,
      child: const EightBallIcon(size: 28),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: emphasize ? AppColors.primary : AppColors.text,
              fontSize: emphasize ? 17 : 13,
              fontWeight: emphasize ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
