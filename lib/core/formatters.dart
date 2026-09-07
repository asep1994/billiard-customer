import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
final _dateFormat = DateFormat('d MMMM yyyy', 'id_ID');
final _shortDateFormat = DateFormat('d MMM', 'id_ID');
final _timeFormat = DateFormat('HH:mm');

String formatCurrency(num amount) => _currencyFormat.format(amount);

String formatDate(DateTime date) => _dateFormat.format(date);

String formatShortDate(DateTime date) => _shortDateFormat.format(date);

String formatTime(DateTime date) => _timeFormat.format(date);

String formatTimeRange(DateTime start, DateTime end) => '${formatTime(start)} - ${formatTime(end)}';

String formatDuration(DateTime start, DateTime end) {
  final minutes = end.difference(start).inMinutes;
  final hours = minutes ~/ 60;
  final remaining = minutes % 60;

  if (hours == 0) return '$remaining menit';
  if (remaining == 0) return '$hours jam';
  return '$hours jam $remaining menit';
}

/// The whole platform (backend, admin dashboard, every venue) runs on a
/// single fixed Asia/Jakarta (WIB, UTC+7, no DST) clock rather than each
/// user's own device timezone - a booking is "14:00 at this venue", not
/// "14:00 wherever the customer's phone happens to think it is". Every
/// DateTime this app hands to a screen or sends to the API should be one of
/// these two conversions, never a bare `DateTime.now()`/`.toLocal()`.
const jakartaOffset = Duration(hours: 7);

/// The current wall-clock moment in Jakarta, regardless of the device's own
/// timezone setting. Use this instead of `DateTime.now()` for anything
/// booking-related (e.g. filtering out time slots that have already passed).
DateTime nowInJakarta() => DateTime.now().toUtc().add(jakartaOffset);

/// Converts an API timestamp (UTC, e.g. "2026-09-07T07:00:00.000000Z") into
/// a DateTime whose year/month/day/hour/minute fields are already the
/// correct Jakarta wall-clock values - safe to format directly without
/// calling `.toLocal()` (which would use the device's timezone instead).
DateTime parseApiTimestamp(String iso) => DateTime.parse(iso).toUtc().add(jakartaOffset);

/// The inverse: given a Jakarta wall-clock date and "HH:mm" time the
/// customer picked, produces the DateTime to send to the API. Because this
/// is UTC-flagged internally, `.toIso8601String()` appends the correct "Z"
/// and the backend receives the exact instant intended, independent of
/// whatever timezone the customer's device happens to be set to.
DateTime jakartaWallClockToApiInstant(DateTime date, int hour, int minute) {
  return DateTime.utc(date.year, date.month, date.day, hour - 7, minute);
}

/// A short "X menit/jam/hari lalu" label for recent timestamps, falling back
/// to [formatDate] once it's more than a week old. `dateTime` must already be
/// in Jakarta wall-clock form (e.g. via [parseApiTimestamp]).
String formatRelativeTime(DateTime dateTime) {
  final diff = nowInJakarta().difference(dateTime);

  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  if (diff.inDays < 7) return '${diff.inDays} hari lalu';
  return formatDate(dateTime);
}

/// "HH:MM" slots between [start] and [end] (inclusive) at [stepMinutes],
/// for picking a booking time from a list instead of typing one. Mirrors
/// billiard-admin's generateTimeSlots so both apps behave the same way.
/// Falls back to a full day when the venue has no set operating hours.
List<String> generateTimeSlots(String? start, String? end, {int stepMinutes = 30}) {
  final startParts = (start ?? '00:00').split(':').map(int.parse).toList();
  final endParts = (end ?? '23:30').split(':').map(int.parse).toList();

  final startTotal = startParts[0] * 60 + startParts[1];
  final endTotal = endParts[0] * 60 + endParts[1];

  final slots = <String>[];
  for (var minutes = startTotal; minutes <= endTotal; minutes += stepMinutes) {
    final hour = (minutes ~/ 60).toString().padLeft(2, '0');
    final minute = (minutes % 60).toString().padLeft(2, '0');
    slots.add('$hour:$minute');
  }
  return slots;
}
