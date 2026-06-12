import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

/// Typed API failure surfaced to the UI layer.
class ApiException extends Equatable implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
    this.original,
  });

  factory ApiException.fromDioException(DioException error) {
    final response = error.response;
    final data = response?.data;

    String message = 'An unexpected error occurred';
    Map<String, dynamic>? fieldErrors;

    if (data is Map<String, dynamic>) {
      message = data['error'] as String? ??
          data['message'] as String? ??
          message;
      final rawErrors = data['errors'];
      if (rawErrors is Map<String, dynamic>) {
        fieldErrors = rawErrors;
      }
    } else if (error.message != null) {
      message = error.message!;
    }

    return ApiException(
      message: message,
      statusCode: response?.statusCode,
      errors: fieldErrors,
      original: error,
    );
  }

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;
  final DioException? original;

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  List<Object?> get props => [message, statusCode, errors];

  @override
  String toString() => 'ApiException($statusCode): $message';
}
