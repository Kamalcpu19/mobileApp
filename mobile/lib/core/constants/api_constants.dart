import 'package:flutter/foundation.dart';

/// API configuration and endpoint paths.
abstract final class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String appointments = '/appointments';
  static const String repairOrders = '/repair-orders';
  static const String vehicles = '/vehicles';
  static const String inspections = '/inspections';
  static const String complaints = '/complaints';
  static const String estimates = '/estimates';
  static const String ai = '/ai';
  static const String invoices = '/invoices';
  static const String customers = '/customers';

  static String get platformBaseUrl {
    if (kIsWeb) return baseUrl;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return baseUrl.replaceFirst('localhost', '10.0.2.2');
    }
    return baseUrl;
  }
}
