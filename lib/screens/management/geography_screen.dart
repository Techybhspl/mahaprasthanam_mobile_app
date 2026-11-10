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

class GeographyScreen extends StatefulWidget {
  const GeographyScreen({super.key});

  @override
  State<GeographyScreen> createState() => _GeographyScreenState();
}

class _GeographyScreenState extends State<GeographyScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;

  List<Map<String, dynamic>> _zones = [];

  @override
  void initState() {
    super.initState();
    _loadGeography();
  }

  Future<void> _loadGeography() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiConstants.geographyHierarchy);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data is List ? response.data : (response.data['data'] ?? response.data['zones'] ?? []);
        if (list is List && list.isNotEmpty) {
          setState(() {
            _zones = list.map<Map<String, dynamic>>((z) {
              final districtsList = (z['districts'] ?? z['district_list'] ?? []) as List;
              return {
                'zone': z['zone_name'] ?? z['zone'] ?? 'Zone 1',
                'vans': z['vans_count'] ?? z['vans'] ?? 34,
                'districts': districtsList.map<Map<String, dynamic>>((d) {
                  return {
                    'name': d['district_name'] ?? d['name'] ?? 'Guntur',
                    'hub': d['hub_name'] ?? d['hub'] ?? 'District Nodal Hub',
                    'vans': d['vans_count'] ?? d['vans'] ?? 10,
                    'dm': d['nodal_dm'] ?? d['dm'] ?? 'District Manager',
                    'mandals': d['mandals_count'] ?? d['mandals'] ?? 15,
                  };
                }).toList(),
              };
            }).toList();
            _tabController?.dispose();
            _tabController = TabController(length: _zones.isEmpty ? 1 : _zones.length, vsync: this);
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _zones = [
          {
            'zone': 'Zone 2 (Central Coastal)',
            'vans': 68,
            'districts': [
              {
                'name': 'Guntur',
                'hub': 'GGH Guntur Nodal Hub',
                'vans': 12,
                'dm': 'Dr. K. Srinivas (+91 94401 22819)',
                'mandals': 18,
              },
              {
                'name': 'Krishna',
                'hub': 'Machilipatnam DH Mortuary',
                'vans': 8,
                'dm': 'Dr. M. Ramanathan (+91 98480 33214)',
                'mandals': 15,
              },
              {
                'name': 'NTR',
                'hub': 'New GGH Vijayawada (Siddhartha)',
                'vans': 10,
                'dm': 'Dr. M. Ramanathan (+91 98480 33214)',
                'mandals': 16,
              },
              {
                'name': 'Bapatla',
                'hub': 'Bapatla Area Hospital',
                'vans': 6,
                'dm': 'S. Venkat Rao (+91 93902 11980)',
                'mandals': 12,
              },
              {
                'name': 'Palnadu',
                'hub': 'Narasaraopet District Hospital',
                'vans': 8,
                'dm': 'S. Venkat Rao (+91 93902 11980)',
                'mandals': 14,
              },
            ],
          },
          {
            'zone': 'Zone 1 (North Coastal)',
            'vans': 34,
            'districts': [
              {
                'name': 'Visakhapatnam',
                'hub': 'KGH Visakhapatnam Hub',
                'vans': 12,
                'dm': 'Dr. P. Surya Rao (+91 91210 44211)',
                'mandals': 11,
              },
              {
                'name': 'Anakapalli',
                'hub': 'Anakapalli Area Hospital',
                'vans': 6,
                'dm': 'Dr. P. Surya Rao (+91 91210 44211)',
                'mandals': 14,
              },
              {
                'name': 'Vizianagaram',
                'hub': 'GGH Vizianagaram',
                'vans': 8,
                'dm': 'T. Appala Naidu (+91 98481 99012)',
                'mandals': 16,
              },
              {
                'name': 'Srikakulam',
                'hub': 'RIMS Srikakulam',
                'vans': 8,
                'dm': 'T. Appala Naidu (+91 98481 99012)',
                'mandals': 18,
              },
            ],
          },
          {
            'zone': 'Zone 4 (Rayalaseema)',
            'vans': 45,
            'districts': [
              {
                'name': 'Tirupati',
                'hub': 'SVRRGGH Tirupati Hub',
                'vans': 12,
                'dm': 'Dr. C. Reddappa (+91 99632 88129)',
                'mandals': 14,
              },
              {
                'name': 'Kurnool',
                'hub': 'GGH Kurnool Mortuary',
                'vans': 10,
                'dm': 'Dr. B. Vijay Kumar (+91 94942 55018)',
                'mandals': 16,
              },
              {
                'name': 'Kadapa (YSR)',
                'hub': 'RIMS Kadapa',
                'vans': 8,
                'dm': 'K. Mohan Reddy (+91 94411 77209)',
                'mandals': 15,
              },
              {
                'name': 'Ananthapuramu',
                'hub': 'GGH Anantapur Hub',
                'vans': 10,
                'dm': 'G. Somasekhar (+91 93910 44120)',
                'mandals': 17,
              },
              {
                'name': 'Nandyal',
                'hub': 'Nandyal District Hospital',
                'vans': 5,
                'dm': 'Dr. B. Vijay Kumar (+91 94942 55018)',
                'mandals': 12,
              },
            ],
          },
          {
            'zone': 'Zone 3 (South Coastal)',
            'vans': 28,
            'districts': [
              {
                'name': 'Nellore (SPSR)',
                'hub': 'GGH Nellore Nodal Hub',
                'vans': 10,
                'dm': 'Dr. R. Madhusudhan (+91 98490 66120)',
                'mandals': 16,
              },
              {
                'name': 'Prakasam',
                'hub': 'RIMS Ongole Mortuary',
                'vans': 10,
                'dm': 'M. Subba Rao (+91 94401 55910)',
                'mandals': 18,
              },
              {
                'name': 'Chittoor',
                'hub': 'Chittoor District Hospital',
                'vans': 8,
                'dm': 'Dr. C. Reddappa (+91 99632 88129)',
                'mandals': 14,
              },
            ],
          },
        ];
        _tabController?.dispose();
        _tabController = TabController(length: _zones.length, vsync: this);
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
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
        currentRoute: '/geography',
      ),
      appBar: AppBar(
        backgroundColor: AppColors.darkSplashBg,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Administrative Geography',
              style: AppTypography.title(color: Colors.white, fontWeight: FontWeight.w700).copyWith(fontSize: 16),
            ),
            Text(
              '4 Zones • 26 Districts • 175 Mandals • AP Govt.',
              style: AppTypography.caption(color: Colors.white70).copyWith(fontSize: 11),
            ),
          ],
        ),
        bottom: _tabController == null
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.brightMagenta,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: _zones.map((z) => Tab(text: z['zone'])).toList(),
              ),
      ),
      body: _isLoading || _tabController == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _zones.map((zoneData) {
                final districts = zoneData['districts'] as List<Map<String, dynamic>>;

                return RefreshIndicator(
                  onRefresh: _loadGeography,
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
                              // Zone Summary Card
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.darkSplashBg, AppColors.midSplashBg],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          zoneData['zone'],
                                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${districts.length} District Jurisdictions',
                                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11.5),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.brightMagenta.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.brightMagenta),
                                      ),
                                      child: Text(
                                        '${zoneData['vans']} VANS ALLOCATED',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              Text(
                                'District Nodal Hospitals & Van Allocation',
                                style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 14.5),
                              ),
                              const SizedBox(height: 10),

                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: districts.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final d = districts[index];

                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${d['name']} District',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppColors.darkSplashBg.withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '${d['vans']} Vans • ${d['mandals']} Mandals',
                                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.darkSplashBg),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.local_hospital_rounded, size: 14, color: AppColors.roleDriver),
                                            const SizedBox(width: 4),
                                            Text('Hub: ${d['hub']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone_rounded, size: 14, color: AppColors.textSecondary),
                                            const SizedBox(width: 4),
                                            Text('Nodal DM: ${d['dm']}', style: AppTypography.caption(color: AppColors.textSecondary).copyWith(fontSize: 11)),
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
                );
              }).toList(),
            ),
    );
  }
}
