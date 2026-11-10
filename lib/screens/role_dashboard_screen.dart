import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/api_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/dashboard_stats_model.dart';
import '../models/user_role.dart';
import '../providers/auth_provider.dart';
import '../services/dashboard_service.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/bavya_footer.dart';
import '../widgets/brand_logo.dart';
import 'beneficiary/beneficiary_history_screen.dart';
import 'fleet/offroad_management_screen.dart';
import 'fleet/vehicle_management_screen.dart';
import 'login_screen.dart';
import 'main/fuel_intel_screen.dart';
import 'main/reports_screen.dart';
import 'management/users_screen.dart';

class RoleDashboardScreen extends StatefulWidget {
  final UserRole role;
  final String userId;
  final String scope;

  const RoleDashboardScreen({
    super.key,
    required this.role,
    required this.userId,
    required this.scope,
  });

  @override
  State<RoleDashboardScreen> createState() => _RoleDashboardScreenState();
}

class _RoleDashboardScreenState extends State<RoleDashboardScreen> {
  final DashboardService _dashboardService = DashboardService();

  bool _isLoading = true;
  String _selectedPeriod = 'Previous Day';
  bool _showZmDetails = false;
  String? _apiErrorMessage;

  DashboardStatsModel _dashboardData = DashboardStatsModel.empty();

  DateTime _selectedLocationDate = DateTime.now();
  bool _isLoadingLocations = false;
  List<TripLocationItem>? _customDateLocations;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _filterTripLocationsDate(DateTime pickedDate) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final projectId = (currentUser != null && currentUser.projects.isNotEmpty)
        ? currentUser.projects.first.id
        : ApiConstants.mahaprastanamProjectId;

    setState(() {
      _selectedLocationDate = pickedDate;
      _isLoadingLocations = true;
    });

    if (_isToday(pickedDate) && _dashboardData.tripLocationsList.isNotEmpty) {
      setState(() {
        _customDateLocations = null;
        _isLoadingLocations = false;
      });
      return;
    }

    try {
      final locs = await _dashboardService.fetchTripLocationsForDate(
        projectId: projectId,
        date: pickedDate,
      );
      if (mounted) {
        setState(() {
          _customDateLocations = locs;
          _isLoadingLocations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocations = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _apiErrorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      final projectId = (currentUser != null && currentUser.projects.isNotEmpty)
          ? currentUser.projects.first.id
          : ApiConstants.mahaprastanamProjectId;

      // Invoke the proper live dashboard API endpoint according to role & period
      final liveStats = await _dashboardService.fetchDashboardData(
        role: widget.role,
        projectId: projectId,
        period: _selectedPeriod,
      );

      if (mounted) {
        setState(() {
          _dashboardData = liveStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[ROLE_DASHBOARD] Live API fetch error: $e');
      if (mounted) {
        setState(() {
          _apiErrorMessage = 'Failed to refresh live dashboard metrics: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to end your current session and sign out of Mahaprastanam Operations?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && mounted) {
      await _executeLogout();
    }
  }

  Future<void> _executeLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.logout();
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading dialog

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = widget.role == UserRole.admin;
    final isWide = MediaQuery.of(context).size.width > 900;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: AppDrawer(
        role: widget.role,
        userId: widget.userId,
        scope: widget.scope,
        currentRoute: '/dashboard',
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentRoute: '/dashboard',
        role: widget.role,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Navigation Menu',
            icon: const Icon(Icons.menu_rounded, color: AppColors.ink),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Operations Suite', style: AppTypography.title(color: AppColors.ink)),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            onPressed: _confirmSignOut,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardStats,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BavyaAccentLine(height: 3),
                      const SizedBox(height: 16),

                      // Header Banner
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSuperAdmin
                                      ? 'SUPER ADMIN • UNRESTRICTED ACCESS'
                                      : '${widget.role.displayName.toUpperCase()} • ${widget.scope.toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.brightMagenta,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Fleet Operations Command',
                                  style: AppTypography.h1(color: AppColors.ink).copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Refresh Live API',
                            icon: const Icon(Icons.refresh_rounded, color: AppColors.purple),
                            onPressed: _loadDashboardStats,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_apiErrorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: AppColors.danger, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _apiErrorMessage!,
                                  style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // SECTION 1: VEHICLE STATUS
                      _buildSectionHeader('VEHICLE STATUS'),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: screenWidth > 750 ? 4 : 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.1,
                        children: [
                          _buildWebDashboardCard(
                            title: 'NO. OF VEHICLES',
                            value: '${_dashboardData.vehicleStatus.totalVehicles}',
                            icon: Icons.local_shipping_rounded,
                            iconColor: AppColors.orange,
                            accentColor: AppColors.orange,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleManagementScreen())),
                          ),
                          _buildWebDashboardCard(
                            title: 'NO. OF ON-ROAD',
                            value: '${_dashboardData.vehicleStatus.onRoadVehicles}',
                            icon: Icons.show_chart_rounded,
                            iconColor: AppColors.brightMagenta,
                            accentColor: AppColors.brightMagenta,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleManagementScreen())),
                          ),
                          _buildWebDashboardCard(
                            title: 'NO. OF OFF-ROAD',
                            value: '${_dashboardData.vehicleStatus.offRoadVehicles}',
                            icon: Icons.warning_amber_rounded,
                            iconColor: AppColors.amber,
                            accentColor: AppColors.amber,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OffroadManagementScreen())),
                          ),
                          _buildWebDashboardCard(
                            title: 'BACKUP VEHICLES',
                            value: '${_dashboardData.vehicleStatus.backupVehicles}',
                            icon: Icons.airport_shuttle_rounded,
                            iconColor: AppColors.success,
                            accentColor: AppColors.success,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleManagementScreen())),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // SECTION 2: PREVIOUS DAY PERFORMANCE
                      _buildSectionHeader('PREVIOUS DAY PERFORMANCE'),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: screenWidth > 850 ? 5 : (screenWidth > 550 ? 3 : 2),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.0,
                        children: [
                          _buildWebDashboardCard(
                            title: 'PREVIOUS DAY TOTAL TRIPS',
                            value: '${_dashboardData.previousDay.trips}',
                            icon: Icons.alt_route_rounded,
                            iconColor: AppColors.purple,
                            accentColor: AppColors.purple,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeneficiaryHistoryScreen())),
                          ),
                          _buildWebDashboardCard(
                            title: 'PREVIOUS DAY CASE RUN KM',
                            value: _dashboardData.previousDay.caseRunKm,
                            icon: Icons.directions_car_rounded,
                            iconColor: AppColors.success,
                            accentColor: AppColors.success,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleManagementScreen())),
                          ),
                          _buildWebDashboardCard(
                            title: 'PREVIOUS DAY FUEL RUN KM',
                            value: _dashboardData.previousDay.fuelRunKm,
                            icon: Icons.speed_rounded,
                            iconColor: AppColors.brightMagenta,
                            accentColor: AppColors.brightMagenta,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleManagementScreen())),
                          ),
                          _buildWebDashboardCard(
                            title: 'PREVIOUS DAY FUEL',
                            value: _dashboardData.previousDay.fuelLiters,
                            icon: Icons.local_gas_station_rounded,
                            iconColor: AppColors.purple,
                            accentColor: AppColors.purple,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FuelIntelScreen())),
                          ),
                          _buildWebDashboardCard(
                            title: 'PREVIOUS DAY AVG MILEAGE',
                            value: _dashboardData.previousDay.avgMileage,
                            icon: Icons.bar_chart_rounded,
                            iconColor: AppColors.info,
                            accentColor: AppColors.info,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // SECTION 3: MONTHLY PERFORMANCE
                      _buildSectionHeader('MONTHLY PERFORMANCE'),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: screenWidth > 850 ? 5 : (screenWidth > 550 ? 3 : 2),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 2.0,
                        children: [
                          _buildWebDashboardCard(
                            title: 'MONTH TOTAL TRIPS',
                            value: '${_dashboardData.monthly.trips}',
                            icon: Icons.timeline_rounded,
                            iconColor: AppColors.success,
                            accentColor: AppColors.success,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeneficiaryHistoryScreen())),
                          ),
                          _buildWebDashboardCard(
                            title: 'MONTH CASE RUN KM',
                            value: _dashboardData.monthly.caseRunKm,
                            icon: Icons.map_rounded,
                            iconColor: AppColors.brightMagenta,
                            accentColor: AppColors.brightMagenta,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleManagementScreen())),
                          ),
                          _buildWebDashboardCard(
                            title: 'TOTAL FUEL RUN KM',
                            value: _dashboardData.monthly.fuelRunKm,
                            icon: Icons.shutter_speed_rounded,
                            iconColor: AppColors.purple,
                            accentColor: AppColors.purple,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleManagementScreen())),
                          ),
                          _buildWebDashboardCard(
                            title: 'FUEL CONSUMPTION (LITERS)',
                            value: _dashboardData.monthly.fuelLiters,
                            icon: Icons.local_gas_station_rounded,
                            iconColor: AppColors.amber,
                            accentColor: AppColors.amber,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FuelIntelScreen())),
                          ),
                          _buildWebDashboardCard(
                            title: 'AVG MILEAGE (KMPL)',
                            value: _dashboardData.monthly.avgMileage,
                            icon: Icons.assessment_rounded,
                            iconColor: AppColors.brightMagenta,
                            accentColor: AppColors.brightMagenta,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Bottom ZM Details & Period Toggle Bar
                      _buildBottomDashboardBar(),
                      const SizedBox(height: 16),

                      // ZM DETAILS EXPANDABLE SECTION
                      if (_showZmDetails) ...[
                        Text(
                          'Zonal Manager (ZM) Performance Breakdown',
                          style: AppTypography.h2(color: AppColors.ink).copyWith(fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        if (_dashboardData.zmList.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Center(
                              child: Text(
                                'No zonal manager performance logs recorded for this active period.',
                                style: TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _dashboardData.zmList.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final zm = _dashboardData.zmList[index];
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 4,
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
                                        const Text('ZONAL MANAGER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: 0.5)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.brightMagenta.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(zm.zone, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.brightMagenta)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(zm.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.ink)),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(child: _buildZmMetricMiniCard('TRIPS', zm.trips, Icons.alt_route_rounded)),
                                        const SizedBox(width: 6),
                                        Expanded(child: _buildZmMetricMiniCard('CASE RUN KM', zm.caseRunKm, Icons.directions_car_rounded)),
                                        const SizedBox(width: 6),
                                        Expanded(child: _buildZmMetricMiniCard('FUEL RUN KM', zm.fuelRunKm, Icons.speed_rounded)),
                                        const SizedBox(width: 6),
                                        Expanded(child: _buildZmMetricMiniCard('FUEL (LITERS)', zm.fuelLiters, Icons.local_gas_station_rounded)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 22),
                      ],

                      // SECTION 4: MAHA PRASTHANAM OPERATIONAL SUMMARY HEADING
                      Text(
                        'Maha Prasthanam Operational Summary',
                        style: AppTypography.h2(color: AppColors.ink).copyWith(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),

                      // Operational Summary Cards Grid (6 cards)
                      GridView.count(
                        crossAxisCount: screenWidth > 900 ? 3 : (screenWidth > 600 ? 2 : 1),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: screenWidth > 900 ? 2.6 : (screenWidth > 600 ? 2.4 : 2.5),
                        children: [
                          _buildOpSummaryCard(
                            title: 'TODAY TRIPS',
                            titleColor: const Color(0xFF64748B),
                            value: '${_dashboardData.opSummary.todayTrips}',
                            icon: Icons.check_rounded,
                            iconColor: const Color(0xFF0F172A),
                            iconBgColor: const Color(0xFFF1F5F9),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeneficiaryHistoryScreen())),
                          ),
                          _buildCallCenterCard(
                            'CALL CENTER EXECUTIVES',
                            '${_dashboardData.opSummary.callCenterExecutives}',
                            present: _dashboardData.opSummary.ccePresent,
                            absent: _dashboardData.opSummary.cceAbsent,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersScreen())),
                          ),
                          _buildOpSummaryCard(
                            title: 'TODAY COVID 19 CASES',
                            titleColor: const Color(0xFF0D9488),
                            value: '${_dashboardData.opSummary.todayCovidCases}',
                            icon: Icons.monitor_heart_outlined,
                            iconColor: const Color(0xFF0D9488),
                            iconBgColor: const Color(0xFFCCFBF1),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                          ),
                          _buildOpSummaryCard(
                            title: 'TOTAL COVID 19 CASES',
                            titleColor: const Color(0xFF4F46E5),
                            value: '${_dashboardData.opSummary.totalCovidCases}',
                            icon: Icons.trending_up_rounded,
                            iconColor: const Color(0xFF4F46E5),
                            iconBgColor: const Color(0xFFEEF2FF),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                          ),
                          _buildOpSummaryCard(
                            title: 'CONSOLIDATE TRIPS',
                            titleColor: const Color(0xFF2563EB),
                            value: '${_dashboardData.opSummary.consolidateTrips}',
                            icon: Icons.bar_chart_rounded,
                            iconColor: const Color(0xFF2563EB),
                            iconBgColor: const Color(0xFFEFF6FF),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeneficiaryHistoryScreen())),
                          ),
                          _buildOpSummaryCard(
                            title: 'PREVIOUS MONTH TRIPS',
                            titleColor: const Color(0xFF64748B),
                            value: '${_dashboardData.opSummary.previousMonthTrips}',
                            icon: Icons.access_time_rounded,
                            iconColor: const Color(0xFF64748B),
                            iconBgColor: const Color(0xFFF1F5F9),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeneficiaryHistoryScreen())),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // SECTION 5: CALL CENTER DATA & TRIP LOCATIONS DATA
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildCallCenterDataTable()),
                            const SizedBox(width: 14),
                            Expanded(flex: 2, child: _buildTripLocationsTable()),
                          ],
                        )
                      else ...[
                        _buildCallCenterDataTable(),
                        const SizedBox(height: 18),
                        _buildTripLocationsTable(),
                      ],
                      const SizedBox(height: 26),

                      // Sign Out Action Button
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: _confirmSignOut,
                          icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
                          label: const Text(
                            'End Duty & Sign Out',
                            style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w800, fontSize: 13.5),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.danger),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Center(child: BavyaFooter()),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: 0.8),
    );
  }

  Widget _buildWebDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color accentColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          gradient: LinearGradient(
            colors: [Colors.white, accentColor.withValues(alpha: 0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.ink),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZmMetricMiniCard(String label, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.purple, size: 14),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: AppColors.muted), textAlign: TextAlign.center, maxLines: 1),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.ink), textAlign: TextAlign.center, maxLines: 1),
        ],
      ),
    );
  }

  Widget _buildOpSummaryCard({
    required String title,
    required Color titleColor,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallCenterCard(
    String title,
    String value, {
    required int present,
    required int absent,
    VoidCallback? onTap,
  }) {
    final formattedVal = int.tryParse(value) != null ? value.padLeft(2, '0') : value;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedVal,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'CCE Present: $present',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'CCE Absent: $absent',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.people_outline_rounded, color: Color(0xFF4F46E5), size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallCenterDataTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1D4ED8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'CALL CENTER DATA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_dashboardData.callCenterList.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_dashboardData.callCenterList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No call center logs reported for this active period.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _dashboardData.callCenterList.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final item = _dashboardData.callCenterList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 105,
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_outline_rounded, color: Colors.white, size: 18),
                            const SizedBox(height: 3),
                            Text(
                              item.name.toUpperCase(),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'INBOUND',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF94A3B8),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.inbound}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'OUTBOUND',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF94A3B8),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.outbound}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'DURATION',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF94A3B8),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.duration,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFF94A3B8), size: 16),
                          Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8), size: 16),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTripLocationsTable() {
    final isCurrentDay = _isToday(_selectedLocationDate);
    final dateDisplay = isCurrentDay
        ? (_dashboardData.tripLocationsDate.isNotEmpty
            ? '${_dashboardData.tripLocationsDate} (Today)'
            : '${_formatDate(_selectedLocationDate)} (Today)')
        : _formatDate(_selectedLocationDate);
    final locations = _customDateLocations ?? _dashboardData.tripLocationsList;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF088395),
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TRIP LOCATIONS DATA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedLocationDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            _filterTripLocationsDate(picked);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Date: $dateDisplay',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white.withValues(alpha: 0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isCurrentDay)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedLocationDate = DateTime.now();
                              _customDateLocations = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              'Today',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${locations.length} Locations',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoadingLocations)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF088395)),
                  ),
                ),
              ),
            )
          else if (locations.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No hospital trip clusters logged for this active period.',
                  style: TextStyle(color: AppColors.muted, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'LOCATION',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5),
                  ),
                  Text(
                    'TRIP COUNT',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 380),
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: locations.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final loc = locations[index];
                    final hasTrips = loc.hasTrips;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: hasTrips ? const Color(0xFFF2FBF7) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              loc.location,
                              style: TextStyle(
                                fontWeight: hasTrips ? FontWeight.w900 : FontWeight.w800,
                                fontSize: 11.5,
                                color: hasTrips ? const Color(0xFF005A43) : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.5),
                            decoration: BoxDecoration(
                              color: hasTrips ? const Color(0xFF00966B) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: hasTrips ? null : Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: hasTrips
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF00966B).withValues(alpha: 0.25),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1.5),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              loc.count,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: hasTrips ? FontWeight.w900 : FontWeight.w700,
                                color: hasTrips ? Colors.white : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomDashboardBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          OutlinedButton(
            onPressed: () {
              setState(() {
                _showZmDetails = !_showZmDetails;
              });
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: _showZmDetails ? AppColors.purple.withValues(alpha: 0.1) : Colors.transparent,
              side: BorderSide(color: _showZmDetails ? AppColors.purple : Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              _showZmDetails ? 'Hide ZM Details' : 'ZM Details',
              style: TextStyle(color: _showZmDetails ? AppColors.purple : AppColors.ink, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_selectedPeriod != 'Previous Day') {
                      setState(() => _selectedPeriod = 'Previous Day');
                      _loadDashboardStats();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _selectedPeriod == 'Previous Day' ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _selectedPeriod == 'Previous Day'
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                          : [],
                    ),
                    child: Text(
                      'Previous Day',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _selectedPeriod == 'Previous Day' ? AppColors.ink : AppColors.muted,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_selectedPeriod != 'Monthly') {
                      setState(() => _selectedPeriod = 'Monthly');
                      _loadDashboardStats();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _selectedPeriod == 'Monthly' ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: _selectedPeriod == 'Monthly'
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                          : [],
                    ),
                    child: Text(
                      'Monthly',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _selectedPeriod == 'Monthly' ? AppColors.ink : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
