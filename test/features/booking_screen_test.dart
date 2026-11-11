import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reservaditos/app.dart';
import 'package:reservaditos/core/clock.dart';
import 'package:reservaditos/core/http/api_exception.dart';
import 'package:reservaditos/core/router/app_router.dart';
import 'package:reservaditos/features/areas/data/areas_repository.dart';
import 'package:reservaditos/features/booking/data/booking_repository.dart';

import '../helpers/booking_fakes.dart';
import '../helpers/fakes.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  /// Wednesday 11/11/2026, like the Figma.
  DateTime today() => DateTime.utc(2026, 11, 11, 14); // 09:00 in Lima

  Future<ProviderContainer> openBooking(
    WidgetTester tester,
    FakeBookingRepository booking,
  ) async {
    await tester.binding.setSurfaceSize(const Size(420, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(today),
        areasRepositoryProvider.overrideWithValue(FakeAreasRepository()),
        bookingRepositoryProvider.overrideWithValue(booking),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ReservaditosApp(),
      ),
    );
    container.read(routerProvider).go('/areas/grill/booking');
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('shows the area, the month and the legend like the Figma', (
    tester,
  ) async {
    await openBooking(tester, FakeBookingRepository());

    expect(find.text('Parrilla'), findsOneWidget);
    expect(find.text('Elige fecha y horario'), findsOneWidget);
    expect(find.text('Noviembre 2026'), findsOneWidget);
    expect(find.text('Con horarios'), findsOneWidget);
    expect(find.text('Sin horarios'), findsOneWidget);
    expect(find.text('Elegido'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('S/ 150'), findsOneWidget);
  });

  testWidgets('opens on the first day with slots and lists its slots', (
    tester,
  ) async {
    await openBooking(tester, FakeBookingRepository());

    expect(find.text('Horarios del miércoles 11/11'), findsOneWidget);
    expect(find.text('Libre'), findsNWidgets(2));
    expect(find.text('Ocupado'), findsOneWidget);
  });

  testWidgets('keeps «Pedir reserva» disabled until a free slot is chosen', (
    tester,
  ) async {
    await openBooking(tester, FakeBookingRepository());
    FilledButton requestButton() => tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Pedir reserva'),
    );

    expect(requestButton().onPressed, isNull);

    await tester.tap(find.text('15:00–18:00')); // taken
    await tester.pump();
    expect(requestButton().onPressed, isNull);

    await tester.tap(find.text('12:00–15:00'));
    await tester.pump();
    expect(requestButton().onPressed, isNotNull);
    expect(find.text('Elegido'), findsNWidgets(2)); // legend + selected slot
  });

  testWidgets('requests the chosen day and slot, then opens «Mi reserva»', (
    tester,
  ) async {
    final booking = FakeBookingRepository();
    await openBooking(tester, booking);

    await tester.tap(find.text('14'));
    await tester.pumpAndSettle();
    expect(find.text('Horarios del sábado 14/11'), findsOneWidget);

    await tester.tap(find.text('12:00–15:00'));
    await tester.pump();
    await tester.tap(find.text('Pedir reserva'));
    await tester.pumpAndSettle();

    expect(booking.requests.single, (
      areaId: 'grill',
      date: '2026-11-14',
      start: '12:00',
    ));
    expect(find.text('Mi reserva'), findsOneWidget);
  });

  testWidgets('days without slots and past days cannot be chosen', (
    tester,
  ) async {
    await openBooking(tester, FakeBookingRepository());

    await tester.tap(find.text('13')); // no slots
    await tester.pump();
    await tester.tap(find.text('9')); // past
    await tester.pump();

    expect(find.text('Horarios del miércoles 11/11'), findsOneWidget);
  });

  testWidgets('shows the backend message when the slot was taken meanwhile', (
    tester,
  ) async {
    await openBooking(
      tester,
      FakeBookingRepository(
        requestError: const ApiException(
          statusCode: 409,
          code: 'SLOT_TAKEN',
          message: 'Ese horario ya está reservado.',
        ),
      ),
    );

    await tester.tap(find.text('12:00–15:00'));
    await tester.pump();
    await tester.tap(find.text('Pedir reserva'));
    await tester.pumpAndSettle();

    expect(find.text('Ese horario ya está reservado.'), findsOneWidget);
    expect(find.text('Elige fecha y horario'), findsOneWidget);
  });
}
