import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reservaditos/app.dart';
import 'package:reservaditos/core/http/api_exception.dart';
import 'package:reservaditos/core/clock.dart';
import 'package:reservaditos/features/areas/data/areas_repository.dart';
import 'package:reservaditos/features/booking/data/booking_repository.dart';
import 'package:reservaditos/features/reservation/data/reservation_models.dart';
import 'package:reservaditos/features/reservation/data/reservation_repository.dart';
import 'package:reservaditos/features/standing/data/standing_repository.dart';

import '../helpers/booking_fakes.dart';
import '../helpers/fakes.dart';
import '../helpers/reservation_fakes.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  Future<FakeStandingRepository> pumpApp(
    WidgetTester tester, {
    Standing standing = upToDate,
    FakeAreasRepository? areas,
    List<Reservation> mine = const [],
  }) async {
    final standingRepository = FakeStandingRepository(standing);
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          areasRepositoryProvider.overrideWithValue(
            areas ?? FakeAreasRepository(),
          ),
          standingRepositoryProvider.overrideWithValue(standingRepository),
          bookingRepositoryProvider.overrideWithValue(FakeBookingRepository()),
          reservationRepositoryProvider.overrideWithValue(
            FakeReservationRepository(aReservation(), mine: mine),
          ),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 11, 11, 14)),
        ],
        child: const ReservaditosApp(),
      ),
    );
    await tester.pumpAndSettle();
    return standingRepository;
  }

  testWidgets('screen 1 shows the header and every area like the Figma', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Áreas comunes'), findsOneWidget);
    expect(find.text('Edificio Demo · Ana Pérez · Depto 502'), findsOneWidget);
    expect(
      find.text('Elige un área para ver sus horarios y reservar.'),
      findsOneWidget,
    );
    expect(find.text('Parrilla'), findsOneWidget);
    expect(find.text('Salón de usos múltiples'), findsOneWidget);
    expect(find.text('Piscina'), findsOneWidget);
    expect(find.text('Tarifa S/ 50'), findsNWidgets(3));
    expect(find.text('Garantía S/ 100'), findsNWidgets(3));
    expect(find.text('Disponible hoy'), findsNWidgets(2));
    expect(find.text('Sin horarios hoy'), findsOneWidget);
    expect(find.text('Reservar'), findsNWidgets(3));
  });

  testWidgets('a resident up to date goes to screen 2', (tester) async {
    final standing = await pumpApp(tester);

    await tester.tap(find.text('Reservar').first);
    await tester.pumpAndSettle();

    expect(standing.calls, 1);
    expect(find.text('Elige fecha y horario'), findsOneWidget);
  });

  testWidgets('a resident with an overdue due sees screen 4', (tester) async {
    await pumpApp(tester, standing: overdue);

    await tester.tap(find.text('Reservar').first);
    await tester.pumpAndSettle();

    expect(find.text('Aún no puedes reservar'), findsOneWidget);
    expect(
      find.text(
        'Tienes una cuota pendiente de S/ 350, vencida el 05/11. Ponte al día para reservar.',
      ),
      findsOneWidget,
    );
    expect(find.text('Ver mi cuota'), findsOneWidget);

    await tester.tap(find.text('Ahora no'));
    await tester.pumpAndSettle();
    expect(find.text('Aún no puedes reservar'), findsNothing);
    expect(find.text('Áreas comunes'), findsOneWidget);
  });

  testWidgets('shows the backend message and retries when the areas fail', (
    tester,
  ) async {
    await pumpApp(
      tester,
      areas: FakeAreasRepository(
        error: const ApiException(
          statusCode: 0,
          code: 'NETWORK_ERROR',
          message: 'No se pudo conectar con el servidor. Revisa tu conexión.',
        ),
      ),
    );

    expect(
      find.text('No se pudo conectar con el servidor. Revisa tu conexión.'),
      findsOneWidget,
    );
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('shows «Tu reserva» while a reservation is in progress', (
    tester,
  ) async {
    await pumpApp(tester, mine: [aReservation()]);

    expect(find.text('Tu reserva'), findsOneWidget);
    expect(find.text('Parrilla · Sáb 14/11 · 12:00–15:00'), findsOneWidget);
    expect(find.text('Esperando aprobación'), findsOneWidget);

    await tester.tap(find.text('Tu reserva'));
    await tester.pumpAndSettle();
    expect(find.text('Mi reserva'), findsOneWidget);

    // Unmount so the 10 s refresh timer of «Mi reserva» is cancelled.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 11));
  });
}
