import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/user_model.dart';

class SecureTokenVault {
  static const _keyAccessToken = 'mp_access_token';
  static const _keyRefreshToken = 'mp_refresh_token';
  static const _keyActiveRole = 'mp_active_role';
  static const _keyUserData = 'mp_user_data';

  final FlutterSecureStorage _storage;

  SecureTokenVault({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(resetOnError: true),
            );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<void> saveActiveRole(String roleCode) async {
    await _storage.write(key: _keyActiveRole, value: roleCode);
  }

  Future<String?> getActiveRole() async {
    return await _storage.read(key: _keyActiveRole);
  }

  Future<void> saveUser(UserModel user) async {
    final jsonStr = jsonEncode(user.toJson());
    await _storage.write(key: _keyUserData, value: jsonStr);
  }

  Future<UserModel?> getUser() async {
    final jsonStr = await _storage.read(key: _keyUserData);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearVault() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
