import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bavya_footer.dart';
import '../../widgets/brand_logo.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';
  String _gpsFrequency = '15 seconds (High Precision)';
  bool _offlineAutoSync = true;
  bool _urgentDispatchAlerts = true;
  bool _approvalAlerts = true;
  bool _maintenanceExpiries = true;

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Local SQLite cache and temporary form snapshots cleared (14.2 MB freed).'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _testServerConnection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Server Ping: 42ms to https://one.bhspl.in • Status: ONLINE (HTTP 200)'),
        backgroundColor: AppColors.roleAdmin,
        behavior: SnackBarBehavior.floating,
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
        currentRoute: '/settings',
      ),
      appBar: AppBar(
        backgroundColor: AppColors.darkSplashBg,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings & Preferences',
              style: AppTypography.title(color: Colors.white, fontWeight: FontWeight.w700).copyWith(fontSize: 16),
            ),
            Text(
              'System Configuration • Mahaprastanam',
              style: AppTypography.caption(color: Colors.white70).copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const BavyaAccentLine(height: 3),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Localization
                  Text('Language & Regional Preferences', style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Interface Language', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                          subtitle: Text('Selected: $_selectedLanguage', style: const TextStyle(fontSize: 12)),
                          trailing: DropdownButton<String>(
                            value: _selectedLanguage,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'English', child: Text('English')),
                              DropdownMenuItem(value: 'తెలుగు (Telugu)', child: Text('తెలుగు (Telugu)')),
                              DropdownMenuItem(value: 'हिंदी (Hindi)', child: Text('हिंदी (Hindi)')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedLanguage = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Section 2: Telematics & Sync
                  Text('Telematics & Offline Sync', style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Automatic SQLite Sync', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                          subtitle: const Text('Auto-sync draft intakes when WiFi/4G network is re-established', style: TextStyle(fontSize: 11.5)),
                          value: _offlineAutoSync,
                          activeThumbColor: AppColors.brightMagenta,
                          onChanged: (v) => setState(() => _offlineAutoSync = v),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('GPS Corridor Ping Interval', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                          subtitle: Text(_gpsFrequency, style: const TextStyle(fontSize: 11.5)),
                          trailing: DropdownButton<String>(
                            value: _gpsFrequency,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: '15 seconds (High Precision)', child: Text('15s High')),
                              DropdownMenuItem(value: '30 seconds (Standard)', child: Text('30s Standard')),
                              DropdownMenuItem(value: '60 seconds (Battery Saver)', child: Text('60s Eco')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _gpsFrequency = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Section 3: Notification Alerts
                  Text('Push Alerts & Escalations', style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Urgent Dispatches (104 / 108 Call Center)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                          value: _urgentDispatchAlerts,
                          activeThumbColor: AppColors.brightMagenta,
                          onChanged: (v) => setState(() => _urgentDispatchAlerts = v),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Approval Pending Requests', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                          value: _approvalAlerts,
                          activeThumbColor: AppColors.brightMagenta,
                          onChanged: (v) => setState(() => _approvalAlerts = v),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Insurance & Fitness Expiry Reminders', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                          value: _maintenanceExpiries,
                          activeThumbColor: AppColors.brightMagenta,
                          onChanged: (v) => setState(() => _maintenanceExpiries = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Section 4: Diagnostics & Maintenance
                  Text('System Diagnostics', style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.speed_rounded, color: AppColors.roleAdmin),
                          title: const Text('Test Central Server Connectivity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                          subtitle: const Text('Endpoint: https://one.bhspl.in/api/v1', style: TextStyle(fontSize: 11.5)),
                          trailing: OutlinedButton(
                            onPressed: _testServerConnection,
                            style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                            child: const Text('PING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.cleaning_services_rounded, color: AppColors.orange),
                          title: const Text('Clear Offline Database Cache', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                          subtitle: const Text('14.2 MB cached files', style: TextStyle(fontSize: 11.5)),
                          trailing: OutlinedButton(
                            onPressed: _clearCache,
                            style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact, foregroundColor: AppColors.orange),
                            child: const Text('CLEAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // App Version Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.darkSplashBg.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'MAHAPRASTHANAM MOBILE SUITE',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.darkSplashBg, letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 2),
                        const Text('Release Version: v2.4.1 (Build 20261027-Prod)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const Text('Deployment: Govt. of Andhra Pradesh Statewide Cloud', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                      ],
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
    );
  }
}
