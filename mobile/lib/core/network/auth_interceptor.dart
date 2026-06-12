import 'package:dio/dio.dart';

import 'package:workshop_service_advisor/core/network/api_client.dart';

/// Attaches JWT bearer tokens and handles 401 unauthorized responses.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenStorage tokenStorage,
    void Function()? onUnauthorized,
  })  : _dio = dio,
        _tokenStorage = tokenStorage,
        _onUnauthorized = onUnauthorized;

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final void Function()? _onUnauthorized;

  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty || _isRefreshing) {
      await _handleLogout();
      handler.next(err);
      return;
    }

    _isRefreshing = true;
    try {
      final refreshResponse = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      final data = refreshResponse.data;
      final newAccessToken = data?['accessToken'] as String?;
      final newRefreshToken = data?['refreshToken'] as String?;

      if (newAccessToken == null) {
        await _handleLogout();
        handler.next(err);
        return;
      }

      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(retryResponse);
    } on DioException catch (refreshError) {
      await _handleLogout();
      handler.next(refreshError);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _handleLogout() async {
    await _tokenStorage.clearTokens();
    _onUnauthorized?.call();
  }
}

/// Convenience helper for persisting tokens after login.
Future<void> persistAuthTokens(
  TokenStorage storage,
  Map<String, dynamic> response,
) async {
  final accessToken = response['accessToken'] as String? ??
      response['token'] as String?;
  final refreshToken = response['refreshToken'] as String?;

  if (accessToken == null) {
    throw StateError('Login response missing access token');
  }

  await storage.saveTokens(
    accessToken: accessToken,
    refreshToken: refreshToken,
  );
}

/// Clears stored credentials on sign-out.
Future<void> clearAuthSession(TokenStorage storage) async {
  await storage.clearTokens();
}
