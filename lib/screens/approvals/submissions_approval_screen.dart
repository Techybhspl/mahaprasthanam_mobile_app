import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../services/submissions_review_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bavya_footer.dart';

class SubmissionsApprovalScreen extends StatefulWidget {
  const SubmissionsApprovalScreen({super.key});

  @override
  State<SubmissionsApprovalScreen> createState() => _SubmissionsApprovalScreenState();
}

class _SubmissionsApprovalScreenState extends State<SubmissionsApprovalScreen> {
  final SubmissionsReviewService _service = SubmissionsReviewService();
  bool _isLoading = true;
  List<PendingSubmission> _pendingList = [];

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() => _isLoading = true);
    final results = await _service.getPendingSubmissions();

    if (mounted) {
      setState(() {
        _pendingList = results.isNotEmpty
            ? results
            : [
                PendingSubmission(
                  id: 501,
                  templateId: 1,
                  templateTitle: 'Daily Vehicle Checklist & Odometer Sign-Off',
                  vehicleId: 12,
                  vehicleNumber: 'AP-16-MP-1042',
                  submittedByRole: 'DRIVER',
                  submitterName: 'Ravi Kumar (DRV-102)',
                  submissionDate: DateTime.now().subtract(const Duration(hours: 3)),
                  status: 'PENDING',
                  data: {
                    'start_odometer': 45120,
                    'closing_odometer': 45310,
                    'total_km': 190,
                    'cases_delivered': 2,
                    'cleanliness_ok': true,
                  },
                ),
                PendingSubmission(
                  id: 502,
                  templateId: 2,
                  templateTitle: 'Depot Fleet Readiness Inspection',
                  vehicleId: 14,
                  vehicleNumber: 'AP-16-MP-1044',
                  submittedByRole: 'FE',
                  submitterName: 'Suresh Babu (FE-04)',
                  submissionDate: DateTime.now().subtract(const Duration(hours: 5)),
                  status: 'PENDING',
                  data: {
                    'tyre_pressure_ok': true,
                    'first_aid_kit_present': true,
                    'def_coolant_level': 'Normal',
                  },
                ),
                PendingSubmission(
                  id: 503,
                  templateId: 3,
                  templateTitle: 'Hospital Mortuary Handoff Batch',
                  vehicleId: 18,
                  vehicleNumber: 'AP-07-MP-2021',
                  submittedByRole: 'BOE',
                  submitterName: 'Priya Sharma (BOE-11)',
                  submissionDate: DateTime.now().subtract(const Duration(hours: 8)),
                  status: 'PENDING',
                  data: {
                    'cases_logged': 3,
                    'district': 'Bapatla',
                  },
                ),
              ];
        _isLoading = false;
      });
    }
  }

  void _handleAction({
    required PendingSubmission submission,
    required String action, // 'APPROVED', 'REJECTED', 'REQUESTED_EDIT'
    required UserRole reviewerRole,
  }) async {
    final submitterRole = UserRole.fromCode(submission.submittedByRole);

    final success = await _service.reviewSubmission(
      submissionId: submission.id,
      reviewerRole: reviewerRole,
      submitterRole: submitterRole,
      action: action,
      remarks: 'Reviewed and verified by ${reviewerRole.roleCode}',
    );

    if (mounted) {
      Color bannerColor;
      if (action == 'APPROVED') {
        bannerColor = AppColors.success;
      } else if (action == 'REJECTED') {
        bannerColor = AppColors.danger;
      } else {
        bannerColor = AppColors.orange;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Submission #${submission.id} marked as $action'
                : 'Hierarchy Action recorded in sync queue',
          ),
          backgroundColor: bannerColor,
        ),
      );

      setState(() {
        _pendingList.removeWhere((item) => item.id == submission.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final reviewerRole = currentUser?.currentRoleEnum ?? authProvider.currentRole;

    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: AppDrawer(
        role: reviewerRole,
        userId: currentUser?.phoneNumber ?? 'User',
        scope: currentUser?.district ?? 'Statewide Operations',
        currentRoute: '/submissions',
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentRoute: '/submissions',
        role: reviewerRole,
      ),
      appBar: AppBar(
        title: Text('Submissions Review Inbox', style: AppTypography.h3(color: Colors.white)),
        backgroundColor: AppColors.roleDistrictManager,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.done_all_rounded, size: 48, color: AppColors.success),
                      const SizedBox(height: 12),
                      Text('All daily submissions are reviewed!', style: AppTypography.title()),
                      const SizedBox(height: 4),
                      Text('No pending items in your hierarchy queue', style: AppTypography.subtitle()),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _pendingList.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: BavyaFooter(isDark: false),
                      );
                    }

                    final sub = _pendingList[index];
                    final submitterRole = UserRole.fromCode(sub.submittedByRole);
                    final canReview = reviewerRole.canReviewSubmissionsOf(submitterRole);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.line),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.roleDistrictManager.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    sub.submittedByRole,
                                    style: AppTypography.badge(color: AppColors.roleDistrictManager),
                                  ),
                                ),
                                Text(
                                  sub.vehicleNumber,
                                  style: AppTypography.title(color: AppColors.ink),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(sub.templateTitle, style: AppTypography.h3()),
                            const SizedBox(height: 4),
                            Text(
                              'Submitted by: ${sub.submitterName}',
                              style: AppTypography.caption(color: AppColors.muted),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.bg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                sub.data.entries.map((e) => '${e.key}: ${e.value}').join('  •  '),
                                style: AppTypography.caption(color: AppColors.ink),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (canReview) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.orange,
                                        side: const BorderSide(color: AppColors.orange),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () => _handleAction(
                                        submission: sub,
                                        action: 'REQUESTED_EDIT',
                                        reviewerRole: reviewerRole,
                                      ),
                                      child: const Text('Request Edit'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.danger,
                                        side: const BorderSide(color: AppColors.danger),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () => _handleAction(
                                        submission: sub,
                                        action: 'REJECTED',
                                        reviewerRole: reviewerRole,
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.success,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () => _handleAction(
                                        submission: sub,
                                        action: 'APPROVED',
                                        reviewerRole: reviewerRole,
                                      ),
                                      child: Text('Approve', style: AppTypography.badge(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Text(
                                'Your role (${reviewerRole.roleCode}, IT: ${reviewerRole.hierarchyLevel}) does not outrank ${submitterRole.roleCode} (IT: ${submitterRole.hierarchyLevel})',
                                style: AppTypography.caption(color: AppColors.muted),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
