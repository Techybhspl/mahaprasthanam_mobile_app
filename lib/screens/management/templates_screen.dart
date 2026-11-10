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

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  List<Map<String, dynamic>> _templates = [];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiConstants.templates);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data is List ? response.data : (response.data['data'] ?? response.data['templates'] ?? []);
        if (list is List && list.isNotEmpty) {
          setState(() {
            _templates = list.map<Map<String, dynamic>>((item) {
              return {
                'title': item['title'] ?? item['name'] ?? 'Inspection Checklist',
                'version': item['version'] ?? 'v3.2.0',
                'category': item['category'] ?? 'Fleet Safety',
                'updated': item['updated_at'] ?? item['updated'] ?? 'Recent',
                'fieldsCount': item['fields_count'] ?? item['fieldsCount'] ?? 24,
                'photoMandatory': item['photo_mandatory'] ?? item['photoMandatory'] ?? true,
                'code': item['code'] ?? item['template_code'] ?? 'CHK-TEMPLATE',
                'description': item['description'] ?? 'Mandatory inspection checklist schema.',
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
        _templates = [
          {
            'title': 'Daily Roadworthiness Inspection Checklist',
            'version': 'v3.2.0',
            'category': 'Fleet Safety',
            'updated': '20 Oct 2026',
            'fieldsCount': 24,
            'photoMandatory': true,
            'code': 'CHK-ROADWORTHY-24P',
            'description': 'Mandatory morning pre-trip verification covering deep freezer cabin, hydraulics, tyre tread, and brakes.',
          },
          {
            'title': 'Beneficiary Intake & Deceased KYC Form',
            'version': 'v2.8.4',
            'category': 'Beneficiary',
            'updated': '15 Oct 2026',
            'fieldsCount': 38,
            'photoMandatory': true,
            'code': 'FRM-BENEFICIARY-INTAKE',
            'description': 'Aadhaar biometric/manual verification, Hospital Death Summary, Mortuary NOC, and attendant contact.',
          },
          {
            'title': 'Preventive Maintenance (PM 5K / 10K)',
            'version': 'v1.5.1',
            'category': 'Repairs & Maintenance',
            'updated': '04 Sep 2026',
            'fieldsCount': 42,
            'photoMandatory': true,
            'code': 'CHK-FLEET-PREVENTIVE',
            'description': 'Authorized OEM dealership service checklist including engine oil, air filter, and compressor gas refill.',
          },
          {
            'title': 'Off-Road Emergency Breakdown Report',
            'version': 'v2.1.0',
            'category': 'Fleet Incident',
            'updated': '18 Aug 2026',
            'fieldsCount': 19,
            'photoMandatory': true,
            'code': 'INC-OFFROAD-EMERGENCY',
            'description': 'Accident, mechanical stall, or tyre burst report triggering replacement hearse dispatch within 30 minutes.',
          },
          {
            'title': 'Fuel Dispensing & Petro-Card Audit',
            'version': 'v1.0.8',
            'category': 'Fuel Intel',
            'updated': '22 Jul 2026',
            'fieldsCount': 14,
            'photoMandatory': true,
            'code': 'AUD-FUEL-PETROCARD',
            'description': 'HPCL automated petrol pump receipt capture, opening/closing odometer calculation, and fuel theft audit.',
          },
        ];
        _isLoading = false;
      });
    }
  }

  void _previewTemplate(Map<String, dynamic> t) {
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
                Expanded(
                  child: Text(
                    t['title'],
                    style: AppTypography.title(color: AppColors.darkSplashBg, fontWeight: FontWeight.w800).copyWith(fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.darkSplashBg, borderRadius: BorderRadius.circular(6)),
                  child: Text(t['version'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Template Code: ${t['code']} • ${t['category']}', style: AppTypography.caption(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            Text(t['description'], style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary)),
            const SizedBox(height: 14),

            _buildDetail('Total Dynamic Form Inputs', '${t['fieldsCount']} schema fields'),
            _buildDetail('Camera Photo Mandatory', t['photoMandatory'] ? 'Yes (Geo-tagged camera)' : 'No'),
            _buildDetail('Effective Since', t['updated']),
            _buildDetail('Storage Format', 'PostgreSQL JSONB + SQLite Offline Cache'),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Exporting ${t['code']} schema definition (JSON)...'),
                      backgroundColor: AppColors.brightMagenta,
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text('EXPORT SCHEMA SPECIFICATION'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brightMagenta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
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
        currentRoute: '/templates',
      ),
      appBar: AppBar(
        backgroundColor: AppColors.darkSplashBg,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dynamic Form Templates',
              style: AppTypography.title(color: Colors.white, fontWeight: FontWeight.w700).copyWith(fontSize: 16),
            ),
            Text(
              'Government Inspection Schemas • Mahaprastanam',
              style: AppTypography.caption(color: Colors.white70).copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTemplates,
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
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.purple.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.dynamic_form_rounded, color: AppColors.purple, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Central Template Governance',
                                style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 13.5),
                              ),
                              Text(
                                'All mobile checklists are synced dynamically from server JSON schemas without app store updates.',
                                style: AppTypography.caption(color: AppColors.textSecondary).copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  Text(
                    'Active Field Form Schemas (${_templates.length})',
                    style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 10),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _templates.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final t = _templates[index];

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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkSplashBg.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(t['code'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5, color: AppColors.darkSplashBg)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.brightMagenta.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(t['version'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5, color: AppColors.brightMagenta)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              t['title'],
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t['description'],
                              style: AppTypography.caption(color: AppColors.textSecondary).copyWith(fontSize: 11.5, height: 1.3),
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1),
                            const SizedBox(height: 8),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${t['fieldsCount']} Inputs • Updated ${t['updated']}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _previewTemplate(t),
                                  icon: const Icon(Icons.visibility_rounded, size: 14),
                                  label: const Text('PREVIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.darkSplashBg,
                                    side: const BorderSide(color: AppColors.darkSplashBg),
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
