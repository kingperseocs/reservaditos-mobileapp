import 'package:flutter_test/flutter_test.dart';
import 'package:reservaditos/features/reservation/data/reservation_models.dart';

void main() {
  final approvedJson = <String, dynamic>{
    'id': 'res-1',
    'status': 'APPROVED',
    'area': {'id': 'grill', 'name': 'Parrilla', 'icon': 'flame'},
    'buildingName': 'Edificio Demo',
    'date': '2026-11-14',
    'slot': {'start': '12:00', 'end': '15:00', 'label': '12:00–15:00'},
    'fee': 50,
    'deposit': 100,
    'total': 150,
    'requestedAt': '2026-11-11T14:00:00.000Z',
    'paymentDeadline': '2026-11-12T14:00:00.000Z',
    'paymentUrl': 'http://localhost:8000/v1/payments/9f2c-token',
    'paidAt': null,
    'code': null,
    'rejectionReason': null,
    'refundAmount': null,
  };

  test('parses the backend reservation and its payment token', () {
    final reservation = Reservation.fromJson(approvedJson);

    expect(reservation.status, ReservationStatus.approved);
    expect(reservation.areaName, 'Parrilla');
    expect(reservation.slotLabel, '12:00–15:00');
    expect(reservation.total, 150);
    expect(reservation.paymentDeadline, DateTime.utc(2026, 11, 12, 14));
    expect(reservation.paymentToken, '9f2c-token');
  });

  test('maps every backend status', () {
    const statuses = {
      'PENDING_APPROVAL': ReservationStatus.pendingApproval,
      'CONFIRMED': ReservationStatus.confirmed,
      'REJECTED': ReservationStatus.rejected,
      'EXPIRED': ReservationStatus.expired,
      'REFUNDED': ReservationStatus.refunded,
    };
    statuses.forEach((value, status) {
      expect(
        Reservation.fromJson({...approvedJson, 'status': value}).status,
        status,
      );
    });
  });
}
