import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/http/api_client.dart';
import 'area_models.dart';

final areasRepositoryProvider = Provider<AreasRepository>(
  (ref) => AreasRepository(ref.watch(apiClientProvider)),
);

/// HTTP access for screen 1. No state, no widgets.
class AreasRepository {
  AreasRepository(this._api);

  final ApiClient _api;

  Future<List<ResidentArea>> fetchAreas() async {
    final json = await _api.get<List<dynamic>>('/areas');
    return json
        .cast<Map<String, dynamic>>()
        .map(ResidentArea.fromJson)
        .toList();
  }

  Future<ResidentProfile> fetchProfile() async => ResidentProfile.fromJson(
    await _api.get<Map<String, dynamic>>('/residents/me'),
  );
}
