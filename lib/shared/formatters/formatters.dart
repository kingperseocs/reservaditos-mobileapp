import 'package:intl/intl.dart';

/// "S/ 150" as in the Figma (no decimals for whole amounts).
String money(num amount) => amount % 1 == 0
    ? 'S/ ${amount.toInt()}'
    : 'S/ ${amount.toStringAsFixed(2)}';

/// Business date "2026-11-14" → DateTime at local midnight (no time zone shift).
DateTime parseIsoDate(String isoDate) {
  final [year, month, day] = isoDate.split('-').map(int.parse).toList();
  return DateTime(year, month, day);
}

/// DateTime → "2026-11-14".
String toIsoDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

/// "2026-11" for the month of [date].
String toIsoMonth(DateTime date) => DateFormat('yyyy-MM').format(date);

String _capitalize(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

/// "Sábado 14/11/2026" (Mi reserva).
String longDate(String isoDate) {
  final date = parseIsoDate(isoDate);
  return '${_capitalize(DateFormat.EEEE('es').format(date))} ${DateFormat('dd/MM/yyyy').format(date)}';
}

/// "Sáb 14/11" (compact, as in the admin web).
String shortDayMonth(String isoDate) {
  final date = parseIsoDate(isoDate);
  final weekday = _capitalize(DateFormat.E('es').format(date))
      .replaceAll('.', '');
  return '$weekday ${DateFormat('dd/MM').format(date)}';
}

/// "sábado 14/11" (Horarios del sábado 14/11).
String weekdayDayMonth(DateTime date) =>
    '${DateFormat.EEEE('es').format(date)} ${DateFormat('dd/MM').format(date)}';

/// "Noviembre 2026" (calendar header).
String monthTitle(DateTime month) =>
    _capitalize(DateFormat.yMMMM('es').format(month)).replaceAll(' de ', ' ');

/// The building is in Lima (UTC−5, no daylight saving time), like the backend.
/// Times are shown in building time whatever the phone's time zone is.
const buildingUtcOffset = Duration(hours: -5);

/// Wall-clock time in the building for an instant (fields read as Lima time).
DateTime toBuildingTime(DateTime instant) =>
    instant.toUtc().add(buildingUtcOffset);

/// Today's date in the building.
DateTime buildingToday(DateTime now) {
  final local = toBuildingTime(now);
  return DateTime(local.year, local.month, local.day);
}

/// "21:00" (payment deadline in the status chip).
String buildingTime(DateTime instant) =>
    DateFormat('HH:mm').format(toBuildingTime(instant));

/// "21:00 del 12/11" (payment deadline).
String timeAndDayMonth(DateTime instant) {
  final local = toBuildingTime(instant);
  return '${DateFormat('HH:mm').format(local)} del ${DateFormat('dd/MM').format(local)}';
}

/// "12/11/2026 · 18:32" (receipt).
String dateTime(DateTime instant) =>
    DateFormat("dd/MM/yyyy '·' HH:mm").format(toBuildingTime(instant));

/// "Quedan 23 h 15 min" for the payment countdown.
String remaining(Duration left) {
  if (left.isNegative || left == Duration.zero) return 'Plazo vencido';
  final hours = left.inHours;
  final minutes = left.inMinutes.remainder(60);
  if (hours == 0) return 'Quedan $minutes min';
  return 'Quedan $hours h $minutes min';
}
