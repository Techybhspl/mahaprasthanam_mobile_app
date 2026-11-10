import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_vector_icons.dart';
import '../models/user_role.dart';
import '../providers/auth_provider.dart';
import '../screens/approvals/submissions_approval_screen.dart';
import '../screens/beneficiary/beneficiary_form_screen.dart';
import '../screens/beneficiary/live_corridor_screen.dart';
import '../screens/fleet/fleet_maintenance_screen.dart';
import '../screens/fleet/gps_tracking_screen.dart';
import '../screens/fleet/offroad_management_screen.dart';
import '../screens/fleet/vehicle_management_screen.dart';
import '../screens/main/break_log_screen.dart';
import '../screens/main/fill_report_screen.dart';
import '../screens/main/fuel_intel_screen.dart';
import '../screens/main/reports_screen.dart';
import '../screens/management/users_screen.dart';

/// Role-Tailored Item Specification for Bottom Navigation Bar
class BottomNavItem {
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String route;
  final WidgetBuilder screenBuilder;

  const BottomNavItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.route,
    required this.screenBuilder,
  });
}

/// A modern, role-aware bottom navigation bar designed for field usability.
/// Provides high-frequency 4-5 destination access within the thumb-reach zone.
class AppBottomNavBar extends StatelessWidget {
  final String currentRoute;
  final UserRole? role;

  const AppBottomNavBar({
    super.key,
    required this.currentRoute,
    this.role,
  });

  List<BottomNavItem> _getItemsForRole(UserRole effectiveRole, bool isSuperAdmin) {
    if (isSuperAdmin || effectiveRole == UserRole.admin) {
      return [
        BottomNavItem(
          label: 'Dashboard',
          activeIcon: AppVectorIcons.dashboard.active,
          inactiveIcon: AppVectorIcons.dashboard.outline,
          route: '/dashboard',
          screenBuilder: (_) => const SizedBox.shrink(),
        ),
        BottomNavItem(
          label: 'Transit',
          activeIcon: AppVectorIcons.liveCorridor.active,
          inactiveIcon: AppVectorIcons.liveCorridor.outline,
          route: '/beneficiary/corridor',
          screenBuilder: (_) => const LiveCorridorScreen(),
        ),
        BottomNavItem(
          label: 'Fleet',
          activeIcon: AppVectorIcons.vehicleManagement.active,
          inactiveIcon: AppVectorIcons.vehicleManagement.outline,
          route: '/fleet/vehicles',
          screenBuilder: (_) => const VehicleManagementScreen(),
        ),
        BottomNavItem(
          label: 'Approvals',
          activeIcon: AppVectorIcons.submissions.active,
          inactiveIcon: AppVectorIcons.submissions.outline,
          route: '/submissions',
          screenBuilder: (_) => const SubmissionsApprovalScreen(),
        ),
        BottomNavItem(
          label: 'Users',
          activeIcon: AppVectorIcons.users.active,
          inactiveIcon: AppVectorIcons.users.outline,
          route: '/management/users',
          screenBuilder: (_) => const UsersScreen(),
        ),
      ];
    }

    switch (effectiveRole) {
      case UserRole.driver:
        return [
          BottomNavItem(
            label: 'Dashboard',
            activeIcon: AppVectorIcons.dashboard.active,
            inactiveIcon: AppVectorIcons.dashboard.outline,
            route: '/dashboard',
            screenBuilder: (_) => const SizedBox.shrink(),
          ),
          BottomNavItem(
            label: 'Intake',
            activeIcon: AppVectorIcons.beneficiaryIntake.active,
            inactiveIcon: AppVectorIcons.beneficiaryIntake.outline,
            route: '/beneficiary/new',
            screenBuilder: (_) => const BeneficiaryFormScreen(),
          ),
          BottomNavItem(
            label: 'Corridor',
            activeIcon: AppVectorIcons.liveCorridor.active,
            inactiveIcon: AppVectorIcons.liveCorridor.outline,
            route: '/beneficiary/corridor',
            screenBuilder: (_) => const LiveCorridorScreen(),
          ),
          BottomNavItem(
            label: 'Fill Report',
            activeIcon: AppVectorIcons.fillReport.active,
            inactiveIcon: AppVectorIcons.fillReport.outline,
            route: '/fill-report',
            screenBuilder: (_) => const FillReportScreen(),
          ),
          BottomNavItem(
            label: 'Break',
            activeIcon: AppVectorIcons.breakLog.active,
            inactiveIcon: AppVectorIcons.breakLog.outline,
            route: '/break',
            screenBuilder: (_) => const BreakLogScreen(),
          ),
        ];

      case UserRole.fleetManager:
      case UserRole.sfm:
      case UserRole.sfh:
        return [
          BottomNavItem(
            label: 'Dashboard',
            activeIcon: AppVectorIcons.dashboard.active,
            inactiveIcon: AppVectorIcons.dashboard.outline,
            route: '/dashboard',
            screenBuilder: (_) => const SizedBox.shrink(),
          ),
          BottomNavItem(
            label: 'Vehicles',
            activeIcon: AppVectorIcons.vehicleManagement.active,
            inactiveIcon: AppVectorIcons.vehicleManagement.outline,
            route: '/fleet/vehicles',
            screenBuilder: (_) => const VehicleManagementScreen(),
          ),
          BottomNavItem(
            label: 'Maintenance',
            activeIcon: AppVectorIcons.fleetMaintenance.active,
            inactiveIcon: AppVectorIcons.fleetMaintenance.outline,
            route: '/fleet/maintenance',
            screenBuilder: (_) => const FleetMaintenanceScreen(),
          ),
          BottomNavItem(
            label: 'Off-Road',
            activeIcon: AppVectorIcons.offroadManagement.active,
            inactiveIcon: AppVectorIcons.offroadManagement.outline,
            route: '/fleet/offroad',
            screenBuilder: (_) => const OffroadManagementScreen(),
          ),
          BottomNavItem(
            label: 'GPS Live',
            activeIcon: AppVectorIcons.gpsTracking.active,
            inactiveIcon: AppVectorIcons.gpsTracking.outline,
            route: '/fleet/gps',
            screenBuilder: (_) => const GpsTrackingScreen(),
          ),
        ];

      case UserRole.districtManager:
      case UserRole.spm:
      case UserRole.coo:
      case UserRole.zm:
      case UserRole.rm:
      case UserRole.boe:
        return [
          BottomNavItem(
            label: 'Dashboard',
            activeIcon: AppVectorIcons.dashboard.active,
            inactiveIcon: AppVectorIcons.dashboard.outline,
            route: '/dashboard',
            screenBuilder: (_) => const SizedBox.shrink(),
          ),
          BottomNavItem(
            label: 'Transit',
            activeIcon: AppVectorIcons.liveCorridor.active,
            inactiveIcon: AppVectorIcons.liveCorridor.outline,
            route: '/beneficiary/corridor',
            screenBuilder: (_) => const LiveCorridorScreen(),
          ),
          BottomNavItem(
            label: 'Fleet',
            activeIcon: AppVectorIcons.vehicleManagement.active,
            inactiveIcon: AppVectorIcons.vehicleManagement.outline,
            route: '/fleet/vehicles',
            screenBuilder: (_) => const VehicleManagementScreen(),
          ),
          BottomNavItem(
            label: 'Approvals',
            activeIcon: AppVectorIcons.submissions.active,
            inactiveIcon: AppVectorIcons.submissions.outline,
            route: '/submissions',
            screenBuilder: (_) => const SubmissionsApprovalScreen(),
          ),
          BottomNavItem(
            label: 'Reports',
            activeIcon: AppVectorIcons.reports.active,
            inactiveIcon: AppVectorIcons.reports.outline,
            route: '/reports',
            screenBuilder: (_) => const ReportsScreen(),
          ),
        ];

      default:
        return [
          BottomNavItem(
            label: 'Dashboard',
            activeIcon: AppVectorIcons.dashboard.active,
            inactiveIcon: AppVectorIcons.dashboard.outline,
            route: '/dashboard',
            screenBuilder: (_) => const SizedBox.shrink(),
          ),
          BottomNavItem(
            label: 'Transit',
            activeIcon: AppVectorIcons.liveCorridor.active,
            inactiveIcon: AppVectorIcons.liveCorridor.outline,
            route: '/beneficiary/corridor',
            screenBuilder: (_) => const LiveCorridorScreen(),
          ),
          BottomNavItem(
            label: 'Fleet',
            activeIcon: AppVectorIcons.vehicleManagement.active,
            inactiveIcon: AppVectorIcons.vehicleManagement.outline,
            route: '/fleet/vehicles',
            screenBuilder: (_) => const VehicleManagementScreen(),
          ),
          BottomNavItem(
            label: 'Fuel Intel',
            activeIcon: AppVectorIcons.fuelIntel.active,
            inactiveIcon: AppVectorIcons.fuelIntel.outline,
            route: '/fuel-intel',
            screenBuilder: (_) => const FuelIntelScreen(),
          ),
          BottomNavItem(
            label: 'Reports',
            activeIcon: AppVectorIcons.reports.active,
            inactiveIcon: AppVectorIcons.reports.outline,
            route: '/reports',
            screenBuilder: (_) => const ReportsScreen(),
          ),
        ];
    }
  }

  void _onTabTapped(BuildContext context, BottomNavItem item, UserRole effectiveRole) {
    if (item.route == currentRoute) return;

    if (item.route == '/dashboard') {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    final targetScreen = item.screenBuilder(context);

    if (currentRoute != '/dashboard') {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
          transitionDuration: const Duration(milliseconds: 140),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
          transitionDuration: const Duration(milliseconds: 140),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final effectiveRole = role ?? currentUser?.currentRoleEnum ?? UserRole.driver;
    final isSuperAdmin = (currentUser?.isSuperAdmin == true) || (effectiveRole == UserRole.admin);

    final items = _getItemsForRole(effectiveRole, isSuperAdmin);
    final accentColor = const Color(0xFF088395); // Maha Prasthanam signature teal

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: items.map((item) {
              final isSelected = item.route == currentRoute;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onTabTapped(context, item, effectiveRole),
                    splashColor: accentColor.withValues(alpha: 0.1),
                    highlightColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSelected ? accentColor.withValues(alpha: 0.12) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.inactiveIcon,
                              color: isSelected ? accentColor : const Color(0xFF64748B),
                              size: 21,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? accentColor : const Color(0xFF64748B),
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
