/// Runtime configuration, overridable with `--dart-define` (see README).
///
/// From the Android emulator, `10.0.2.2` is the host machine, so the default
/// reaches the backend running on the PC at port 8000.
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.residentId,
    required this.pollInterval,
  });

  factory AppConfig.fromEnvironment() => const AppConfig(
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000/v1',
    ),
    residentId: String.fromEnvironment(
      'RESIDENT_ID',
      defaultValue: 'ana-perez',
    ),
    pollInterval: Duration(seconds: 10),
  );

  /// Backend base URL including the API version.
  final String apiBaseUrl;

  /// Simulated identity sent as `x-user-id` (the backend has no login).
  final String residentId;

  /// How often «Mi reserva» refreshes to notice the administration's answer.
  final Duration pollInterval;
}
