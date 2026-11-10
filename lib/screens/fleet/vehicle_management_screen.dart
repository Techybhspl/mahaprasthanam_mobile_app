import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bavya_footer.dart';
import '../../widgets/brand_logo.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import 'fleet_maintenance_screen.dart';
import 'offroad_management_screen.dart';

class VehicleManagementScreen extends StatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  State<VehicleManagementScreen> createState() => _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  String _selectedDistrict = 'All Districts';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;

  final List<String> _districts = [
    'All Districts',
    'Guntur',
    'Krishna',
    'NTR',
    'Visakhapatnam',
    'Tirupati',
    'Kurnool',
    'Nellore',
    'Prakasam',
  ];

  List<Map<String, dynamic>> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiConstants.vehicles);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data is List ? response.data : (response.data['data'] ?? response.data['vehicles'] ?? []);
        if (list is List && list.isNotEmpty) {
          setState(() {
            _vehicles = list.map<Map<String, dynamic>>((item) {
              return {
                'regNo': item['registration_number'] ?? item['regNo'] ?? 'AP 16 MP 1000',
                'model': item['model'] ?? item['vehicle_model'] ?? 'Force Trax Hearse',
                'district': item['district'] ?? 'Guntur',
                'depot': item['depot'] ?? item['station_name'] ?? 'District Nodal Hub',
                'driver': item['driver_name'] ?? item['driver'] ?? 'Assigned Driver',
                'phone': item['driver_phone'] ?? item['phone'] ?? '+91 94400 00000',
                'odometer': '${item['odometer'] ?? '42,000'} KM',
                'status': item['status'] ?? 'ON-ROAD',
                'fitness': item['fitness_expiry'] ?? item['fitness'] ?? 'Valid',
                'insurance': item['insurance_expiry'] ?? item['insurance'] ?? 'Valid',
                'freezerTemp': item['freezer_temp'] ?? '3.5°C',
              };
            }).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    // Fallback static/mock data if offline or API returns empty
    if (mounted) {
      setState(() {
        _vehicles = [
          {
            'regNo': 'AP 39 TE 1080',
            'model': 'Force Trax Cruiser Hearse Van',
            'district': 'Guntur',
            'depot': 'GGH Guntur Hub',
            'driver': 'K. Srinivasa Rao',
            'phone': '+91 94401 88219',
            'odometer': '42,180 KM',
            'status': 'ON-ROAD',
            'fitness': '14 Dec 2027',
            'insurance': '22 Feb 2027',
            'freezerTemp': '3.8°C',
          },
          {
            'regNo': 'AP 16 TH 4421',
            'model': 'Tata Winger Mortuary Specification',
            'district': 'Krishna',
            'depot': 'Machilipatnam District Hospital',
            'driver': 'M. Venkatesh',
            'phone': '+91 98481 12390',
            'odometer': '68,410 KM',
            'status': 'ON-ROAD',
            'fitness': '08 Aug 2027',
            'insurance': '19 Sep 2026',
            'freezerTemp': '4.1°C',
          },
          {
            'regNo': 'AP 31 TC 9022',
            'model': 'Force Trax Cruiser Hearse Van',
            'district': 'Visakhapatnam',
            'depot': 'KGH Visakhapatnam Hub',
            'driver': 'B. Appala Raju',
            'phone': '+91 91210 55431',
            'odometer': '35,920 KM',
            'status': 'ON-ROAD',
            'fitness': '25 Jan 2028',
            'insurance': '30 Nov 2026',
            'freezerTemp': '3.5°C',
          },
          {
            'regNo': 'AP 04 TB 5110',
            'model': 'Force Trax Cruiser Hearse Van',
            'district': 'Tirupati',
            'depot': 'SVRRGGH Tirupati',
            'driver': 'P. Ravi Teja',
            'phone': '+91 99632 77120',
            'odometer': '51,200 KM',
            'status': 'SERVICING',
            'fitness': '11 May 2027',
            'insurance': '14 Oct 2026',
            'freezerTemp': 'Offline',
          },
          {
            'regNo': 'AP 21 TZ 3309',
            'model': 'Tata Winger Mortuary Specification',
            'district': 'Kurnool',
            'depot': 'GGH Kurnool Mortuary',
            'driver': 'S. Khaja Hussain',
            'phone': '+91 93902 44109',
            'odometer': '84,950 KM',
            'status': 'OFF-ROAD',
            'fitness': 'Expired (Under Renewal)',
            'insurance': '12 Jul 2026',
            'freezerTemp': 'Fault',
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ON-ROAD':
        return AppColors.success;
      case 'SERVICING':
        return AppColors.orange;
      case 'OFF-ROAD':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showVehicleDetailsModal(Map<String, dynamic> v) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  v['regNo'],
                  style: AppTypography.title(color: AppColors.darkSplashBg, fontWeight: FontWeight.w800).copyWith(fontSize: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(v['status']).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    v['status'],
                    style: TextStyle(color: _getStatusColor(v['status']), fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                ),
              ],
            ),
            Text(v['model'], style: AppTypography.caption(color: AppColors.textSecondary).copyWith(fontSize: 12.5)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),

            _buildDetailRow('District & Hub', '${v['district']} • ${v['depot']}'),
            _buildDetailRow('Assigned Driver', '${v['driver']} (${v['phone']})'),
            _buildDetailRow('Odometer Reading', v['odometer']),
            _buildDetailRow('Fitness Expiry', v['fitness']),
            _buildDetailRow('Insurance Expiry', v['insurance']),
            _buildDetailRow('Freezer Telematics', v['freezerTemp']),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FleetMaintenanceScreen()));
                    },
                    icon: const Icon(Icons.build_rounded, size: 16),
                    label: const Text('MAINTENANCE'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkSplashBg,
                      side: const BorderSide(color: AppColors.darkSplashBg),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Inter-district transfer workflow initiated for ${v['regNo']}.'),
                          backgroundColor: AppColors.brightMagenta,
                        ),
                      );
                    },
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: Colors.white),
                    label: const Text('TRANSFER DEPOT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brightMagenta,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final userRole = currentUser?.currentRoleEnum ?? UserRole.fleetManager;

    final filteredVehicles = _vehicles.where((v) {
      final matchesDistrict = _selectedDistrict == 'All Districts' || v['district'] == _selectedDistrict;
      final matchesSearch = _searchQuery.isEmpty ||
          v['regNo'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v['driver'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v['depot'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesDistrict && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      drawer: AppDrawer(
        role: userRole,
        userId: currentUser?.phoneNumber ?? 'User',
        scope: currentUser?.district ?? 'Statewide',
        currentRoute: '/vehicles',
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentRoute: '/fleet/vehicles',
        role: userRole,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.darkSplashBg,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Asset Master',
              style: AppTypography.title(color: Colors.white, fontWeight: FontWeight.w700).copyWith(fontSize: 16),
            ),
            Text(
              'Statewide Fleet of 175 Hearse Vans • AP Govt.',
              style: AppTypography.caption(color: Colors.white70).copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: AppColors.yellow),
            tooltip: 'Off-Road Portal',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OffroadManagementScreen()));
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadVehicles,
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
                  // Statewide Fleet Stats Grid
                  Row(
                    children: [
                      _buildKpiCard('175', 'TOTAL VANS', Icons.commute_rounded, AppColors.darkSplashBg),
                      const SizedBox(width: 8),
                      _buildKpiCard('152', 'ON-ROAD', Icons.check_circle_rounded, AppColors.success),
                      const SizedBox(width: 8),
                      _buildKpiCard('19', 'SERVICING', Icons.build_circle_rounded, AppColors.orange),
                      const SizedBox(width: 8),
                      _buildKpiCard('4', 'OFF-ROAD', Icons.cancel_rounded, AppColors.error),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search Reg No, Driver name, or Depot...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // District Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _districts.map((d) {
                        final isSel = _selectedDistrict == d;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(d),
                            selected: isSel,
                            selectedColor: AppColors.darkSplashBg,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            backgroundColor: Colors.white,
                            onSelected: (val) {
                              if (val) setState(() => _selectedDistrict = d);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Count Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Showing ${filteredVehicles.length} of 175 Assets',
                          style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Fleet Health: 97.7%', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Vehicle List Cards
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredVehicles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final v = filteredVehicles[index];
                      final statusColor = _getStatusColor(v['status']);

                      return InkWell(
                        onTap: () => _showVehicleDetailsModal(v),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
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
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: AppColors.darkSplashBg.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.airline_seat_flat_rounded, color: AppColors.darkSplashBg, size: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        v['regNo'],
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.darkSplashBg),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                                    ),
                                    child: Text(
                                      v['status'],
                                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 10.5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(v['model'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary)),
                              const SizedBox(height: 3),
                              Text(
                                'Depot: ${v['depot']} (${v['district']} Dist.)',
                                style: AppTypography.caption(color: AppColors.textSecondary).copyWith(fontSize: 11),
                              ),
                              const SizedBox(height: 10),
                              const Divider(height: 1),
                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.person_pin_rounded, size: 15, color: AppColors.textSecondary),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(v['driver'], style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.speed_rounded, size: 15, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(v['odometer'], style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.darkSplashBg)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  Widget _buildKpiCard(String count, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(count, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
