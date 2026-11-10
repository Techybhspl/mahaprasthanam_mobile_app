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

class GpsTrackingScreen extends StatefulWidget {
  const GpsTrackingScreen({super.key});

  @override
  State<GpsTrackingScreen> createState() => _GpsTrackingScreenState();
}

class _GpsTrackingScreenState extends State<GpsTrackingScreen> {
  String _selectedFilter = 'Moving (48)';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;

  final List<String> _filters = [
    'All (175)',
    'Moving (48)',
    'Idle (104)',
    'Servicing (19)',
    'Off-Road (4)',
  ];

  List<Map<String, dynamic>> _telemetryList = [];

  @override
  void initState() {
    super.initState();
    _loadGpsTelemetry();
  }

  Future<void> _loadGpsTelemetry() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiConstants.liveGpsVehicles);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data is List ? response.data : (response.data['data'] ?? response.data['vehicles'] ?? []);
        if (list is List && list.isNotEmpty) {
          setState(() {
            _telemetryList = list.map<Map<String, dynamic>>((item) {
              return {
                'regNo': item['registration_number'] ?? item['regNo'] ?? 'AP 16 MP 1000',
                'driver': item['driver_name'] ?? item['driver'] ?? 'Assigned Driver',
                'district': item['district'] ?? 'Guntur',
                'location': item['location'] ?? item['address'] ?? 'State Highway',
                'coordinates': item['coordinates'] ?? '16.5062° N, 80.6480° E',
                'speed': '${item['speed'] ?? 50} km/h',
                'status': item['status'] ?? 'Moving',
                'ignition': item['ignition'] ?? 'ON',
                'lastPing': item['last_ping'] ?? 'Just now',
                'freezer': item['freezer_temp'] ?? '3.5°C (Normal)',
                'destination': item['destination'] ?? 'District Hospital',
              };
            }).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    // Fallback static data if offline or API returns empty
    if (mounted) {
      setState(() {
        _telemetryList = [
          {
            'regNo': 'AP 39 TE 1080',
            'driver': 'K. Srinivasa Rao',
            'district': 'Guntur',
            'location': 'NH-16 near Mangalagiri Toll Plaza',
            'coordinates': '16.4412° N, 80.5721° E',
            'speed': '58 km/h',
            'status': 'Moving',
            'ignition': 'ON',
            'lastPing': '3 sec ago',
            'freezer': '3.8°C (Normal)',
            'destination': 'Tenali Municipal Residence',
          },
          {
            'regNo': 'AP 16 TH 4421',
            'driver': 'M. Venkatesh',
            'district': 'Krishna',
            'location': 'Machilipatnam Coastal Highway',
            'coordinates': '16.1875° N, 81.1389° E',
            'speed': '46 km/h',
            'status': 'Moving',
            'ignition': 'ON',
            'lastPing': '8 sec ago',
            'freezer': '4.1°C (Normal)',
            'destination': 'Avanigadda CHC',
          },
          {
            'regNo': 'AP 31 TC 9022',
            'driver': 'B. Appala Raju',
            'district': 'Visakhapatnam',
            'location': 'KGH Hospital Mortuary Depot',
            'coordinates': '17.7082° N, 83.2985° E',
            'speed': '0 km/h',
            'status': 'Idle',
            'ignition': 'OFF',
            'lastPing': '12 min ago',
            'freezer': '3.5°C (Normal)',
            'destination': 'Standby Hub',
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
      case 'Moving':
        return AppColors.success;
      case 'Idle':
        return AppColors.info;
      case 'Servicing':
        return AppColors.orange;
      case 'Off-Road':
      default:
        return AppColors.error;
    }
  }

  void _showRoutePlayback(String regNo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loading 24-hour GPS route playback for $regNo...'),
        backgroundColor: AppColors.brightMagenta,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final userRole = currentUser?.currentRoleEnum ?? UserRole.fleetManager;

    final filteredList = _telemetryList.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          t['regNo'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t['district'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      drawer: AppDrawer(
        role: userRole,
        userId: currentUser?.phoneNumber ?? 'User',
        scope: currentUser?.district ?? 'Statewide',
        currentRoute: '/gps',
      ),
      appBar: AppBar(
        backgroundColor: AppColors.darkSplashBg,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GPS Telematics & Corridor Tracking',
              style: AppTypography.title(color: Colors.white, fontWeight: FontWeight.w700).copyWith(fontSize: 16),
            ),
            Text(
              'Live 26-District Fleet Positioning • Mahaprastanam',
              style: AppTypography.caption(color: Colors.white70).copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.satellite_alt_rounded, color: AppColors.yellow),
            tooltip: 'Satellite Layer',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Switched to High-Resolution Satellite & Highway Corridor Map.'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadGpsTelemetry,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const BavyaAccentLine(height: 3),

            // Live Simulated GPS Map Canvas
            Container(
              height: 220,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Stylized Radar & Geographic grid lines
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MapGridPainter(),
                    ),
                  ),

                  // Overlay Controls
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.radar_rounded, color: AppColors.success, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'LIVE CORRIDOR TELEMATICS ACTIVE',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.darkSplashBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('AP 26 DISTRICTS', style: TextStyle(color: AppColors.yellow, fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                  ),

                  // Hearse Marker Overlay
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.darkSplashBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.yellow),
                          ),
                          child: const Text('AP 39 TE 1080 (58 km/h)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(height: 4),
                        const Icon(Icons.navigation_rounded, color: AppColors.yellow, size: 28),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Ping Interval: 10s • Accuracy: ±2m',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(6)),
                          child: const Text('Zoom: Statewide', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((f) {
                        final isSel = _selectedFilter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: isSel,
                            selectedColor: AppColors.darkSplashBg,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            backgroundColor: Colors.white,
                            onSelected: (val) {
                              if (val) setState(() => _selectedFilter = f);
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
                      hintText: 'Search Reg No or GPS location...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Real-Time Telematics Feed (${filteredList.length} Active)',
                    style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 14.5),
                  ),
                  const SizedBox(height: 10),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final statusColor = _getStatusColor(item['status']);

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
                                Expanded(
                                  child: Text(
                                    item['regNo'],
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.darkSplashBg),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(radius: 3, backgroundColor: statusColor),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${item['status']} (${item['speed']})',
                                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 10.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 14, color: AppColors.error),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item['location'],
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Coords: ${item['coordinates']} • Updated ${item['lastPing']}',
                              style: AppTypography.caption(color: AppColors.textSecondary).copyWith(fontSize: 10.5),
                            ),
                            const SizedBox(height: 8),
                            const Divider(height: 1),
                            const SizedBox(height: 8),

                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  'Freezer: ${item['freezer']}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.info),
                                ),
                                TextButton.icon(
                                  onPressed: () => _showRoutePlayback(item['regNo']),
                                  icon: const Icon(Icons.history_rounded, size: 15),
                                  label: const Text('PLAYBACK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.darkSplashBg,
                                    visualDensity: VisualDensity.compact,
                                  ),
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
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final radarPaint = Paint()
      ..color = AppColors.success.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 40, radarPaint);
    canvas.drawCircle(center, 80, radarPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
