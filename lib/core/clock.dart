import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current time, injectable so calendars and countdowns are testable.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
