import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/billiard_table.dart';
import '../../models/venue.dart';
import '../../repositories/booking_repository.dart';
import '../../widgets/primary_button.dart';

class PilihWaktuScreen extends StatefulWidget {
  const PilihWaktuScreen({super.key, required this.venue, required this.table, required this.date});

  final Venue venue;
  final BilliardTable table;
  final DateTime date;

  @override
  State<PilihWaktuScreen> createState() => _PilihWaktuScreenState();
}

class _PilihWaktuScreenState extends State<PilihWaktuScreen> {
  final _bookingRepository = BookingRepository();
  final _promoController = TextEditingController();
  final _notesController = TextEditingController();

  String? _startTime;
  String? _endTime;
  bool _isSubmitting = false;
  String? _formError;

  @override
  void dispose() {
    _promoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isToday {
    final now = nowInJakarta();
    return widget.date.year == now.year && widget.date.month == now.month && widget.date.day == now.day;
  }

  List<String> get _startOptions {
    final slots = generateTimeSlots(widget.venue.openingTime, widget.venue.closingTime);
    if (!_isToday) return slots;

    final now = nowInJakarta();
    final nowLabel = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return slots.where((slot) => slot.compareTo(nowLabel) > 0).toList();
  }

  List<String> get _endOptions {
    final slots = generateTimeSlots(widget.venue.openingTime, widget.venue.closingTime);
    if (_startTime == null) return slots;
    return slots.where((slot) => slot.compareTo(_startTime!) > 0).toList();
  }

  DateTime? _combine(String? time) {
    if (time == null) return null;
    final parts = time.split(':').map(int.parse).toList();
    return jakartaWallClockToApiInstant(widget.date, parts[0], parts[1]);
  }

  Future<void> _submit() async {
    final start = _combine(_startTime);
    final end = _combine(_endTime);

    if (start == null || end == null) {
      setState(() => _formError = 'Lengkapi jam mulai dan jam selesai terlebih dahulu.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      final booking = await _bookingRepository.create(
        venueId: widget.venue.id,
        billiardTableId: widget.table.id,
        start: start,
        end: end,
        promoCode: _promoController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (mounted) context.pushReplacement('/booking-success', extra: booking);
    } on ApiException catch (error) {
      setState(() => _formError = error.fieldError('billiard_table_id') ?? error.message);
    } catch (_) {
      setState(() => _formError = 'Gagal membuat booking. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Pilih Waktu')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
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
                      Text(widget.table.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
                      Text(
                        _isToday ? 'Hari ini, ${formatDate(widget.date)}' : formatDate(widget.date),
                        style: const TextStyle(color: AppColors.textFaint, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${formatCurrency(widget.table.hourlyRate)}/jam',
                  style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_formError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.dangerSoft, borderRadius: BorderRadius.circular(12)),
              child: Text(_formError!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: _TimeDropdown(
                  label: 'Jam Mulai',
                  value: _startTime,
                  options: _startOptions,
                  onChanged: (value) => setState(() {
                    _startTime = value;
                    _endTime = null;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeDropdown(
                  label: 'Jam Selesai',
                  value: _endTime,
                  options: _endOptions,
                  enabled: _startTime != null,
                  onChanged: (value) => setState(() => _endTime = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _promoController,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(color: AppColors.text),
            decoration: const InputDecoration(labelText: 'Kode Promo (opsional)', hintText: 'DISKON20'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.text),
            decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Lanjut Booking', isLoading: _isSubmitting, onPressed: _submit),
        ],
      ),
    );
  }
}

class _TimeDropdown extends StatelessWidget {
  const _TimeDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final validValue = options.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: validValue,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          style: const TextStyle(color: AppColors.text),
          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
          hint: const Text('Pilih jam', style: TextStyle(color: AppColors.textFaint)),
          items: options.map((slot) => DropdownMenuItem(value: slot, child: Text(slot))).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
