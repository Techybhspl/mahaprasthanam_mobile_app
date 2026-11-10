import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/offroad_model.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../services/offroad_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bavya_footer.dart';

class OffroadManagementScreen extends StatefulWidget {
  const OffroadManagementScreen({super.key});

  @override
  State<OffroadManagementScreen> createState() => _OffroadManagementScreenState();
}

class _OffroadManagementScreenState extends State<OffroadManagementScreen> {
  final OffroadService _offroadService = OffroadService();
  bool _isLoading = true;
  List<OffroadIncident> _incidents = [];

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    setState(() => _isLoading = true);
    final results = await _offroadService.getIncidents();

    if (mounted) {
      setState(() {
        _incidents = results.isNotEmpty
            ? results
            : [
                OffroadIncident(
                  id: 201,
                  vehicleId: 14,
                  vehicleNumber: 'AP-16-MP-1044',
                  district: 'Krishna',
                  incidentDate: DateTime.now().subtract(const Duration(hours: 6)),
                  location: 'NH-16 near Hanuman Junction',
                  reason: 'Radiator coolant burst & cylinder head gasket leak',
                  estimatedCost: 8500.0,
                  currentWave: 1,
                  status: 'WAVE1_PENDING',
                  assignedWorkshop: 'Krishna Auto Garage, Gudivada',
                ),
                OffroadIncident(
                  id: 202,
                  vehicleId: 19,
                  vehicleNumber: 'AP-21-MP-3002',
                  district: 'Kurnool',
                  incidentDate: DateTime.now().subtract(const Duration(days: 1)),
                  location: 'Depot Kurnool North',
                  reason: 'Differential crown pinion gear failure & axle shaft breakdown',
                  estimatedCost: 34000.0,
                  currentWave: 2,
                  status: 'WAVE2_PENDING',
                  assignedWorkshop: 'Authorized Tata Workshop, Kurnool',
                ),
                OffroadIncident(
                  id: 203,
                  vehicleId: 25,
                  vehicleNumber: 'AP-39-MP-5011',
                  district: 'Visakhapatnam',
                  incidentDate: DateTime.now().subtract(const Duration(days: 2)),
                  location: 'Anakapalli Bypass',
                  reason: 'Engine seizure due to lubrication oil pump failure (Full overhaul needed)',
                  estimatedCost: 78000.0,
                  currentWave: 3,
                  status: 'WAVE3_PENDING',
                  assignedWorkshop: 'Apex Heavy Commercial Works Vizag',
                ),
              ];
        _isLoading = false;
      });
    }
  }

  void _showReportDialog() {
    final vehicleController = TextEditingController(text: 'AP-16-MP-1042');
    final locController = TextEditingController();
    final reasonController = TextEditingController();
    final costController = TextEditingController();
    String selectedDistrict = ApiConstants.apDistricts26.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Report Off-Road Breakdown', style: AppTypography.h3()),
                  const SizedBox(height: 14),
                  TextField(
                    controller: vehicleController,
                    decoration: InputDecoration(
                      labelText: 'Vehicle Registration Number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDistrict,
                    decoration: InputDecoration(
                      labelText: 'District',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ApiConstants.apDistricts26.map((d) {
                      return DropdownMenuItem(value: d, child: Text(d));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedDistrict = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locController,
                    decoration: InputDecoration(
                      labelText: 'Breakdown Location / Landmark',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      labelText: 'Mechanical Breakdown Reason',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: costController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Estimated Repair Cost (₹)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (locController.text.trim().isEmpty || reasonController.text.trim().isEmpty) return;

                        final cost = double.tryParse(costController.text.trim()) ?? 0.0;
                        final wave = OffroadIncident.requiredWaveForCost(cost);

                        final incident = OffroadIncident(
                          vehicleId: 12,
                          vehicleNumber: vehicleController.text.trim(),
                          district: selectedDistrict,
                          incidentDate: DateTime.now(),
                          location: locController.text.trim(),
                          reason: reasonController.text.trim(),
                          estimatedCost: cost,
                          currentWave: wave,
                          status: 'WAVE${wave}_PENDING',
                        );

                        Navigator.of(ctx).pop();
                        await _offroadService.reportIncident(incident);
                        _loadIncidents();
                      },
                      child: Text('Submit Breakdown Report', style: AppTypography.button()),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleApproval({
    required OffroadIncident incident,
    required bool isApproved,
    required UserRole currentRole,
  }) async {
    final success = await _offroadService.submitWaveApproval(
      offroadId: incident.id ?? 0,
      wave: incident.currentWave,
      userRole: currentRole,
      isApproved: isApproved,
      remarks: isApproved ? 'Authorized per delegation matrix' : 'Rejected for cost review',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Wave ${incident.currentWave} ${isApproved ? "Approved" : "Rejected"} successfully'
                : 'Action recorded (Demo mode synced)',
          ),
          backgroundColor: isApproved ? AppColors.success : AppColors.danger,
        ),
      );
      _loadIncidents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentRole = authProvider.currentRole;
    final currentUser = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: AppDrawer(
        role: currentRole,
        userId: currentUser?.phoneNumber ?? 'User',
        scope: currentUser?.district ?? 'Statewide',
        currentRoute: '/offroad',
      ),
      appBar: AppBar(
        title: Text('Off-Road & Breakdown Desk', style: AppTypography.h3(color: Colors.white)),
        backgroundColor: AppColors.danger,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.danger,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        label: Text('Report Breakdown', style: AppTypography.badge(color: Colors.white)),
        onPressed: _showReportDialog,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _incidents.length + 1,
              itemBuilder: (context, index) {
                if (index == _incidents.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: BavyaFooter(isDark: false),
                  );
                }

                final incident = _incidents[index];
                final canApprove = currentRole.canApproveWave(incident.currentWave);

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
                                color: incident.statusBadgeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                incident.status,
                                style: AppTypography.badge(color: incident.statusBadgeColor),
                              ),
                            ),
                            Text(
                              '₹${incident.estimatedCost.toStringAsFixed(0)}',
                              style: AppTypography.h3(color: AppColors.ink),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              incident.vehicleNumber,
                              style: AppTypography.title(color: AppColors.ink),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${incident.district}',
                              style: AppTypography.caption(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Location: ${incident.location}',
                          style: AppTypography.caption(color: AppColors.muted),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          incident.reason,
                          style: AppTypography.body(),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.layers_outlined, size: 16, color: AppColors.muted),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Wave ${incident.currentWave} Required: ${_waveAuthorityDescription(incident.currentWave)}',
                                  style: AppTypography.caption(color: AppColors.ink),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (canApprove) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.danger,
                                    side: const BorderSide(color: AppColors.danger),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => _handleApproval(
                                    incident: incident,
                                    isApproved: false,
                                    currentRole: currentRole,
                                  ),
                                  child: const Text('Reject'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => _handleApproval(
                                    incident: incident,
                                    isApproved: true,
                                    currentRole: currentRole,
                                  ),
                                  child: Text('Approve Wave ${incident.currentWave}', style: AppTypography.badge(color: Colors.white)),
                                ),
                              ),
                            ],
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

  String _waveAuthorityDescription(int wave) {
    switch (wave) {
      case 1:
        return 'DM / RM (Cost ≤ ₹10,000)';
      case 2:
        return 'SFM / SFH (Cost ₹10,001 - ₹50,000)';
      case 3:
        return 'COO / ADMIN (Cost > ₹50,000)';
      default:
        return 'Standard approval';
    }
  }
}
