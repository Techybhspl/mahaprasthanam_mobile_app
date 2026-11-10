import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_token_vault.dart';

class AuthInterceptor extends QueuedInterceptor {
  final SecureTokenVault vault;
  final Dio dio;

  AuthInterceptor({
    required this.vault,
    required this.dio,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token injection for login and refresh endpoints
    final isAuthEndpoint = options.path.contains(ApiConstants.login) ||
        options.path.contains(ApiConstants.refresh);

    if (!isAuthEndpoint) {
      final token = await vault.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers[ApiConstants.headerAuthorization] = 'Bearer $token';
      }

      final activeRole = await vault.getActiveRole();
      if (activeRole != null && activeRole.isNotEmpty) {
        options.headers[ApiConstants.headerActiveRole] = activeRole;
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only attempt silent refresh for protected endpoints (never login or refresh)
    final isAuthEndpoint = err.requestOptions.path.contains(ApiConstants.login) ||
        err.requestOptions.path.contains(ApiConstants.refresh);

    if (err.response?.statusCode == 401 && !isAuthEndpoint) {
      final refreshToken = await vault.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Standalone Dio instance to prevent infinite interceptor loops
          final tokenRefreshDio = Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              headers: {ApiConstants.headerContentType: ApiConstants.contentTypeJson},
            ),
          );

          final response = await tokenRefreshDio.post(
            ApiConstants.refresh,
            data: {'refresh_token': refreshToken},
          );

          if (response.statusCode == 200 && response.data != null) {
            final newAccessToken = response.data['access_token']?.toString();
            if (newAccessToken != null && newAccessToken.isNotEmpty) {
              await vault.saveTokens(
                accessToken: newAccessToken,
                refreshToken: refreshToken,
              );

              // Retry original request with fresh token
              final newOptions = err.requestOptions;
              newOptions.headers[ApiConstants.headerAuthorization] = 'Bearer $newAccessToken';

              final clonedResponse = await dio.fetch(newOptions);
              return handler.resolve(clonedResponse);
            }
          }
        } catch (_) {
          // Refresh failed: session expired, purge credentials
          await vault.clearVault();
        }
      }
    }

    handler.next(err);
  }
}
