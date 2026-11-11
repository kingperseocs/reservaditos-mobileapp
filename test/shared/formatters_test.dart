import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reservaditos/shared/formatters/formatters.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  test('money shows soles like the Figma', () {
    expect(money(150), 'S/ 150');
    expect(money(50.5), 'S/ 50.50');
  });

  test('longDate formats the reservation date', () {
    expect(longDate('2026-11-14'), 'Sábado 14/11/2026');
  });

  test('weekdayDayMonth titles the slots section', () {
    expect(weekdayDayMonth(DateTime(2026, 11, 14)), 'sábado 14/11');
  });

  test('monthTitle titles the calendar', () {
    expect(monthTitle(DateTime(2026, 11)), 'Noviembre 2026');
  });

  test('remaining builds the payment countdown', () {
    expect(
      remaining(const Duration(hours: 23, minutes: 15)),
      'Quedan 23 h 15 min',
    );
    expect(remaining(const Duration(minutes: 40)), 'Quedan 40 min');
    expect(remaining(Duration.zero), 'Plazo vencido');
  });

  test('parseIsoDate keeps the calendar day', () {
    expect(parseIsoDate('2026-11-14'), DateTime(2026, 11, 14));
    expect(toIsoDate(DateTime(2026, 11, 4)), '2026-11-04');
  });

  test('times are shown in building time (Lima, UTC−5)', () {
    final deadline = DateTime.utc(2026, 11, 13, 2); // 21:00 on 12/11 in Lima
    expect(buildingTime(deadline), '21:00');
    expect(timeAndDayMonth(deadline), '21:00 del 12/11');
    expect(dateTime(DateTime.utc(2026, 11, 12, 23, 32)), '12/11/2026 · 18:32');
    expect(
      buildingToday(DateTime.utc(2026, 11, 12, 3)),
      DateTime(2026, 11, 11),
    );
  });

  test('shortDayMonth is compact like the admin web', () {
    expect(shortDayMonth('2026-11-14'), 'Sáb 14/11');
  });
}
