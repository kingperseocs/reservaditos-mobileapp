import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/area_models.dart';
import '../data/areas_repository.dart';

/// «Edificio Demo · Ana Pérez · Depto 502» for the header.
final residentProfileProvider = FutureProvider<ResidentProfile>(
  (ref) => ref.watch(areasRepositoryProvider).fetchProfile(),
);

/// Areas with fee, deposit and today's availability (screen 1).
final areasProvider = FutureProvider<List<ResidentArea>>(
  (ref) => ref.watch(areasRepositoryProvider).fetchAreas(),
);
