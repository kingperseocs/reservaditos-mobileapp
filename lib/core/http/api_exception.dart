import 'package:dio/dio.dart';

/// Error returned by the backend: `{ statusCode, code, message, details? }`.
/// `message` is already in Spanish and can be shown to the resident.
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details = const {},
  });

  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> &&
        data['code'] is String &&
        data['message'] is String) {
      return ApiException(
        statusCode: error.response?.statusCode ?? 0,
        code: data['code'] as String,
        message: data['message'] as String,
        details: (data['details'] as Map<String, dynamic>?) ?? const {},
      );
    }
    if (error.response == null) {
      return const ApiException(
        statusCode: 0,
        code: 'NETWORK_ERROR',
        message: 'No se pudo conectar con el servidor. Revisa tu conexión.',
      );
    }
    return ApiException(
      statusCode: error.response?.statusCode ?? 0,
      code: 'HTTP_ERROR',
      message: 'Ocurrió un error inesperado.',
    );
  }

  final int statusCode;
  final String code;
  final String message;
  final Map<String, dynamic> details;

  @override
  String toString() => 'ApiException($statusCode $code: $message)';
}
