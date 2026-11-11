import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/standing_repository.dart';

/// Whether the resident can book (rule 5). Asked fresh every time
/// «Reservar» is tapped (the screen invalidates it), so a due paid a minute
/// ago is already reflected.
final standingProvider = FutureProvider<Standing>(
  (ref) => ref.watch(standingRepositoryProvider).fetchStanding(),
);
