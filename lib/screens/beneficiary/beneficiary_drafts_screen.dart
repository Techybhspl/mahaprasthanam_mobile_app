import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/beneficiary_provider.dart';
import '../../widgets/brand_logo.dart';
import 'beneficiary_form_screen.dart';

class BeneficiaryDraftsScreen extends StatefulWidget {
  const BeneficiaryDraftsScreen({super.key});

  @override
  State<BeneficiaryDraftsScreen> createState() => _BeneficiaryDraftsScreenState();
}

class _BeneficiaryDraftsScreenState extends State<BeneficiaryDraftsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BeneficiaryProvider>(context, listen: false).loadDraftsAndHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BeneficiaryProvider>(context);
    final drafts = provider.drafts;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Offline Drafts',
              style: AppTypography.title(color: AppColors.ink).copyWith(fontSize: 16),
            ),
            Text(
              'Retrieved Data Stored in Local SQLite',
              style: AppTypography.caption(color: AppColors.muted).copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const BavyaAccentLine(height: 3),
            Expanded(
              child: drafts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.drafts_outlined,
                            size: 64,
                            color: AppColors.muted.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No Offline Drafts Found',
                            style: AppTypography.title(color: AppColors.muted),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Trips saved as draft will appear here for sync.',
                            style: AppTypography.caption(color: AppColors.muted),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: drafts.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final trip = drafts[index];
                        final primaryBodyName = trip.bodies.isNotEmpty
                            ? trip.bodies.first.name
                            : 'Beneficiary';

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.line),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.ink.withValues(alpha: 0.04),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.roleDriver.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      trip.vehicleNumber,
                                      style: AppTypography.badge(
                                        color: AppColors.roleDriver,
                                      ).copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                                        onPressed: () => provider.deleteDraft(trip.localId),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_note_rounded, color: AppColors.purple, size: 22),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => BeneficiaryFormScreen(initialTrip: trip),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                primaryBodyName,
                                style: AppTypography.title(color: AppColors.ink).copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.local_hospital_rounded, size: 14, color: AppColors.muted),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      trip.hospitalName,
                                      style: AppTypography.caption(color: AppColors.muted),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.place_rounded, size: 14, color: AppColors.muted),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${trip.mandalName}, ${trip.village}',
                                      style: AppTypography.caption(color: AppColors.muted),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${trip.bodies.length} ${trip.bodies.length > 1 ? "Bodies" : "Body"} • ODO: ${trip.odoStart} KM',
                                    style: AppTypography.caption(color: AppColors.inkLight).copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final success = await provider.submitTrip(trip);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success ? 'Draft synced to server!' : 'Sync queued locally',
                                            ),
                                            backgroundColor: success ? AppColors.success : AppColors.amber,
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.purple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                                    label: const Text('Sync Now', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
