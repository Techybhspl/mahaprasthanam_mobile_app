import 'user_role.dart';

class UserModel {
  final int id;
  final String name;
  final String phone;
  final List<String> roles;
  final String? activeRole;
  final String? languagePreference;
  final String? photoUrl;
  final List<ProjectModel> projects;
  final bool isSuperAdmin;
  final Map<String, List<String>> permissions;
  final List<String> disabledModules;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.roles,
    this.activeRole,
    this.languagePreference,
    this.photoUrl,
    this.projects = const [],
    this.isSuperAdmin = false,
    this.permissions = const {},
    this.disabledModules = const [],
  });

  UserRole get currentRoleEnum {
    if (isSuperAdmin) return UserRole.admin;
    final currentCode = (activeRole ?? (roles.isNotEmpty ? roles.first : 'DRIVER')).toUpperCase();
    return UserRole.fromCode(currentCode);
  }

  String get phoneNumber => phone;
  String get employeeId => 'EMP-$id';
  String get district => (projects.isNotEmpty ? projects.first.name : null) ?? 'Statewide';


  /// Checks if user has permission to access a functional module
  bool canAccess(String module) {
    if (isSuperAdmin || currentRoleEnum == UserRole.admin) return true;
    if (disabledModules.contains(module)) return false;
    if (permissions.containsKey(module) && permissions[module]!.isNotEmpty) {
      return true;
    }
    return currentRoleEnum.hasStaticPermission(module);
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userObj = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    var rawRoles = <String>[];
    if (json['roles'] is List) {
      rawRoles = (json['roles'] as List).map((e) {
        if (e is Map) {
          return (e['role_name'] ?? e['role'] ?? e['role_code'] ?? e['name'] ?? '').toString();
        }
        return e.toString();
      }).where((r) => r.isNotEmpty).toSet().toList();
    }

    final isSuper = userObj['is_super_admin'] == true ||
        userObj['is_super_admin'] == 1 ||
        userObj['is_super_admin']?.toString().toLowerCase() == 'true' ||
        json['is_super_admin'] == true ||
        json['is_super_admin'] == 1 ||
        rawRoles.any((r) => r.toUpperCase() == 'ADMIN' || r.toUpperCase() == 'SUPER ADMIN');

    if (isSuper && !rawRoles.contains('ADMIN')) {
      rawRoles.add('ADMIN');
    }

    var rawProjects = <ProjectModel>[];
    if (json['projects'] is List) {
      rawProjects = (json['projects'] as List)
          .whereType<Map<String, dynamic>>()
          .map((p) => ProjectModel.fromJson(p))
          .toList();
    }

    // Extract project scopes from roles array if top-level projects key was omitted
    if (rawProjects.isEmpty && json['roles'] is List) {
      final seenProjectIds = <int>{};
      for (final r in json['roles']) {
        if (r is Map && r.containsKey('project_id') && r['project_id'] != null) {
          final pid = r['project_id'] is int
              ? r['project_id'] as int
              : int.tryParse(r['project_id'].toString()) ?? 0;
          if (pid > 0 && !seenProjectIds.contains(pid)) {
            seenProjectIds.add(pid);
            final pname = r['project_name']?.toString() ?? 'MAHAPRASTHANAM - AP';
            rawProjects.add(ProjectModel(id: pid, name: pname));
          }
        }
      }
    }

    final Map<String, List<String>> perms = {};
    if (json['role_permissions'] is Map) {
      final rolePerms = json['role_permissions'] as Map;
      final currentCode = (json['active_role']?.toString() ??
              (rawRoles.isNotEmpty ? rawRoles.first : 'DRIVER'))
          .toUpperCase();

      for (final rKey in rolePerms.keys) {
        final val = rolePerms[rKey];
        if (val is Map) {
          // Nested structure: { "DRIVER": { "driver_home": ["view", "edit"] } }
          val.forEach((mod, acts) {
            if (acts is List) {
              final actList = acts.map((a) => a.toString()).toList();
              perms['$rKey.$mod'] = actList;
              if (rKey.toString().toUpperCase() == currentCode || isSuper) {
                perms[mod.toString()] = actList;
              }
            }
          });
        } else if (val is List) {
          // Flat structure: { "driver_home": ["view", "edit"] }
          final actList = val.map((a) => a.toString()).toList();
          perms[rKey.toString()] = actList;
        }
      }
    } else if (json['permissions'] is Map) {
      final pMap = json['permissions'] as Map;
      pMap.forEach((k, v) {
        if (v is List) {
          perms[k.toString()] = v.map((e) => e.toString()).toList();
        }
      });
    }

    final List<String> disabled = [];
    if (json['disabled_modules'] is List) {
      disabled.addAll((json['disabled_modules'] as List).map((e) => e.toString()));
    }

    final rawId = userObj['id'];
    final parsedId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '0') ?? 0;

    return UserModel(
      id: parsedId,
      name: userObj['name']?.toString() ??
          (userObj['employee_name']?.toString() ?? (isSuper ? 'Super Admin' : 'Operations Staff')),
      phone: userObj['phone']?.toString() ?? '',
      roles: rawRoles.isNotEmpty ? rawRoles : [json['role_code']?.toString() ?? 'DRIVER'],
      activeRole: isSuper ? 'ADMIN' : json['active_role']?.toString(),
      languagePreference: userObj['language_preference']?.toString() ?? 'te',
      photoUrl: userObj['photo_url']?.toString(),
      projects: rawProjects,
      isSuperAdmin: isSuper,
      permissions: perms,
      disabledModules: disabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'roles': roles,
      'active_role': activeRole,
      'language_preference': languagePreference,
      'photo_url': photoUrl,
      'projects': projects.map((p) => p.toJson()).toList(),
      'is_super_admin': isSuperAdmin,
      'permissions': permissions,
      'disabled_modules': disabledModules,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? phone,
    List<String>? roles,
    String? activeRole,
    String? languagePreference,
    String? photoUrl,
    List<ProjectModel>? projects,
    bool? isSuperAdmin,
    Map<String, List<String>>? permissions,
    List<String>? disabledModules,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      roles: roles ?? this.roles,
      activeRole: activeRole ?? this.activeRole,
      languagePreference: languagePreference ?? this.languagePreference,
      photoUrl: photoUrl ?? this.photoUrl,
      projects: projects ?? this.projects,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      permissions: permissions ?? this.permissions,
      disabledModules: disabledModules ?? this.disabledModules,
    );
  }
}

class ProjectModel {
  final int id;
  final String name;
  final String? code;

  const ProjectModel({
    required this.id,
    required this.name,
    this.code,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'MAHAPRASTHANAM - AP',
      code: json['code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}
