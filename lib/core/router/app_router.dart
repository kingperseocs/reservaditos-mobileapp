import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/areas/data/area_models.dart';
import '../../features/areas/presentation/areas_screen.dart';
import '../../features/booking/presentation/booking_screen.dart';
import '../../features/reservation/presentation/reservation_screen.dart';

/// Routes of the resident app. Screen 4 («No está al día») is a bottom sheet
/// over screen 1, so it has no route of its own.
final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AreasScreen(),
        routes: [
          GoRoute(
            path: 'areas/:areaId/booking',
            builder: (context, state) => BookingScreen(
              areaId: state.pathParameters['areaId']!,
              area: state.extra as ResidentArea?,
            ),
          ),
          GoRoute(
            path: 'reservations/:id',
            builder: (context, state) =>
                ReservationScreen(reservationId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  ),
);
