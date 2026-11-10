import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_token_vault.dart';
import 'auth_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  final SecureTokenVault _vault;

  ApiClient({SecureTokenVault? vault}) : _vault = vault ?? SecureTokenVault() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
          'Accept': ApiConstants.contentTypeJson,
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(vault: _vault, dio: _dio),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final screenTag = _getScreenTag(options.path);
          debugPrint('$screenTag 🚀 REQUEST [${options.method}] => URL: ${options.baseUrl}${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final screenTag = _getScreenTag(response.requestOptions.path);
          debugPrint('$screenTag ✅ RESPONSE [${response.statusCode}] => Data: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          final screenTag = _getScreenTag(e.requestOptions.path);
          debugPrint('$screenTag ❌ ERROR [${e.response?.statusCode}] => Message: ${e.message} | Response: ${e.response?.data}');
          return handler.next(e);
        },
      ),
    ]);
  }

  String _getScreenTag(String path) {
    if (path.contains('/auth/login')) return '[LOGIN_SCREEN]';
    if (path.contains('/auth/me') || path.contains('/auth/refresh') || path.contains('/auth/fcm') || path.contains('/auth/language')) return '[SPLASH_SCREEN]';
    if (path.contains('/dashboard')) return '[DASHBOARD_SCREEN]';
    if (path.contains('/vehicle-drivers') || path.contains('/vehicles')) return '[VEHICLE_MANAGEMENT_SCREEN]';
    if (path.contains('/beneficiaries')) return '[BENEFICIARY_SCREEN]';
    if (path.contains('/maintenance')) return '[MAINTENANCE_SCREEN]';
    if (path.contains('/fuel')) return '[FUEL_SCREEN]';
    if (path.contains('/offroad')) return '[OFFROAD_SCREEN]';
    if (path.contains('/submissions') || path.contains('/templates')) return '[FILL_REPORT_SCREEN]';
    if (path.contains('/feedback')) return '[FEEDBACK_SCREEN]';
    if (path.contains('/gps')) return '[GPS_TELEMATICS_SCREEN]';
    if (path.contains('/geography')) return '[GEOGRAPHY_SCREEN]';
    return '[GENERAL_API]';
  }

  Dio get dio => _dio;
  SecureTokenVault get vault => _vault;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> uploadFile<T>({
    required String path,
    required FormData formData,
    ProgressCallback? onSendProgress,
  }) async {
    return await _dio.post<T>(
      path,
      data: formData,
      options: Options(
        headers: {
          ApiConstants.headerContentType: ApiConstants.contentTypeMultipart,
        },
      ),
      onSendProgress: onSendProgress,
    );
  }
}
