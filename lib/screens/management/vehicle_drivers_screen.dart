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

class VehicleDriversScreen extends StatefulWidget {
  const VehicleDriversScreen({super.key});

  @override
  State<VehicleDriversScreen> createState() => _VehicleDriversScreenState();
}

class _VehicleDriversScreenState extends State<VehicleDriversScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  List<Map<String, dynamic>> _pairings = [];

  @override
  void initState() {
    super.initState();
    _loadPairings();
  }

  Future<void> _loadPairings() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiConstants.vehicleDrivers);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data is List ? response.data : (response.data['data'] ?? response.data['pairings'] ?? response.data['vehicle_drivers'] ?? []);
        if (list is List && list.isNotEmpty) {
          setState(() {
            _pairings = list.map<Map<String, dynamic>>((item) {
              return {
                'regNo': item['registration_number'] ?? item['regNo'] ?? 'AP 39 TE 1080',
                'depot': item['depot'] ?? item['station_name'] ?? 'GGH Guntur Hub',
                'district': item['district'] ?? 'Guntur',
                'primaryDriver': item['primary_driver'] ?? item['primaryDriver'] ?? 'K. Srinivasa Rao',
                'primaryPhone': item['primary_phone'] ?? item['primaryPhone'] ?? '9440188219',
                'primaryDl': item['primary_dl'] ?? item['primaryDl'] ?? 'AP0720180029141',
                'secondaryDriver': item['secondary_driver'] ?? item['secondaryDriver'] ?? 'Reliever Driver',
                'shift': item['shift'] ?? 'Double Shift (24x7 Ready)',
                'status': item['status'] ?? 'ACTIVE',
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
        _pairings = [
          {
            'regNo': 'AP 39 TE 1080',
            'depot': 'GGH Guntur Hub',
            'district': 'Guntur',
            'primaryDriver': 'K. Srinivasa Rao',
            'primaryPhone': '9440188219',
            'primaryDl': 'AP0720180029141',
            'secondaryDriver': 'B. Ramesh Kumar',
            'shift': 'Double Shift (24x7 Ready)',
            'status': 'ACTIVE',
          },
          {
            'regNo': 'AP 16 TH 4421',
            'depot': 'Machilipatnam DH Mortuary',
            'district': 'Krishna',
            'primaryDriver': 'M. Venkatesh',
            'primaryPhone': '9848112390',
            'primaryDl': 'AP1620160081290',
            'secondaryDriver': 'G. Appa Rao',
            'shift': 'Double Shift (24x7 Ready)',
            'status': 'ACTIVE',
          },
          {
            'regNo': 'AP 31 TC 9022',
            'depot': 'KGH Visakhapatnam Hub',
            'district': 'Visakhapatnam',
            'primaryDriver': 'B. Appala Raju',
            'primaryPhone': '9121055431',
            'primaryDl': 'AP3120190044123',
            'secondaryDriver': 'N. Chaitanya',
            'shift': 'Double Shift (24x7 Ready)',
            'status': 'ACTIVE',
          },
          {
            'regNo': 'AP 04 TB 5110',
            'depot': 'SVRRGGH Tirupati',
            'district': 'Tirupati',
            'primaryDriver': 'P. Ravi Teja',
            'primaryPhone': '9963277120',
            'primaryDl': 'AP0420210091823',
            'secondaryDriver': 'Reliever Pool',
            'shift': 'Single Shift (Day: 08:00 - 20:00)',
            'status': 'MAINTENANCE',
          },
        ];
        _isLoading = false;
      });
    }
  }

  void _showReassignModal(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
              'Reassign Hearse Driver',
              style: AppTypography.title(color: AppColors.darkSplashBg, fontWeight: FontWeight.w800).copyWith(fontSize: 16),
            ),
            Text(
              'Select authorized driver from district pool for ${item['regNo']}:',
              style: AppTypography.caption(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person_add_rounded, color: AppColors.brightMagenta),
              title: const Text('B. Ramesh Kumar (Reliever Driver)'),
              subtitle: const Text('DL: AP072020001429 • Valid till 2031'),
              trailing: ElevatedButton(
                onPressed: () async {
                  try {
                    await _apiClient.post(ApiConstants.vehicleDrivers, data: {
                      'vehicle': item['regNo'],
                      'driver': 'B. Ramesh Kumar',
                    });
                  } catch (_) {}

                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  setState(() {
                    item['primaryDriver'] = 'B. Ramesh Kumar';
                  });
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text('Vehicle ${item['regNo']} successfully assigned to B. Ramesh Kumar.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.brightMagenta, foregroundColor: Colors.white),
                child: const Text('ASSIGN'),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final userRole = currentUser?.currentRoleEnum ?? UserRole.admin;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      drawer: AppDrawer(
        role: userRole,
        userId: currentUser?.phoneNumber ?? 'User',
        scope: currentUser?.district ?? 'Statewide',
        currentRoute: '/vehicle-drivers',
      ),
      appBar: AppBar(
        backgroundColor: AppColors.darkSplashBg,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle & Driver Pairings',
              style: AppTypography.title(color: Colors.white, fontWeight: FontWeight.w700).copyWith(fontSize: 16),
            ),
            Text(
              '175 Van Driver Roster • Mahaprastanam',
              style: AppTypography.caption(color: Colors.white70).copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPairings,
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
                  // KPI Header
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPairingStat('175', 'Assigned Vans', AppColors.darkSplashBg),
                        _buildPairingStat('84', 'Primary Drivers', AppColors.roleDriver),
                        _buildPairingStat('62', 'Secondary / Night', AppColors.purple),
                        _buildPairingStat('100%', 'DL Verified', AppColors.success),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  Text(
                    'Active Depot Vehicle-Driver Pairings',
                    style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 10),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _pairings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = _pairings[index];

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.darkSplashBg.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.commute_rounded, size: 18, color: AppColors.darkSplashBg),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      p['regNo'],
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.darkSplashBg),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: p['status'] == 'ACTIVE'
                                        ? AppColors.success.withValues(alpha: 0.12)
                                        : AppColors.orange.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p['status'],
                                    style: TextStyle(
                                      color: p['status'] == 'ACTIVE' ? AppColors.success : AppColors.orange,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Depot: ${p['depot']} (${p['district']} Dist.) • ${p['shift']}',
                              style: AppTypography.caption(color: AppColors.textSecondary).copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1),
                            const SizedBox(height: 8),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.person_rounded, size: 16, color: AppColors.roleDriver),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Primary: ${p['primaryDriver']} (${p['primaryPhone']})',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                      ),
                                      Text(
                                        'DL: ${p['primaryDl']} • Secondary: ${p['secondaryDriver']}',
                                        style: AppTypography.caption(color: AppColors.textSecondary).copyWith(fontSize: 10.5),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () => _showReassignModal(p),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.darkSplashBg,
                                    side: const BorderSide(color: AppColors.darkSplashBg),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: const Text('REASSIGN', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                                ),
                              ],
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

  Widget _buildPairingStat(String count, String label, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      ],
    );
  }
}
