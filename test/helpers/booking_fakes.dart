import 'package:reservaditos/core/http/api_exception.dart';
import 'package:reservaditos/features/booking/data/booking_models.dart';
import 'package:reservaditos/features/booking/data/booking_repository.dart';
import 'package:reservaditos/features/reservation/data/reservation_models.dart';

/// November 2026 like the Figma: 13, 20 and 28 without slots; before 11 is past.
class FakeBookingRepository implements BookingRepository {
  FakeBookingRepository({this.requestError});

  final ApiException? requestError;
  final requests = <({String areaId, String date, String start})>[];

  static const _full = {13, 20, 28};

  @override
  Future<List<DayAvailability>> fetchMonth(String areaId, String month) async =>
      [
        for (var day = 1; day <= 30; day++)
          DayAvailability(
            date: '$month-${day.toString().padLeft(2, '0')}',
            available: day >= 11 && !_full.contains(day),
          ),
      ];

  @override
  Future<List<SlotOption>> fetchSlots(String areaId, String date) async =>
      const [
        SlotOption(
          start: '12:00',
          end: '15:00',
          label: '12:00–15:00',
          status: SlotStatus.free,
        ),
        SlotOption(
          start: '15:00',
          end: '18:00',
          label: '15:00–18:00',
          status: SlotStatus.taken,
        ),
        SlotOption(
          start: '19:00',
          end: '22:00',
          label: '19:00–22:00',
          status: SlotStatus.free,
        ),
      ];

  @override
  Future<Reservation> requestReservation({
    required String areaId,
    required String date,
    required SlotOption slot,
  }) async {
    requests.add((areaId: areaId, date: date, start: slot.start));
    if (requestError != null) throw requestError!;
    return Reservation(
      id: 'res-new',
      status: ReservationStatus.pendingApproval,
      areaId: areaId,
      areaName: 'Parrilla',
      areaIcon: 'flame',
      buildingName: 'Edificio Demo',
      date: date,
      slotLabel: slot.label,
      fee: 50,
      deposit: 100,
      total: 150,
      requestedAt: DateTime.utc(2026, 11, 11, 14),
    );
  }
}
