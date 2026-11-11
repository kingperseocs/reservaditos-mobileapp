import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_client.dart';
import '../../reservation/data/reservation_models.dart';
import 'booking_models.dart';

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepository(ref.watch(apiClientProvider)),
);

/// HTTP access for screen 2: calendar, slots and the request itself.
class BookingRepository {
  BookingRepository(this._api);

  final ApiClient _api;

  /// [month] as yyyy-MM.
  Future<List<DayAvailability>> fetchMonth(String areaId, String month) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/areas/$areaId/availability',
      query: {'month': month},
    );
    return (json['days'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(DayAvailability.fromJson)
        .toList();
  }

  /// [date] as yyyy-MM-dd.
  Future<List<SlotOption>> fetchSlots(String areaId, String date) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/areas/$areaId/slots',
      query: {'date': date},
    );
    return (json['slots'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(SlotOption.fromJson)
        .toList();
  }

  Future<Reservation> requestReservation({
    required String areaId,
    required String date,
    required SlotOption slot,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      '/reservations',
      body: {
        'areaId': areaId,
        'date': date,
        'startTime': slot.start,
        'endTime': slot.end,
      },
    );
    return Reservation.fromJson(json);
  }
}
