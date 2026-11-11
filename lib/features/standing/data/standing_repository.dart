import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_client.dart';

/// Mirrors `GET /v1/residents/me/standing` (rule 5: up to date, one grace day).
class Standing {
  const Standing({
    required this.upToDate,
    required this.overdueAmount,
    required this.oldestOverdueDate,
  });

  factory Standing.fromJson(Map<String, dynamic> json) => Standing(
    upToDate: json['upToDate'] as bool,
    overdueAmount: json['overdueAmount'] as num,
    oldestOverdueDate: json['oldestOverdueDate'] as String?,
  );

  final bool upToDate;
  final num overdueAmount;

  /// yyyy-MM-dd
  final String? oldestOverdueDate;
}

final standingRepositoryProvider = Provider<StandingRepository>(
  (ref) => StandingRepository(ref.watch(apiClientProvider)),
);

class StandingRepository {
  StandingRepository(this._api);

  final ApiClient _api;

  Future<Standing> fetchStanding() async => Standing.fromJson(
    await _api.get<Map<String, dynamic>>('/residents/me/standing'),
  );
}
