import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/beneficiary_provider.dart';
import '../../widgets/brand_logo.dart';

class BeneficiaryHistoryScreen extends StatefulWidget {
  const BeneficiaryHistoryScreen({super.key});

  @override
  State<BeneficiaryHistoryScreen> createState() => _BeneficiaryHistoryScreenState();
}

class _BeneficiaryHistoryScreenState extends State<BeneficiaryHistoryScreen> {
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
    final history = provider.history;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transit History & Audit',
              style: AppTypography.title(color: AppColors.ink).copyWith(fontSize: 16),
            ),
            Text(
              'Completed Dignified Transit Cases',
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
              child: history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_toggle_off_rounded,
                            size: 64,
                            color: AppColors.muted.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No Submitted Trips Yet',
                            style: AppTypography.title(color: AppColors.muted),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Completed beneficiary trips will appear here.',
                            style: AppTypography.caption(color: AppColors.muted),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: history.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final trip = history[index];
                        final primaryBody = trip.bodies.isNotEmpty ? trip.bodies.first : null;

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
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                                            const SizedBox(width: 4),
                                            Text(
                                              'COMPLETED',
                                              style: AppTypography.badge(
                                                color: AppColors.success,
                                              ).copyWith(fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        trip.vehicleNumber,
                                        style: AppTypography.caption(color: AppColors.ink).copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: trip.isSynced
                                          ? AppColors.purple.withValues(alpha: 0.08)
                                          : AppColors.amber.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      trip.isSynced ? 'Synced' : 'Local Queue',
                                      style: AppTypography.caption(
                                        color: trip.isSynced ? AppColors.purple : AppColors.amber,
                                      ).copyWith(fontSize: 10.5, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                primaryBody?.name ?? 'Beneficiary Deceased Citizen',
                                style: AppTypography.title(color: AppColors.ink).copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Case: ${primaryBody?.caseType ?? "DC"} • Age: ${primaryBody?.age ?? "-"} • Attendant: ${trip.attendantName}',
                                style: AppTypography.caption(color: AppColors.muted),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.bg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Source Hospital', style: AppTypography.caption(color: AppColors.muted).copyWith(fontSize: 10.5)),
                                        Text(trip.hospitalName, style: AppTypography.body(color: AppColors.ink).copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('Total Distance', style: AppTypography.caption(color: AppColors.muted).copyWith(fontSize: 10.5)),
                                        Text(
                                          '${trip.totalKilometers} KM',
                                          style: AppTypography.body(color: AppColors.purple).copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
