import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/maintenance_model.dart';
import '../../models/user_role.dart';
import '../../providers/auth_provider.dart';
import '../../services/maintenance_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bavya_footer.dart';

class FleetMaintenanceScreen extends StatefulWidget {
  final int? vehicleId;
  final String? vehicleNumber;
  final int initialTabIndex;

  const FleetMaintenanceScreen({
    super.key,
    this.vehicleId,
    this.vehicleNumber,
    this.initialTabIndex = 0,
  });

  @override
  State<FleetMaintenanceScreen> createState() => _FleetMaintenanceScreenState();
}

class _FleetMaintenanceScreenState extends State<FleetMaintenanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MaintenanceService _maintenanceService = MaintenanceService();

  bool _isLoading = true;
  List<MaintenanceRecord> _records = [];
  List<ComplianceAlert> _alerts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final records = await _maintenanceService.getRecords(vehicleId: widget.vehicleId);
    final alerts = await _maintenanceService.getComplianceAlerts();

    if (mounted) {
      setState(() {
        _records = records.isNotEmpty
            ? records
            : [
                MaintenanceRecord(
                  id: 101,
                  vehicleId: widget.vehicleId ?? 12,
                  vehicleNumber: widget.vehicleNumber ?? 'AP-16-MP-1042',
                  maintenanceType: 'TYRE',
                  description: 'Replaced rear axle dual tyres & balanced pressure',
                  cost: 14500.0,
                  serviceCenter: 'Bridgestone Commercial Vijayawada',
                  invoiceNumber: 'INV-2026-9081',
                  recordDate: DateTime.now().subtract(const Duration(days: 3)),
                  odometerReading: 45050,
                  status: 'COMPLETED',
                ),
                MaintenanceRecord(
                  id: 102,
                  vehicleId: widget.vehicleId ?? 12,
                  vehicleNumber: widget.vehicleNumber ?? 'AP-16-MP-1042',
                  maintenanceType: 'SCHEDULED',
                  description: '45,000 KM Engine oil flush, oil filter, air filter',
                  cost: 8200.0,
                  serviceCenter: 'Tata Motors Authorized Guntur Depot',
                  invoiceNumber: 'INV-2026-8812',
                  recordDate: DateTime.now().subtract(const Duration(days: 18)),
                  odometerReading: 44200,
                  status: 'COMPLETED',
                ),
              ];

        _alerts = alerts.isNotEmpty
            ? alerts
            : [
                ComplianceAlert(
                  vehicleId: 12,
                  vehicleNumber: widget.vehicleNumber ?? 'AP-16-MP-1042',
                  district: 'Guntur',
                  complianceType: 'FITNESS',
                  expiryDate: DateTime.now().add(const Duration(days: 9)),
                  daysRemaining: 9,
                  status: 'EXPIRING_SOON',
                ),
                ComplianceAlert(
                  vehicleId: 15,
                  vehicleNumber: 'AP-16-MP-1045',
                  district: 'NTR',
                  complianceType: 'PUC',
                  expiryDate: DateTime.now().add(const Duration(days: 3)),
                  daysRemaining: 3,
                  status: 'EXPIRING_SOON',
                ),
                ComplianceAlert(
                  vehicleId: 18,
                  vehicleNumber: 'AP-07-MP-2021',
                  district: 'Bapatla',
                  complianceType: 'INSURANCE',
                  expiryDate: DateTime.now().add(const Duration(days: 42)),
                  daysRemaining: 42,
                  status: 'VALID',
                ),
              ];

        _isLoading = false;
      });
    }
  }

  void _showAddRecordDialog() {
    final typeController = TextEditingController(text: 'SCHEDULED');
    final descController = TextEditingController();
    final costController = TextEditingController();
    final vendorController = TextEditingController();
    final odoController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
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
              Text(
                'Log Fleet Servicing Entry',
                style: AppTypography.h3(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: typeController.text,
                decoration: InputDecoration(
                  labelText: 'Maintenance Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'SCHEDULED', child: Text('Scheduled Periodic Service')),
                  DropdownMenuItem(value: 'TYRE', child: Text('Tyres & Alignment')),
                  DropdownMenuItem(value: 'BATTERY', child: Text('Battery Servicing / Replacement')),
                  DropdownMenuItem(value: 'EMERGENCY', child: Text('Emergency Mechanical Repair')),
                ],
                onChanged: (val) => typeController.text = val ?? 'SCHEDULED',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Work Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cost (₹)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: odoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Odometer (KM)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: vendorController,
                decoration: InputDecoration(
                  labelText: 'Authorized Workshop / Vendor',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roleFleetManager,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (descController.text.trim().isEmpty) return;
                    final cost = double.tryParse(costController.text.trim()) ?? 0.0;
                    final odo = int.tryParse(odoController.text.trim());

                    final newRecord = MaintenanceRecord(
                      vehicleId: widget.vehicleId ?? 12,
                      vehicleNumber: widget.vehicleNumber ?? 'AP-16-MP-1042',
                      maintenanceType: typeController.text,
                      description: descController.text.trim(),
                      cost: cost,
                      serviceCenter: vendorController.text.trim(),
                      recordDate: DateTime.now(),
                      odometerReading: odo,
                      status: 'COMPLETED',
                    );

                    Navigator.of(ctx).pop();
                    await _maintenanceService.createRecord(newRecord);
                    _loadData();
                  },
                  child: Text('Save Record', style: AppTypography.button()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final userRole = currentUser?.currentRoleEnum ?? UserRole.fleetManager;

    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: AppDrawer(
        role: userRole,
        userId: currentUser?.phoneNumber ?? 'User',
        scope: currentUser?.district ?? 'Statewide',
        currentRoute: widget.initialTabIndex == 1 ? '/maintenance/compliance' : '/maintenance',
      ),
      appBar: AppBar(
        title: Text(
          'Fleet Maintenance & Compliance',
          style: AppTypography.h3(color: Colors.white),
        ),
        backgroundColor: AppColors.roleFleetManager,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.amber,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: AppTypography.badge(color: Colors.white),
          tabs: const [
            Tab(icon: Icon(Icons.build_circle_outlined), text: 'Service Records'),
            Tab(icon: Icon(Icons.shield_outlined), text: 'Compliance Alerts'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.roleFleetManager,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Log Service', style: AppTypography.badge(color: Colors.white)),
        onPressed: _showAddRecordDialog,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRecordsTab(),
                _buildAlertsTab(),
              ],
            ),
    );
  }

  Widget _buildRecordsTab() {
    if (_records.isEmpty) {
      return Center(
        child: Text('No maintenance records found.', style: AppTypography.subtitle()),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _records.length + 1,
      itemBuilder: (context, index) {
        if (index == _records.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: BavyaFooter(isDark: false),
          );
        }

        final record = _records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
                        color: AppColors.roleFleetManager.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        record.maintenanceType,
                        style: AppTypography.badge(color: AppColors.roleFleetManager),
                      ),
                    ),
                    Text(
                      '₹${record.cost.toStringAsFixed(0)}',
                      style: AppTypography.h3(color: AppColors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(record.description, style: AppTypography.body()),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.line),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.directions_car_filled_outlined, size: 14, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text(record.vehicleNumber, style: AppTypography.caption()),
                    const Spacer(),
                    if (record.odometerReading != null) ...[
                      Icon(Icons.speed, size: 14, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Text('${record.odometerReading} KM', style: AppTypography.caption()),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertsTab() {
    if (_alerts.isEmpty) {
      return Center(
        child: Text('All vehicle compliance documents are valid!', style: AppTypography.subtitle()),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alerts.length + 1,
      itemBuilder: (context, index) {
        if (index == _alerts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: BavyaFooter(isDark: false),
          );
        }

        final alert = _alerts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: alert.statusColor.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: alert.statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.warning_amber_rounded, color: alert.statusColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            alert.complianceType,
                            style: AppTypography.title(color: AppColors.ink),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${alert.vehicleNumber})',
                            style: AppTypography.caption(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'District: ${alert.district} • Expires: ${alert.expiryDate.toIso8601String().split('T').first}',
                        style: AppTypography.caption(),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: alert.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${alert.daysRemaining} days',
                    style: AppTypography.badge(color: alert.statusColor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
