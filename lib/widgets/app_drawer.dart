import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_vector_icons.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../providers/auth_provider.dart';
import '../screens/approvals/submissions_approval_screen.dart';
import '../screens/beneficiary/beneficiary_drafts_screen.dart';
import '../screens/beneficiary/beneficiary_form_screen.dart';
import '../screens/beneficiary/beneficiary_history_screen.dart';
import '../screens/beneficiary/live_corridor_screen.dart';
import '../screens/fleet/fleet_maintenance_screen.dart';
import '../screens/fleet/gps_tracking_screen.dart';
import '../screens/fleet/offroad_management_screen.dart';
import '../screens/fleet/vehicle_management_screen.dart';
import '../screens/main/break_log_screen.dart';
import '../screens/main/feedback_screen.dart';
import '../screens/main/fill_report_screen.dart';
import '../screens/main/fuel_intel_screen.dart';
import '../screens/main/reports_screen.dart';
import '../screens/management/geography_screen.dart';
import '../screens/management/import_data_screen.dart';
import '../screens/management/projects_screen.dart';
import '../screens/management/settings_screen.dart';
import '../screens/management/templates_screen.dart';
import '../screens/management/users_screen.dart';
import '../screens/management/vehicle_drivers_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/role_dashboard_screen.dart';
import 'bavya_version_signature.dart';
import 'brand_logo.dart';

/// Navigation Drawer matching the Mahaprastanam Web Left Sidebar
/// Supporting unrestricted Super Admin access and dynamic role restrictions
class AppDrawer extends StatelessWidget {
  final UserRole role;
  final String userId;
  final String scope;
  final String currentRoute;

  const AppDrawer({
    super.key,
    required this.role,
    required this.userId,
    required this.scope,
    this.currentRoute = '/dashboard',
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final isSuperAdmin = (currentUser?.isSuperAdmin == true) || (role == UserRole.admin);
    final activeRole = currentUser?.currentRoleEnum ?? role;
    final displayColor = isSuperAdmin ? AppColors.roleAdmin : activeRole.color;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header matching Web Brand Sidebar
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 18,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.darkSplashBg,
                  AppColors.midSplashBg,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 4-Color Accent Line
                const BavyaAccentLine(height: 3.5),
                const SizedBox(height: 14),

                // Brand Title & Emblem
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/ems_108_ambulance.png',
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, stack) => Icon(
                          AppVectorIcons.ambulance.active,
                          color: AppColors.yellow,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MAHAPRASTHANAM',
                            style: AppTypography.title(color: Colors.white, fontWeight: FontWeight.w800).copyWith(
                              fontSize: 14,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            'Govt. of Andhra Pradesh',
                            style: AppTypography.caption(color: Colors.white70).copyWith(fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // User Profile Summary Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 19,
                        backgroundColor: displayColor,
                        child: Text(
                          (currentUser?.name.isNotEmpty == true
                                  ? currentUser!.name[0]
                                  : (userId.isNotEmpty ? userId[0] : 'U'))
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser?.name.isNotEmpty == true ? currentUser!.name : userId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSuperAdmin
                                    ? AppColors.brightMagenta.withValues(alpha: 0.3)
                                    : Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isSuperAdmin
                                    ? 'SUPER ADMIN'
                                    : activeRole.roleCode,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Sidebar Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // 1. MAIN
                _buildSectionLabel('MAIN'),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.dashboard.active,
                  title: 'Dashboard',
                  route: '/dashboard',
                  moduleKey: 'dashboard',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/dashboard') {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => RoleDashboardScreen(
                            role: activeRole,
                            userId: userId,
                            scope: scope,
                          ),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.fillReport.active,
                  title: 'Fill Report',
                  route: '/fill-report',
                  moduleKey: 'fill_report',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/fill-report') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FillReportScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.submissions.active,
                  title: 'Submissions',
                  route: '/submissions',
                  moduleKey: 'submissions',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/submissions') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SubmissionsApprovalScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.reports.active,
                  title: 'Reports',
                  route: '/reports',
                  moduleKey: 'reports',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/reports') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ReportsScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.fuelIntel.active,
                  title: 'Fuel Intel',
                  route: '/fuel',
                  moduleKey: 'fuel',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/fuel') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FuelIntelScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.breakLog.active,
                  title: 'Break',
                  route: '/breaks',
                  moduleKey: 'breaks',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/breaks') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BreakLogScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.feedback.active,
                  title: 'Feedback',
                  route: '/feedback',
                  moduleKey: 'feedback',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/feedback') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                      );
                    }
                  },
                ),

                const Divider(height: 20, indent: 16, endIndent: 16),

                // 2. BENEFICIARY
                _buildSectionLabel('BENEFICIARY'),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.beneficiaryIntake.active,
                  title: 'New Beneficiary Intake',
                  route: '/beneficiary/create',
                  moduleKey: 'beneficiary',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/beneficiary/create') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BeneficiaryFormScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.liveCorridor.active,
                  title: 'Live Transit Corridor',
                  route: '/beneficiary/corridor',
                  moduleKey: 'live-trip',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/beneficiary/corridor') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LiveCorridorScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.retrievedDrafts.active,
                  title: 'Retrieved Data (Drafts)',
                  route: '/beneficiary/drafts',
                  moduleKey: 'beneficiary',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/beneficiary/drafts') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BeneficiaryDraftsScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.beneficiaryHistory.active,
                  title: 'Beneficiary Data (History)',
                  route: '/beneficiary/history',
                  moduleKey: 'beneficiary',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/beneficiary/history') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BeneficiaryHistoryScreen()),
                      );
                    }
                  },
                ),

                const Divider(height: 20, indent: 16, endIndent: 16),

                // 3. VEHICLE REPAIRS AND MAINTENANCE
                _buildSectionLabel('VEHICLE REPAIRS AND MAINTENANCE'),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.fleetMaintenance.active,
                  title: 'Maintenance Dashboard (17 Workflows)',
                  route: '/maintenance',
                  moduleKey: 'vehicle_maintenance',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/maintenance') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FleetMaintenanceScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.compliance.active,
                  title: 'Compliance & Expirations',
                  route: '/maintenance/compliance',
                  moduleKey: 'vehicle_maintenance',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/maintenance/compliance') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FleetMaintenanceScreen(initialTabIndex: 1)),
                      );
                    }
                  },
                ),

                const Divider(height: 20, indent: 16, endIndent: 16),

                // 4. FLEET
                _buildSectionLabel('FLEET'),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.vehicleManagement.active,
                  title: 'Vehicle Management',
                  route: '/vehicles',
                  moduleKey: 'vehicles',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/vehicles') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const VehicleManagementScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.offroadManagement.active,
                  title: 'Off-Road',
                  route: '/offroad',
                  moduleKey: 'offroad',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/offroad') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OffroadManagementScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.gpsTracking.active,
                  title: 'GPS Tracking',
                  route: '/gps',
                  moduleKey: 'gps',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/gps') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GpsTrackingScreen()),
                      );
                    }
                  },
                ),

                const Divider(height: 20, indent: 16, endIndent: 16),

                // 5. MANAGEMENT
                _buildSectionLabel('MANAGEMENT'),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.projects.active,
                  title: 'Project',
                  route: '/projects',
                  moduleKey: 'projects',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/projects') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProjectsScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.templates.active,
                  title: 'Templates',
                  route: '/templates',
                  moduleKey: 'templates',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/templates') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TemplatesScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.users.active,
                  title: 'Users',
                  route: '/users',
                  moduleKey: 'users',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/users') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const UsersScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.vehicleDrivers.active,
                  title: 'Vehicle Drivers',
                  route: '/vehicle-drivers',
                  moduleKey: 'vehicle_driver_management',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/vehicle-drivers') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const VehicleDriversScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.geography.active,
                  title: 'Geography',
                  route: '/geography',
                  moduleKey: 'geography',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/geography') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GeographyScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.importData.active,
                  title: 'Import Data',
                  route: '/import',
                  moduleKey: 'import',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/import') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ImportDataScreen()),
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.settings.active,
                  title: 'Settings',
                  route: '/settings',
                  moduleKey: 'settings',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/settings') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    }
                  },
                ),

                const Divider(height: 20, indent: 16, endIndent: 16),

                // 6. PROFILE & ACCOUNT (No logout here, dedicated version signature below)
                _buildSectionLabel('ACCOUNT'),
                _buildNavItem(
                  context: context,
                  icon: AppVectorIcons.profile.active,
                  title: 'Profile',
                  route: '/profile',
                  moduleKey: 'profile',
                  isSuperAdmin: isSuperAdmin,
                  user: currentUser,
                  role: activeRole,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != '/profile') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Drawer Footer with Highlighted App Version & Powered by BAVYA Signature
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: const BavyaVersionSignature(
              isDark: false,
              versionString: 'v1.0.0+1',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required String moduleKey,
    required bool isSuperAdmin,
    required UserModel? user,
    required UserRole role,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    // Check permission
    final bool isVisible = isSuperAdmin ||
        moduleKey == 'dashboard' ||
        moduleKey == 'profile' ||
        (user != null ? user.canAccess(moduleKey) : role.hasStaticPermission(moduleKey));

    if (!isVisible) return const SizedBox.shrink();

    final bool isActive = currentRoute == route;
    final itemColor = iconColor ?? (isActive ? AppColors.brightMagenta : AppColors.ink);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1.5),
      child: Material(
        color: isActive ? AppColors.brightMagenta.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: itemColor,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: itemColor,
                      fontSize: 13.5,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.brightMagenta,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
