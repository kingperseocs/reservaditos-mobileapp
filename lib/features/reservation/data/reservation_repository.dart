import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_client.dart';
import 'reservation_models.dart';

final reservationRepositoryProvider = Provider<ReservationRepository>(
  (ref) => ReservationRepository(ref.watch(apiClientProvider)),
);

/// HTTP access for screen 3: the reservation and its simulated payment.
class ReservationRepository {
  ReservationRepository(this._api);

  final ApiClient _api;

  Future<Reservation> fetchReservation(String id) async => Reservation.fromJson(
    await _api.get<Map<String, dynamic>>('/reservations/$id'),
  );

  Future<List<Reservation>> fetchMine() async {
    final json = await _api.get<List<dynamic>>('/reservations/me');
    return json.cast<Map<String, dynamic>>().map(Reservation.fromJson).toList();
  }

  /// Simulated payment through the link received after approval.
  Future<void> pay(String paymentToken) =>
      _api.post<Map<String, dynamic>>('/payments/$paymentToken');
}
