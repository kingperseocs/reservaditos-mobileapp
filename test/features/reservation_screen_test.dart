import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:reservaditos/app.dart';
import 'package:reservaditos/core/clock.dart';
import 'package:reservaditos/core/config/app_config.dart';
import 'package:reservaditos/core/http/api_client.dart';
import 'package:reservaditos/core/http/api_exception.dart';
import 'package:reservaditos/core/router/app_router.dart';
import 'package:reservaditos/features/areas/data/areas_repository.dart';
import 'package:reservaditos/features/reservation/data/reservation_models.dart';
import 'package:reservaditos/features/reservation/data/reservation_repository.dart';

import '../helpers/fakes.dart';
import '../helpers/reservation_fakes.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  late ProviderContainer container;

  /// 21:45 on 11/11 in Lima: 23 h 15 min before the 21:00 deadline of 12/11.
  DateTime now() => DateTime.utc(2026, 11, 12, 2, 45);

  Future<void> openReservation(
    WidgetTester tester,
    FakeReservationRepository repository,
  ) async {
    await tester.binding.setSurfaceSize(const Size(420, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(now),
        areasRepositoryProvider.overrideWithValue(FakeAreasRepository()),
        reservationRepositoryProvider.overrideWithValue(repository),
        appConfigProvider.overrideWithValue(
          const AppConfig(
            apiBaseUrl: 'http://test/v1',
            residentId: 'ana-perez',
            pollInterval: Duration(seconds: 10),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ReservaditosApp(),
      ),
    );
    container.read(routerProvider).go('/reservations/res-1');
    await tester.pumpAndSettle();
  }

  /// Unmounts the screen so the 10 s refresh timer is cancelled before the test ends.
  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump();
  }

  void expectSummary() {
    expect(find.text('Mi reserva'), findsOneWidget);
    expect(find.text('Parrilla'), findsOneWidget);
    expect(find.text('Edificio Demo'), findsOneWidget);
    expect(find.text('Sábado 14/11/2026'), findsOneWidget);
    expect(find.text('12:00–15:00'), findsOneWidget);
    expect(find.text('Monto total'), findsOneWidget);
    expect(find.text('S/ 150'), findsOneWidget);
  }

  testWidgets('3a · waiting for approval', (tester) async {
    await openReservation(tester, FakeReservationRepository(aReservation()));

    expectSummary();
    expect(find.text('Esperando aprobación'), findsOneWidget);
    expect(find.text('La administración revisa tu pedido'), findsOneWidget);
    expect(find.text('Te avisaremos cuando responda.'), findsOneWidget);
    expect(find.textContaining('Pagar'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('3b · approved: deadline, countdown and pay button', (
    tester,
  ) async {
    await openReservation(
      tester,
      FakeReservationRepository(approvedReservation),
    );

    expectSummary();
    expect(find.text('Aprobada · paga antes de las 21:00'), findsOneWidget);
    expect(find.text('Paga antes de las 21:00 del 12/11'), findsOneWidget);
    expect(
      find.text('Si no pagas a tiempo, el horario se libera.'),
      findsOneWidget,
    );
    expect(find.text('Tiempo para pagar'), findsOneWidget);
    expect(find.text('Quedan 23 h 15 min'), findsOneWidget);
    expect(find.text('Pagar S/ 150'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('3b → 3c · paying confirms and shows the receipt', (
    tester,
  ) async {
    final repository = FakeReservationRepository(approvedReservation);
    await openReservation(tester, repository);

    await tester.tap(find.text('Pagar S/ 150'));
    await tester.pumpAndSettle();

    expect(repository.paidTokens, ['token-123']);
    expect(find.text('Confirmada'), findsOneWidget);
    expect(find.text('Reserva confirmada'), findsOneWidget);
    expect(find.text('Tu pago de S/ 150 se registró.'), findsOneWidget);
    expect(find.text('Comprobante'), findsOneWidget);
    expect(find.text('DEMO-4821'), findsOneWidget);
    expect(find.text('12/11/2026 · 18:32'), findsOneWidget);
    expect(find.textContaining('Pagar'), findsNothing);
    await closeApp(tester);
  });

  testWidgets('3d · expired', (tester) async {
    await openReservation(
      tester,
      FakeReservationRepository(
        aReservation(status: ReservationStatus.expired),
      ),
    );

    expect(find.text('Vencida'), findsOneWidget);
    expect(find.text('No se pagó a tiempo'), findsOneWidget);
    expect(find.text('El horario se liberó.'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('3e · rejected with the administration reason', (tester) async {
    await openReservation(
      tester,
      FakeReservationRepository(
        aReservation(
          status: ReservationStatus.rejected,
          rejectionReason: 'El área está en mantenimiento ese día.',
        ),
      ),
    );

    expect(find.text('Rechazada'), findsOneWidget);
    expect(find.text('Motivo del rechazo'), findsOneWidget);
    expect(find.text('El área está en mantenimiento ese día.'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('refunded when the area was suspended', (tester) async {
    await openReservation(
      tester,
      FakeReservationRepository(
        aReservation(
          status: ReservationStatus.refunded,
          refundAmount: 150,
          rejectionReason: 'Área suspendida: Mantenimiento programado',
        ),
      ),
    );

    expect(find.text('Devuelta'), findsOneWidget);
    expect(find.text('Te devolvimos S/ 150'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('refreshes on its own and shows the approval made in the web', (
    tester,
  ) async {
    final repository = FakeReservationRepository(aReservation());
    await openReservation(tester, repository);
    expect(find.text('Esperando aprobación'), findsOneWidget);

    repository.current = approvedReservation; // the administration approves
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();

    expect(find.text('Aprobada · paga antes de las 21:00'), findsOneWidget);
    expect(find.text('Pagar S/ 150'), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('shows the backend message when the deadline already passed', (
    tester,
  ) async {
    final repository = FakeReservationRepository(
      approvedReservation,
      payError: const ApiException(
        statusCode: 409,
        code: 'PAYMENT_DEADLINE_PASSED',
        message: 'El plazo de pago venció y el horario se liberó.',
      ),
    );
    await openReservation(tester, repository);

    await tester.tap(find.text('Pagar S/ 150'));
    await tester.pumpAndSettle();

    expect(
      find.text('El plazo de pago venció y el horario se liberó.'),
      findsOneWidget,
    );
    await closeApp(tester);
  });
}
