import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/billiard_table.dart';
import '../../models/venue.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/venue_repository.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/state_views.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.venueId});

  final int venueId;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _venueRepository = VenueRepository();
  final _bookingRepository = BookingRepository();
  final _promoController = TextEditingController();
  final _notesController = TextEditingController();

  late Future<Venue> _venueFuture;
  Venue? _venue;

  DateTime _date = DateTime.now();
  String? _startTime;
  String? _endTime;

  Future<List<BilliardTable>>? _tablesFuture;
  int? _selectedTableId;

  bool _isSubmitting = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _venueFuture = _venueRepository.show(widget.venueId).then((venue) {
      _venue = venue;
      return venue;
    });
  }

  @override
  void dispose() {
    _promoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<String> get _startOptions {
    final slots = generateTimeSlots(_venue?.openingTime, _venue?.closingTime);
    if (!_isToday(_date)) return slots;

    final now = nowInJakarta();
    final nowLabel = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return slots.where((slot) => slot.compareTo(nowLabel) > 0).toList();
  }

  List<String> get _endOptions {
    final slots = generateTimeSlots(_venue?.openingTime, _venue?.closingTime);
    if (_startTime == null) return slots;
    return slots.where((slot) => slot.compareTo(_startTime!) > 0).toList();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  DateTime? get _startDateTime => _combine(_date, _startTime);
  DateTime? get _endDateTime => _combine(_date, _endTime);

  DateTime? _combine(DateTime date, String? time) {
    if (time == null) return null;
    final parts = time.split(':').map(int.parse).toList();
    return jakartaWallClockToApiInstant(date, parts[0], parts[1]);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _date = picked;
        _startTime = null;
        _endTime = null;
        _tablesFuture = null;
        _selectedTableId = null;
      });
    }
  }

  void _checkAvailability() {
    final start = _startDateTime;
    final end = _endDateTime;
    if (start == null || end == null) return;

    setState(() {
      _selectedTableId = null;
      _tablesFuture = _venueRepository.availableTables(venueId: widget.venueId, start: start, end: end);
    });
  }

  Future<void> _submit() async {
    final start = _startDateTime;
    final end = _endDateTime;

    if (start == null || end == null || _selectedTableId == null) {
      setState(() => _formError = 'Lengkapi tanggal, jam, dan meja terlebih dahulu.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _formError = null;
    });

    try {
      final booking = await _bookingRepository.create(
        venueId: widget.venueId,
        billiardTableId: _selectedTableId!,
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
      appBar: AppBar(title: const Text('Pilih Jadwal & Meja')),
      body: FutureBuilder<Venue>(
        future: _venueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return const ErrorView(message: 'Gagal memuat venue.');
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_formError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_formError!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ),
                const SizedBox(height: 16),
              ],
              const Text('Tanggal', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const SizedBox(height: 6),
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
                      Text(formatDate(_date), style: const TextStyle(color: AppColors.text)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TimeDropdown(
                      label: 'Jam Mulai',
                      value: _startTime,
                      options: _startOptions,
                      onChanged: (value) {
                        setState(() {
                          _startTime = value;
                          _endTime = null;
                          _tablesFuture = null;
                          _selectedTableId = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeDropdown(
                      label: 'Jam Selesai',
                      value: _endTime,
                      options: _endOptions,
                      enabled: _startTime != null,
                      onChanged: (value) {
                        setState(() {
                          _endTime = value;
                          _tablesFuture = null;
                          _selectedTableId = null;
                        });
                        _checkAvailability();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Pilih Meja', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text)),
              const SizedBox(height: 12),
              if (_tablesFuture == null)
                const Text('Pilih tanggal dan jam terlebih dahulu.', style: TextStyle(color: AppColors.textMuted))
              else
                FutureBuilder<List<BilliardTable>>(
                  future: _tablesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Text('Gagal memuat meja kosong.', style: TextStyle(color: AppColors.danger));
                    }

                    final tables = snapshot.data ?? [];
                    if (tables.isEmpty) {
                      return const Text('Tidak ada meja kosong pada rentang waktu ini.',
                          style: TextStyle(color: AppColors.textMuted));
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: tables.length,
                      itemBuilder: (context, index) {
                        final table = tables[index];
                        final selected = table.id == _selectedTableId;
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() => _selectedTableId = table.id),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primarySoft : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(table.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
                                Text(table.typeLabel, style: const TextStyle(color: AppColors.textFaint, fontSize: 11)),
                                const Spacer(),
                                Text(
                                  '${formatCurrency(table.hourlyRate)}/jam',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
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
          );
        },
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
