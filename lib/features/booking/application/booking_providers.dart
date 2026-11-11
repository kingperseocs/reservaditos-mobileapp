import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../areas/application/areas_providers.dart';
import '../../areas/data/area_models.dart';
import '../data/booking_models.dart';
import '../data/booking_repository.dart';

/// Days of a month with or without free slots: (areaId, yyyy-MM).
final monthAvailabilityProvider = FutureProvider.autoDispose
    .family<Map<String, bool>, (String, String)>((ref, args) async {
      final (areaId, month) = args;
      final days = await ref
          .watch(bookingRepositoryProvider)
          .fetchMonth(areaId, month);
      return {for (final day in days) day.date: day.available};
    });

/// Slots of a day: (areaId, yyyy-MM-dd).
final daySlotsProvider = FutureProvider.autoDispose
    .family<List<SlotOption>, (String, String)>((ref, args) {
      final (areaId, date) = args;
      return ref.watch(bookingRepositoryProvider).fetchSlots(areaId, date);
    });

/// The area being booked. Uses the list already loaded on screen 1.
final bookingAreaProvider = FutureProvider.autoDispose
    .family<ResidentArea, String>((ref, areaId) async {
      final areas = await ref.watch(areasProvider.future);
      return areas.firstWhere((area) => area.id == areaId);
    });
