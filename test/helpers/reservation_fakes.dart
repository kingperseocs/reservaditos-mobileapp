import 'package:reservaditos/core/http/api_exception.dart';
import 'package:reservaditos/features/reservation/data/reservation_models.dart';
import 'package:reservaditos/features/reservation/data/reservation_repository.dart';

/// Ana's grill booking on Saturday 14/11, in any status.
Reservation aReservation({
  ReservationStatus status = ReservationStatus.pendingApproval,
  DateTime? paymentDeadline,
  String? paymentUrl,
  DateTime? paidAt,
  String? code,
  String? rejectionReason,
  num? refundAmount,
}) => Reservation(
  id: 'res-1',
  status: status,
  areaId: 'grill',
  areaName: 'Parrilla',
  areaIcon: 'flame',
  buildingName: 'Edificio Demo',
  date: '2026-11-14',
  slotLabel: '12:00–15:00',
  fee: 50,
  deposit: 100,
  total: 150,
  requestedAt: DateTime.utc(2026, 11, 11, 14),
  paymentDeadline: paymentDeadline,
  paymentUrl: paymentUrl,
  paidAt: paidAt,
  code: code,
  rejectionReason: rejectionReason,
  refundAmount: refundAmount,
);

/// Approved at 21:45 Lima on 11/11: pay before 21:00 on 12/11 (like the Figma).
final approvedReservation = aReservation(
  status: ReservationStatus.approved,
  paymentDeadline: DateTime.utc(2026, 11, 13, 2), // 21:00 on 12/11 in Lima
  paymentUrl: 'http://10.0.2.2:8000/v1/payments/token-123',
);

final confirmedReservation = aReservation(
  status: ReservationStatus.confirmed,
  paidAt: DateTime.utc(2026, 11, 12, 23, 32), // 18:32 on 12/11 in Lima
  code: 'DEMO-4821',
);

class FakeReservationRepository implements ReservationRepository {
  FakeReservationRepository(
    this.current, {
    this.payError,
    this.mine = const [],
  });

  /// What GET /reservations/:id returns; tests change it to simulate the web.
  Reservation current;
  final ApiException? payError;
  final List<Reservation> mine;
  final paidTokens = <String>[];

  @override
  Future<Reservation> fetchReservation(String id) async => current;

  @override
  Future<List<Reservation>> fetchMine() async => mine;

  @override
  Future<void> pay(String paymentToken) async {
    paidTokens.add(paymentToken);
    if (payError != null) throw payError!;
    current = confirmedReservation;
  }
}
