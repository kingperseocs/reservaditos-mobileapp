import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_client.dart';
import '../data/reservation_models.dart';
import '../data/reservation_repository.dart';

/// «Mi reserva»: loads the reservation and keeps it fresh while the
/// administration decides (PENDING) or the payment window is open (APPROVED),
/// so the change made in the web shows up on its own.
final reservationProvider = AsyncNotifierProvider.autoDispose
    .family<ReservationController, Reservation, String>(
      ReservationController.new,
    );

class ReservationController extends AsyncNotifier<Reservation> {
  ReservationController(this.reservationId);

  final String reservationId;

  static const _waiting = {
    ReservationStatus.pendingApproval,
    ReservationStatus.approved,
  };

  @override
  Future<Reservation> build() async {
    final reservation = await ref
        .watch(reservationRepositoryProvider)
        .fetchReservation(reservationId);

    if (_waiting.contains(reservation.status)) {
      final timer = Timer(
        ref.read(appConfigProvider).pollInterval,
        ref.invalidateSelf,
      );
      ref.onDispose(timer.cancel);
    }
    return reservation;
  }

  /// Simulated payment through the link received after approval.
  /// Throws ApiException (e.g. PAYMENT_DEADLINE_PASSED); the state is refreshed either way.
  Future<void> pay() async {
    final token = state.value?.paymentToken;
    if (token == null) return;
    try {
      await ref.read(reservationRepositoryProvider).pay(token);
    } finally {
      ref.invalidateSelf();
      await future;
    }
  }
}

/// The resident's most recent reservation still in progress, for the banner on screen 1.
final activeReservationProvider = FutureProvider.autoDispose<Reservation?>((
  ref,
) async {
  const active = {
    ReservationStatus.pendingApproval,
    ReservationStatus.approved,
    ReservationStatus.confirmed,
  };
  final mine = await ref.watch(reservationRepositoryProvider).fetchMine();
  return mine.where((r) => active.contains(r.status)).firstOrNull;
});
