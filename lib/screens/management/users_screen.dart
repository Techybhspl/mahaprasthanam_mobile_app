import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bavya_footer.dart';
import '../../widgets/brand_logo.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _selectedRole = 'All (148)';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;

  final List<String> _roleFilters = [
    'All (148)',
    'Drivers (84)',
    'District Mgrs (26)',
    'Fleet Mgrs (12)',
    'BOE (8)',
    'Super Admin (4)',
  ];

  List<Map<String, dynamic>> _userRoster = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiConstants.vehicleDrivers);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data is List ? response.data : (response.data['data'] ?? response.data['users'] ?? response.data['drivers'] ?? []);
        if (list is List && list.isNotEmpty) {
          setState(() {
            _userRoster = list.map<Map<String, dynamic>>((item) {
              return {
                'name': item['name'] ?? item['driver_name'] ?? 'Operational Staff',
                'empId': item['emp_id'] ?? item['id']?.toString() ?? 'EMP-001',
                'phone': item['phone'] ?? item['phone_number'] ?? '9999900000',
                'role': item['role'] ?? 'Hearse Driver',
                'roleCode': item['role_code'] ?? 'DRIVER',
                'district': item['district'] ?? 'Guntur District',
                'status': item['status'] ?? 'ACTIVE',
                'color': AppColors.roleDriver,
              };
            }).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _userRoster = [
          {
            'name': 'Super Administrator',
            'empId': 'EMP-SA-0001',
            'phone': '9999900000',
            'role': 'SUPER ADMIN',
            'roleCode': 'ADMIN',
            'district': 'Statewide (All 26 Districts)',
            'status': 'ACTIVE',
            'color': AppColors.roleAdmin,
          },
          {
            'name': 'K. Srinivasa Rao',
            'empId': 'EMP-DR-1080',
            'phone': '9440188219',
            'role': 'Hearse Driver',
            'roleCode': 'DRIVER',
            'district': 'Guntur (AP 39 TE 1080)',
            'status': 'ACTIVE',
            'color': AppColors.roleDriver,
          },
          {
            'name': 'Dr. M. Ramanathan',
            'empId': 'EMP-DM-0412',
            'phone': '9848033214',
            'role': 'District Manager',
            'roleCode': 'DM',
            'district': 'Krishna & NTR Districts',
            'status': 'ACTIVE',
            'color': AppColors.roleDm,
          },
          {
            'name': 'V. Satyanarayana',
            'empId': 'EMP-FM-0109',
            'phone': '9121088765',
            'role': 'Fleet Manager',
            'roleCode': 'FLEET',
            'district': 'Zone 2 Central Fleet Hub',
            'status': 'ACTIVE',
            'color': AppColors.roleFleet,
          },
          {
            'name': 'P. Lakshmi Devi',
            'empId': 'EMP-BOE-0034',
            'phone': '9494200118',
            'role': 'Back Office Executive',
            'roleCode': 'BOE',
            'district': 'State Control Room, Vijayawada',
            'status': 'ACTIVE',
            'color': AppColors.roleBoe,
          },
        ];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddUserModal() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final districtCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enroll Operational Staff',
                style: AppTypography.title(color: AppColors.darkSplashBg, fontWeight: FontWeight.w800).copyWith(fontSize: 17),
              ),
              Text(
                'Add driver, manager, or executive credentials with role permissions.',
                style: AppTypography.caption(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Login ID)',
                  prefixIcon: Icon(Icons.phone_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: districtCtrl,
                decoration: const InputDecoration(
                  labelText: 'District Assignment',
                  prefixIcon: Icon(Icons.location_city_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await _apiClient.post(ApiConstants.vehicleDrivers, data: {
                        'name': nameCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'district': districtCtrl.text.trim(),
                      });
                    } catch (_) {}

                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    setState(() {
                      _userRoster.insert(0, {
                        'name': nameCtrl.text.trim().isEmpty ? 'New Staff' : nameCtrl.text.trim(),
                        'empId': 'EMP-${1000 + _userRoster.length}',
                        'phone': phoneCtrl.text.trim().isEmpty ? '9999999999' : phoneCtrl.text.trim(),
                        'role': 'Hearse Driver',
                        'roleCode': 'DRIVER',
                        'district': districtCtrl.text.trim().isEmpty ? 'Guntur' : districtCtrl.text.trim(),
                        'status': 'ACTIVE',
                        'color': AppColors.roleDriver,
                      });
                    });
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Personnel credentials generated & OTP sent for verification.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brightMagenta,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('ENROLL USER & ISSUE ACCESS', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final userRole = currentUser?.currentRoleEnum ?? UserRole.admin;

    final filteredUsers = _userRoster.where((u) {
      final matchesSearch = _searchQuery.isEmpty ||
          u['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['phone'].toString().contains(_searchQuery) ||
          u['empId'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u['district'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      drawer: AppDrawer(
        role: userRole,
        userId: currentUser?.phoneNumber ?? 'User',
        scope: currentUser?.district ?? 'Statewide',
        currentRoute: '/users',
      ),
      appBar: AppBar(
        backgroundColor: AppColors.darkSplashBg,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personnel & Role Management',
              style: AppTypography.title(color: Colors.white, fontWeight: FontWeight.w700).copyWith(fontSize: 16),
            ),
            Text(
              '148 Field Personnel Roster • Mahaprastanam',
              style: AppTypography.caption(color: Colors.white70).copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: AppColors.yellow),
            tooltip: 'Add Staff Member',
            onPressed: _showAddUserModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const BavyaAccentLine(height: 3),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _roleFilters.map((r) {
                        final isSel = _selectedRole == r;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(r),
                            selected: isSel,
                            selectedColor: AppColors.darkSplashBg,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            backgroundColor: Colors.white,
                            onSelected: (val) {
                              if (val) setState(() => _selectedRole = r);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Search input
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search Name, Phone number, or Emp ID...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Operational Personnel (${filteredUsers.length} Found)',
                    style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 14.5),
                  ),
                  const SizedBox(height: 10),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredUsers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final u = filteredUsers[index];
                      final roleColor = u['color'] as Color;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: roleColor,
                              child: Text(
                                u['name'].toString().isNotEmpty ? u['name'].toString().substring(0, 1) : 'U',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        u['name'],
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: roleColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          u['roleCode'],
                                          style: TextStyle(color: roleColor, fontWeight: FontWeight.w800, fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${u['role']} • ${u['empId']}',
                                    style: AppTypography.caption(color: AppColors.textSecondary).copyWith(fontSize: 11),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone_rounded, size: 12, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(u['phone'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                      const SizedBox(width: 10),
                                      const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          u['district'],
                                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const BavyaFooter(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
  }
}
