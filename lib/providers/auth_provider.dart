import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _currentUser;
  UserRole _selectedRole = UserRole.driver;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  UserModel? get currentUser => _currentUser;
  UserRole get selectedRole => _selectedRole;
  UserRole get currentRole => _currentUser?.currentRoleEnum ?? _selectedRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  void setSelectedRole(UserRole role) {
    if (_selectedRole == role) return;
    _selectedRole = role;
    notifyListeners();
  }

  Future<void> initializeSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.restoreSession();
      if (user != null) {
        _currentUser = user;
        _selectedRole = user.currentRoleEnum;
      }
    } catch (_) {
      // Ignored during startup initialization
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String identity,
    required String password,
    UserRole? role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(
        identity: identity,
        password: password,
        role: role,
      );
      _currentUser = user;
      _selectedRole = role ?? user.currentRoleEnum;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> switchRole(UserRole newRole) async {
    _selectedRole = newRole;
    await _authService.switchRole(newRole);
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        activeRole: newRole.roleCode,
      );
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (_) {
      // Silently proceed so user is logged out locally even if server fails
    } finally {
      _currentUser = null;
      _selectedRole = UserRole.driver;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}
