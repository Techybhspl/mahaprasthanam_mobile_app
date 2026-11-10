import 'package:flutter_test/flutter_test.dart';
import 'package:mahaprastanam/models/user_model.dart';
import 'package:mahaprastanam/models/user_role.dart';

void main() {
  group('Auth & UserModel Unit Tests', () {
    test('UserModel.fromJson parses nested role_permissions correctly', () {
      final json = {
        'access_token': 'jwt_access_123',
        'refresh_token': 'jwt_refresh_456',
        'user': {
          'id': 142,
          'name': 'Ravi Kumar',
          'phone': '9876543210',
          'is_super_admin': false,
        },
        'roles': [
          {
            'project_id': 5,
            'role_name': 'DRIVER',
            'project_name': 'MAHAPRASTHANAM - AP',
          }
        ],
        'role_permissions': {
          'DRIVER': {
            'driver_home': ['view', 'edit'],
            'live_trip': ['view'],
          }
        },
        'disabled_modules': ['fuel_intel'],
      };

      final user = UserModel.fromJson(json);
      expect(user.id, equals(142));
      expect(user.name, equals('Ravi Kumar'));
      expect(user.phone, equals('9876543210'));
      expect(user.currentRoleEnum, equals(UserRole.driver));
      expect(user.projects.length, equals(1));
      expect(user.projects.first.id, equals(5));
      expect(user.projects.first.name, equals('MAHAPRASTHANAM - AP'));
      expect(user.district, equals('MAHAPRASTHANAM - AP'));
      expect(user.canAccess('driver_home'), isTrue);
      expect(user.canAccess('fuel_intel'), isFalse); // disabled module
    });

    test('UserModel.fromJson parses flat role_permissions correctly', () {
      final json = {
        'user': {
          'id': '101',
          'name': 'Lakshmi Fleet Mgr',
          'phone': '9812345678',
        },
        'roles': ['DFM'],
        'role_permissions': {
          'fleet_management': ['view', 'approve'],
          'offroad': ['view', 'create'],
        },
      };

      final user = UserModel.fromJson(json);
      expect(user.id, equals(101));
      expect(user.currentRoleEnum, equals(UserRole.fleetManager));
      expect(user.canAccess('fleet_management'), isTrue);
      expect(user.canAccess('offroad'), isTrue);
    });

    test('UserModel deduplicates identical role entries', () {
      final json = {
        'user': {'id': 99, 'name': 'Multi-Project Driver'},
        'roles': [
          {'role_name': 'DRIVER', 'project_id': 1},
          {'role_name': 'DRIVER', 'project_id': 2},
        ],
      };

      final user = UserModel.fromJson(json);
      expect(user.roles.length, equals(1));
      expect(user.roles.first, equals('DRIVER'));
    });

    test('UserModel parses is_super_admin as int (1) or string', () {
      final jsonInt = {
        'user': {'id': 1, 'is_super_admin': 1, 'name': 'Root Admin'},
        'roles': ['ADMIN'],
      };
      final user1 = UserModel.fromJson(jsonInt);
      expect(user1.isSuperAdmin, isTrue);
      expect(user1.currentRoleEnum, equals(UserRole.admin));
      expect(user1.canAccess('any_restricted_module'), isTrue);
    });
  });
}

