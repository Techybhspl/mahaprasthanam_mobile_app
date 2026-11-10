import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bavya_footer.dart';
import '../../widgets/brand_logo.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final Map<String, bool> _projectModules = {
    'Deceased Beneficiary Intake & KYC': true,
    'Live Transit Corridor Telematics': true,
    '24-Point Roadworthiness Daily Inspection': true,
    '17 Maintenance Workflows & Invoicing': true,
    'Fuel Card Tracking & Dispensing Audits': true,
    'Off-Road Breakdown Escalations': true,
    'Multi-Tier Approval Matrix': true,
    'Statewide GPS & Heatmap Telematics': true,
  };

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
        currentRoute: '/projects',
      ),
      appBar: AppBar(
        backgroundColor: AppColors.darkSplashBg,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Governance',
              style: AppTypography.title(color: Colors.white, fontWeight: FontWeight.w700).copyWith(fontSize: 16),
            ),
            Text(
              'MAHAPRASTHANAM-AP • Govt. of Andhra Pradesh',
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
                  // Project Overview Card
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
                          color: AppColors.darkSplashBg.withValues(alpha: 0.25),
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
                                color: AppColors.yellow.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.yellow),
                              ),
                              child: const Text(
                                'ACTIVE STATEWIDE CONTRACT',
                                style: TextStyle(color: AppColors.yellow, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.success),
                              ),
                              child: const Text('STATUS: LIVE', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'MAHAPRASTHANAM (Free Hearse Van Services)',
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Govt. of Andhra Pradesh • Health, Medical & Family Welfare Dept.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 14),

                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 12,
                          runSpacing: 10,
                          children: [
                            _buildWhiteKpi('26', 'Districts'),
                            _buildWhiteKpi('175', 'Hearse Vans'),
                            _buildWhiteKpi('100%', 'Free Citizen Service'),
                            _buildWhiteKpi('<30 min', 'SLA Response'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Project Details & Scope
                  Text('Project Metadata & Scope', style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 15)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildRow('Project Code', 'MP-AP-2026-GOVT'),
                        _buildRow('Operating Partner', 'Bavya Health Services Pvt Ltd (BHSPL)'),
                        _buildRow('Nodal Department', 'Commissioner of Health & Family Welfare, AP'),
                        _buildRow('State Nodal Officer', 'Dr. K. Somasekhar, Joint Director (Logistics)'),
                        _buildRow('State Control Room', '104 / 108 Integrated Dispatch Center, Vijayawada'),
                        _buildRow('Fleet Specification', 'Force Trax Cruiser & Tata Winger Mortuary Vans'),
                        _buildRow('Contract Duration', '01 Nov 2024 - 31 Oct 2029 (5 Years)'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Module Toggles & Configuration
                  Text('Active Project Modules', style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('Statewide enabled capabilities configured by State Admin:', style: AppTypography.caption(color: AppColors.textSecondary)),
                  const SizedBox(height: 10),

                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: _projectModules.entries.map((e) {
                          return SwitchListTile(
                            title: Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            value: e.value,
                            activeThumbColor: AppColors.brightMagenta,
                            onChanged: (val) {
                              setState(() => _projectModules[e.key] = val);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Module "${e.key}" configuration updated.'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          );
                        }).toList(),
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
    );
  }

  Widget _buildWhiteKpi(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10.5, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
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
}
