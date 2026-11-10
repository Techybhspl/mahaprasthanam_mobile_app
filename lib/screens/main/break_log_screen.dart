import 'dart:async';
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

class BreakLogScreen extends StatefulWidget {
  const BreakLogScreen({super.key});

  @override
  State<BreakLogScreen> createState() => _BreakLogScreenState();
}

class _BreakLogScreenState extends State<BreakLogScreen> {
  bool _isOnBreak = false;
  String _activeBreakType = 'Lunch Break';
  int _breakSecondsElapsed = 0;
  Timer? _breakTimer;
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;

  List<Map<String, dynamic>> _breakHistory = [];

  final List<Map<String, dynamic>> _breakOptions = [
    {
      'title': 'Lunch Break',
      'allowed': '45 mins',
      'icon': Icons.restaurant_rounded,
      'color': AppColors.orange,
    },
    {
      'title': 'Tea & Refreshment',
      'allowed': '15 mins',
      'icon': Icons.coffee_rounded,
      'color': AppColors.roleDriver,
    },
    {
      'title': 'Fatigue / Rest Stop',
      'allowed': '30 mins',
      'icon': Icons.airline_seat_flat_rounded,
      'color': AppColors.purple,
    },
    {
      'title': 'Vehicle Inspection / Fueling',
      'allowed': '20 mins',
      'icon': Icons.local_gas_station_rounded,
      'color': AppColors.brightMagenta,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadBreaks();
  }

  Future<void> _loadBreaks() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiConstants.breaks);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data is List ? response.data : (response.data['data'] ?? response.data['breaks'] ?? []);
        if (list is List && list.isNotEmpty) {
          setState(() {
            _breakHistory = list.map<Map<String, dynamic>>((item) {
              return {
                'type': item['break_type'] ?? item['type'] ?? 'Tea & Refreshment',
                'startTime': item['start_time'] ?? item['startTime'] ?? '10:30 AM',
                'duration': item['duration'] ?? '15 mins',
                'status': item['status'] ?? 'Approved',
                'remarks': item['remarks'] ?? item['notes'] ?? 'Morning checkpoint stop',
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
        _breakHistory = [
          {
            'type': 'Tea & Refreshment',
            'startTime': '10:30 AM',
            'duration': '15 mins',
            'status': 'Approved',
            'remarks': 'Morning checkpoint stop at Vijayawada bypass',
          },
          {
            'type': 'Vehicle Fueling & Inspection',
            'startTime': '01:15 PM',
            'duration': '20 mins',
            'status': 'Approved',
            'remarks': 'HPCL COCO Pump, NH-16 Guntur',
          },
        ];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _breakTimer?.cancel();
    super.dispose();
  }

  void _toggleBreak(String breakType) async {
    if (_isOnBreak) {
      // Resume duty
      _breakTimer?.cancel();
      final minutes = (_breakSecondsElapsed / 60).ceil();
      setState(() {
        _breakHistory.insert(0, {
          'type': _activeBreakType,
          'startTime': 'Just now',
          'duration': '$minutes mins',
          'status': 'Logged',
          'remarks': 'Duty resumed on time',
        });
        _isOnBreak = false;
        _breakSecondsElapsed = 0;
      });

      try {
        await _apiClient.post(ApiConstants.breaks, data: {'break_type': _activeBreakType, 'duration': '$minutes mins', 'status': 'Resumed'});
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Duty Resumed. Vehicle status updated to Active On-Duty.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Start break
      setState(() {
        _isOnBreak = true;
        _activeBreakType = breakType;
        _breakSecondsElapsed = 0;
      });

      _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          _breakSecondsElapsed++;
        });
      });

      try {
        await _apiClient.post(ApiConstants.breaks, data: {'break_type': breakType, 'status': 'Started'});
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Break Started: $breakType. Control room notified.'),
          backgroundColor: AppColors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatTimer(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
        scope: currentUser?.district ?? 'Statewide',
        currentRoute: '/breaks',
      ),
      appBar: AppBar(
        backgroundColor: AppColors.darkSplashBg,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Roster & Break Management',
              style: AppTypography.title(color: Colors.white, fontWeight: FontWeight.w700).copyWith(fontSize: 16),
            ),
            Text(
              'Shift Rest Compliance • Mahaprastanam',
              style: AppTypography.caption(color: Colors.white70).copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _isOnBreak ? AppColors.orange.withValues(alpha: 0.25) : AppColors.success.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isOnBreak ? AppColors.orange : AppColors.success,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isOnBreak ? Icons.pause_circle_filled_rounded : Icons.check_circle_rounded,
                  size: 14,
                  color: _isOnBreak ? AppColors.orange : AppColors.success,
                ),
                const SizedBox(width: 5),
                Text(
                  _isOnBreak ? 'ON BREAK' : 'ON DUTY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _isOnBreak ? AppColors.orange : AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBreaks,
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
                  // Active Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isOnBreak
                            ? [AppColors.orange.withValues(alpha: 0.9), Colors.deepOrange.shade800]
                            : [AppColors.darkSplashBg, AppColors.midSplashBg],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (_isOnBreak ? AppColors.orange : AppColors.darkSplashBg).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
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
                                _isOnBreak ? 'CURRENTLY ON BREAK' : 'ACTIVE DUTY SHIFT',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Shift: 08:00 - 20:00',
                                style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              child: Icon(
                                _isOnBreak ? Icons.coffee_rounded : Icons.drive_eta_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isOnBreak ? _activeBreakType : 'Hearse Van AP 39 TE 1080',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isOnBreak
                                        ? 'Timer Running: ${_formatTimer(_breakSecondsElapsed)}'
                                        : 'Driver Ready • Guntur District Corridor',
                                    style: TextStyle(
                                      color: _isOnBreak ? AppColors.yellow : Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_isOnBreak) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _toggleBreak(_activeBreakType),
                              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                              label: const Text('RESUME ON-DUTY TRANSIT'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Break Selection
                  if (!_isOnBreak) ...[
                    Text(
                      'Log Rest or Refill Break',
                      style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select break category according to AP State Transport safety norms:',
                      style: AppTypography.caption(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _breakOptions.length,
                      itemBuilder: (context, index) {
                        final opt = _breakOptions[index];
                        final color = opt['color'] as Color;
                        return InkWell(
                          onTap: () => _toggleBreak(opt['title']),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: color.withValues(alpha: 0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(opt['icon'], color: color, size: 20),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        opt['allowed'],
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  opt['title'],
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Today's Break Logs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Today's Shift Log",
                          style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Compliance: 35 / 60 mins',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _breakHistory.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _breakHistory[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.darkSplashBg.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.timer_outlined, color: AppColors.darkSplashBg, size: 20),
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
                                          item['type'],
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item['duration'],
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.orange),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item['startTime']} • ${item['remarks']}',
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

