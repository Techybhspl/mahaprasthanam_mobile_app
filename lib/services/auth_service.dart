import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_token_vault.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

class AuthService {
  final ApiClient _apiClient;
  final SecureTokenVault _vault;

  AuthService({
    ApiClient? apiClient,
    SecureTokenVault? vault,
  })  : _apiClient = apiClient ?? ApiClient(),
        _vault = vault ?? SecureTokenVault();

  SecureTokenVault get vault => _vault;

  Future<UserModel> login({
    required String identity,
    required String password,
    UserRole? role,
  }) async {
    final cleanIdentity = identity.trim();
    final cleanPassword = password.trim();

    if (cleanIdentity.isEmpty || cleanPassword.isEmpty) {
      throw Exception('Mobile Number / Employee ID and password are required.');
    }

    // Normalize phone number if entered with country code (+91 / 91 / 0)
    String normalizedIdentity = cleanIdentity;
    final digitsOnly = cleanIdentity.replaceAll(RegExp(r'\D'), '');

    String phoneToSend = cleanIdentity;
    String? employeeIdToSend;

    if (digitsOnly.length == 10 && RegExp(r'^[6-9]').hasMatch(digitsOnly)) {
      normalizedIdentity = digitsOnly;
      phoneToSend = digitsOnly;
    } else if (digitsOnly.length == 12 &&
        digitsOnly.startsWith('91') &&
        RegExp(r'^[6-9]').hasMatch(digitsOnly.substring(2))) {
      normalizedIdentity = digitsOnly.substring(2);
      phoneToSend = normalizedIdentity;
    } else if (digitsOnly.length == 11 &&
        digitsOnly.startsWith('0') &&
        RegExp(r'^[6-9]').hasMatch(digitsOnly.substring(1))) {
      normalizedIdentity = digitsOnly.substring(1);
      phoneToSend = normalizedIdentity;
    } else {
      // Non-phone input: alphanumeric Employee ID or User ID (e.g. DRV-1042, BHSPL-001, admin)
      employeeIdToSend = cleanIdentity;
    }

    // Match exact payload consumed by backend and web portal
    final requestData = <String, dynamic>{
      'identity': normalizedIdentity,
      'phone': phoneToSend,
      'password': cleanPassword,
      'employee_id': ?employeeIdToSend,
    };

    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: requestData,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};

        // Extract access token and refresh token from standard and nested payload structures
        String? accessToken =
            data['access_token']?.toString() ?? data['token']?.toString();
        String? refreshToken = data['refresh_token']?.toString();

        if (accessToken == null && data['data'] is Map<String, dynamic>) {
          final nested = data['data'] as Map<String, dynamic>;
          accessToken =
              nested['access_token']?.toString() ?? nested['token']?.toString();
          refreshToken ??= nested['refresh_token']?.toString();
        }

        if (accessToken != null && accessToken.isNotEmpty) {
          await _vault.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken ?? '',
          );
        }

        UserModel user = UserModel.fromJson(data);

        // Immediate session hydration via /auth/me for projects, scopes, and full permissions
        try {
          final meResponse = await _apiClient.get(ApiConstants.me);
          if (meResponse.statusCode == 200 && meResponse.data is Map<String, dynamic>) {
            final meData = meResponse.data as Map<String, dynamic>;
            final enriched = UserModel.fromJson(meData);
            user = user.copyWith(
              projects: enriched.projects.isNotEmpty ? enriched.projects : user.projects,
              permissions: enriched.permissions.isNotEmpty ? enriched.permissions : user.permissions,
              disabledModules: enriched.disabledModules.isNotEmpty ? enriched.disabledModules : user.disabledModules,
              name: enriched.name.isNotEmpty && enriched.name != 'Operations Staff' ? enriched.name : user.name,
              photoUrl: enriched.photoUrl ?? user.photoUrl,
            );
          }
        } catch (_) {
          // Continue gracefully if /auth/me background hydration fails
        }

        final effectiveRole = role ?? user.currentRoleEnum;
        await _vault.saveActiveRole(effectiveRole.roleCode);
        await _vault.saveUser(user);
        return user;
      } else {
        final errorMsg = response.data is Map
            ? (response.data['error'] ?? response.data['message'])
            : null;
        throw Exception(
          errorMsg?.toString() ??
              'Authentication failed with status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Authentication failed. Please verify credentials.';
      if (e.response != null) {
        final respData = e.response?.data;
        if (respData is Map) {
          errorMessage = respData['error']?.toString() ??
              respData['message']?.toString() ??
              respData['msg']?.toString() ??
              respData['detail']?.toString() ??
              'Invalid credentials (HTTP ${e.response?.statusCode})';
        } else if (respData is String && respData.isNotEmpty) {
          errorMessage = respData;
        } else if (e.response?.statusCode == 401) {
          errorMessage = 'Invalid username/ID or password.';
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'Access denied. You do not have permissions for this role.';
        } else if (e.response?.statusCode == 429) {
          errorMessage = 'Too many attempts. Please wait a minute and try again.';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Login endpoint or user account not found (404).';
        } else {
          errorMessage = 'Server error (${e.response?.statusCode}). Please try again later.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server connection timed out. Please check your network.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Unable to reach server (${ApiConstants.baseUrl}). Check your internet connection.';
      } else if (e.message != null && e.message!.isNotEmpty) {
        errorMessage = e.message!;
      }
      throw Exception(errorMessage);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Unexpected login error: $e');
    }
  }

  Future<UserModel?> restoreSession() async {
    final token = await _vault.getAccessToken();
    if (token == null || token.isEmpty) return null;

    final cachedUser = await _vault.getUser();
    if (cachedUser != null) {
      // Try background profile refresh
      _hydrateProfileInBackground();
      return cachedUser;
    }

    try {
      final response = await _apiClient.get(ApiConstants.me);
      if (response.statusCode == 200 && response.data != null) {
        final user = UserModel.fromJson(response.data as Map<String, dynamic>);
        await _vault.saveUser(user);
        return user;
      }
    } catch (_) {
      // Ignore background hydration failure if offline
    }
    return null;
  }

  Future<void> switchRole(UserRole newRole) async {
    final roleCode = _mapUserRoleToCode(newRole);
    await _vault.saveActiveRole(roleCode);
    final user = await _vault.getUser();
    if (user != null) {
      final updated = user.copyWith(activeRole: roleCode);
      await _vault.saveUser(updated);
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _vault.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _apiClient.post(
          ApiConstants.logout,
          data: {'refresh_token': refreshToken},
        );
      }
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      try {
        await _vault.clearVault();
      } catch (_) {}
    }
  }

  void _hydrateProfileInBackground() {
    _apiClient.get(ApiConstants.me).then((res) {
      if (res.statusCode == 200 && res.data != null) {
        final user = UserModel.fromJson(res.data as Map<String, dynamic>);
        _vault.saveUser(user);
      }
    }).catchError((_) {});
  }

  String _mapUserRoleToCode(UserRole role) => role.roleCode;
}

