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

class LiveCorridorScreen extends StatefulWidget {
  const LiveCorridorScreen({super.key});

  @override
  State<LiveCorridorScreen> createState() => _LiveCorridorScreenState();
}

class _LiveCorridorScreenState extends State<LiveCorridorScreen> {
  int _activeStep = 3; // 0-based: 3 is "En Route"
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;

  Map<String, dynamic> _tripData = {};
  List<Map<String, dynamic>> _milestones = [];

  @override
  void initState() {
    super.initState();
    _loadActiveTrip();
  }

  Future<void> _loadActiveTrip() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiConstants.activeTrip);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : null;
        if (data != null) {
          final milList = (data['milestones'] ?? data['stages'] ?? []) as List;
          setState(() {
            _tripData = {
              'caseNo': data['case_no'] ?? data['caseNo'] ?? 'Case #DC-2026-0921',
              'deceased': data['deceased_name'] ?? data['deceased'] ?? 'Late P. Sambasiva Rao (Age 68, Male)',
              'startLocation': data['start_location'] ?? 'GGH Guntur',
              'endLocation': data['end_location'] ?? 'Tenali Residence',
              'distance': data['distance'] ?? '34.2 KM',
              'remaining': data['remaining'] ?? '12.8 KM (Est. 18 mins)',
              'temp': data['freezer_temp'] ?? '3.8°C',
              'speed': data['speed'] ?? '54 km/h',
              'vehicle': data['vehicle_no'] ?? 'AP 39 TE 1080',
              'attendant': data['attendant'] ?? 'Ch. Venkata Rao (Son)',
            };
            if (milList.isNotEmpty) {
              _milestones = milList.map<Map<String, dynamic>>((m) {
                return {
                  'title': m['title'] ?? 'Milestone',
                  'time': m['time'] ?? '11:00 AM',
                  'location': m['location'] ?? 'Checkpoint',
                  'done': m['done'] ?? false,
                  'isCurrent': m['is_current'] ?? m['isCurrent'] ?? false,
                };
              }).toList();
            } else {
              _getDefaultMilestones();
            }
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _tripData = {
          'caseNo': 'Case #DC-2026-0921',
          'deceased': 'Late P. Sambasiva Rao (Age 68, Male)',
          'startLocation': 'GGH Guntur',
          'endLocation': 'Tenali Residence',
          'distance': '34.2 KM',
          'remaining': '12.8 KM (Est. 18 mins)',
          'temp': '3.8°C',
          'speed': '54 km/h',
          'vehicle': 'AP 39 TE 1080',
          'attendant': 'Ch. Venkata Rao (Son)',
        };
        _getDefaultMilestones();
        _isLoading = false;
      });
    }
  }

  void _getDefaultMilestones() {
    _milestones = [
      {
        'title': 'Dispatch Authorized',
        'time': '10:15 AM',
        'location': 'District Emergency Control Room, Guntur',
        'done': true,
      },
      {
        'title': 'Mortuary Pickup & Cabin Placement',
        'time': '10:38 AM',
        'location': 'GGH Guntur Mortuary Wing',
        'done': true,
      },
      {
        'title': 'Transit Exit & Highway Clearance',
        'time': '11:00 AM',
        'location': 'Guntur City Bypass, NH-16',
        'done': true,
      },
      {
        'title': 'Corridor Transit In-Progress',
        'time': '11:24 AM (Current)',
        'location': 'Tenali Main Road, KM 22',
        'done': true,
        'isCurrent': true,
      },
      {
        'title': 'Destination Handover & Certificate Sign-off',
        'time': 'Est. 11:45 AM',
        'location': 'Tenali Municipal Residence',
        'done': false,
      },
    ];
  }

  void _advanceMilestone() async {
    if (_activeStep < _milestones.length - 1) {
      setState(() {
        _activeStep++;
        _milestones[_activeStep]['done'] = true;
        _milestones[_activeStep]['isCurrent'] = true;
        _milestones[_activeStep - 1]['isCurrent'] = false;
      });

      try {
        await _apiClient.post(ApiConstants.activeTrip, data: {
          'active_step': _activeStep,
          'stage': _milestones[_activeStep]['title'],
        });
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transit Stage Updated: ${_milestones[_activeStep]['title']}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mission Completed. Handover documentation signed.'),
          backgroundColor: AppColors.roleAdmin,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final userRole = currentUser?.currentRoleEnum ?? UserRole.driver;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      drawer: AppDrawer(
        role: userRole,
        userId: currentUser?.phoneNumber ?? 'User',
        scope: currentUser?.district ?? 'Guntur District',
        currentRoute: '/beneficiary/corridor',
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentRoute: '/beneficiary/corridor',
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
              'Live Transit Corridor',
              style: AppTypography.title(color: Colors.white, fontWeight: FontWeight.w700).copyWith(fontSize: 16),
            ),
            Text(
              'Statewide Hearse Telematics • Mission Active',
              style: AppTypography.caption(color: Colors.white70).copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh GPS & Freezer Ping',
            onPressed: _loadActiveTrip,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadActiveTrip,
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
                          // Active Mission Header Banner
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.darkSplashBg, AppColors.midSplashBg],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkSplashBg.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.brightMagenta.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.brightMagenta),
                                      ),
                                      child: const Text(
                                        'ACTIVE CORRIDOR MISSION',
                                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.success),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.fiber_manual_record, color: AppColors.success, size: 10),
                                          SizedBox(width: 4),
                                          Text(
                                            'GPS LIVE',
                                            style: TextStyle(color: AppColors.success, fontSize: 10.5, fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                                      child: const Icon(Icons.airline_seat_flat_rounded, color: AppColors.yellow, size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _tripData['caseNo'] ?? 'Case #DC-2026-0921',
                                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _tripData['deceased'] ?? 'Late P. Sambasiva Rao',
                                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(color: Colors.white24, height: 1),
                                const SizedBox(height: 14),

                                // Route Progress
                                Row(
                                  children: [
                                    const Icon(Icons.local_hospital_rounded, color: AppColors.yellow, size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _tripData['startLocation'] ?? 'GGH Guntur',
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_rounded, color: Colors.white60, size: 16),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.home_work_rounded, color: AppColors.success, size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _tripData['endLocation'] ?? 'Tenali Residence',
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Total Distance: ${_tripData['distance']} • Remaining: ${_tripData['remaining']}',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Real-Time Telematics Strip
                          Row(
                            children: [
                              // Deep Freezer
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.ac_unit_rounded, size: 16, color: AppColors.info),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'FREEZER TEMP',
                                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(_tripData['temp'] ?? '3.8°C', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.info)),
                                      const SizedBox(height: 2),
                                      Text('Range: 2°C - 8°C (Normal)', style: TextStyle(fontSize: 9, color: AppColors.success, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Speed & Ignition
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.speed_rounded, size: 16, color: AppColors.orange),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'SPEED',
                                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(_tripData['speed'] ?? '54 km/h', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                      const SizedBox(height: 2),
                                      Text('Ignition: ON • Fuel: 72%', style: TextStyle(fontSize: 9, color: AppColors.success, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Vehicle ID
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.commute_rounded, size: 16, color: AppColors.brightMagenta),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'HEARSE VAN',
                                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(_tripData['vehicle'] ?? 'AP 39 TE 1080', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary), maxLines: 1),
                                      const SizedBox(height: 2),
                                      Text('Force Trax Cruiser', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Citizen Attendant Card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.roleDriver.withValues(alpha: 0.12),
                                  child: const Icon(Icons.person_rounded, color: AppColors.roleDriver, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _tripData['attendant'] ?? 'Ch. Venkata Rao (Son)',
                                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Family Attendant • Traveling in Cabin',
                                        style: AppTypography.caption(color: AppColors.textSecondary).copyWith(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton.filled(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Connecting phone call to Citizen Attendant: +91 98480 22338'),
                                        backgroundColor: AppColors.success,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.call_rounded, size: 18),
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Transit Milestones
                          Text(
                            'Corridor Milestones & Handover',
                            style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Chain-of-custody verification points mandated by AP Health Dept:',
                            style: AppTypography.caption(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 12),

                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _milestones.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final m = _milestones[index];
                              final isDone = m['done'] == true;
                              final isCurrent = m['isCurrent'] == true;

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isCurrent ? AppColors.yellow.withValues(alpha: 0.08) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isCurrent
                                        ? AppColors.yellow
                                        : (isDone ? AppColors.success.withValues(alpha: 0.4) : Colors.grey.shade200),
                                    width: isCurrent ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isDone
                                            ? AppColors.success
                                            : (isCurrent ? AppColors.yellow : Colors.grey.shade300),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isDone ? Icons.check : (isCurrent ? Icons.navigation_rounded : Icons.circle),
                                        size: 12,
                                        color: isDone ? Colors.white : (isCurrent ? Colors.black87 : Colors.white),
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
                                              Expanded(
                                                child: Text(
                                                  m['title'],
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w700,
                                                    color: isCurrent ? AppColors.darkSplashBg : AppColors.textPrimary,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                m['time'],
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: isCurrent ? AppColors.darkSplashBg : AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            m['location'],
                                            style: AppTypography.caption(color: AppColors.textSecondary).copyWith(fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // Advance Milestone Action Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _advanceMilestone,
                              icon: const Icon(Icons.flag_rounded, color: Colors.white),
                              label: Text(
                                _activeStep < _milestones.length - 1 ? 'UPDATE CORRIDOR STAGE' : 'FINALIZE & ARCHIVE MISSION',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brightMagenta,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
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
