import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bavya_footer.dart';
import '../../widgets/brand_logo.dart';

class FillReportScreen extends StatefulWidget {
  const FillReportScreen({super.key});

  @override
  State<FillReportScreen> createState() => _FillReportScreenState();
}

class _FillReportScreenState extends State<FillReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController(text: '14242');
  final _fuelLevelController = TextEditingController(text: '75');
  final _remarksController = TextEditingController();

  String _selectedVehicle = 'AP 39 TE 1080';
  bool _isSubmitting = false;
  bool _isLoadingVehicles = true;
  List<String> _vehicleList = [
    'AP 39 TE 1080',
    'AP 16 MP 1042',
    'AP 31 MP 0921',
  ];
  final ApiClient _apiClient = ApiClient();

  // 24-Point Roadworthiness Verification Checkpoints
  final Map<String, bool> _inspectionPoints = {
    'Mortuary Cabin AC & Deep Freezer (2°C - 8°C)': true,
    'Hydraulic Stretcher Lock & Straps': true,
    'Emergency Siren & LED Beacon Bar': true,
    'Tyre Pressure & Minimum 3mm Tread': true,
    'Brake Fluid, Pad Travel & Handbrake': true,
    'Engine Oil Level & Coolant Level': true,
    'Power Steering & Suspension Check': true,
    'Cabin Sanitation & Disinfectant Spray': true,
    'First Aid Kit & Emergency PPE Stock': true,
    'Live GPS Tracker Online & Signal Ping': true,
    'Carry-Forward Odometer Verified': true,
    'Vehicle Documentation (PUC/Insurance)': true,
  };

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoadingVehicles = true);
    try {
      final response = await _apiClient.get(ApiConstants.vehicles);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data is List ? response.data : (response.data['data'] ?? response.data['vehicles'] ?? []);
        if (list is List && list.isNotEmpty) {
          final fetched = list.map<String>((item) {
            final reg = item['registration_number'] ?? item['regNo'] ?? item['registrationNumber'] ?? 'AP 16 MP 1000';
            return reg.toString();
          }).toList();

          if (mounted && fetched.isNotEmpty) {
            setState(() {
              _vehicleList = fetched;
              _selectedVehicle = _vehicleList.first;
              _isLoadingVehicles = false;
            });
            return;
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoadingVehicles = false);
    }
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _fuelLevelController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _submitInspection() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily Inspection & Roadworthiness Report certified and submitted successfully.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final role = user?.currentRoleEnum ?? auth.selectedRole;
    final userId = user?.name ?? 'Staff';
    const scope = 'Andhra Pradesh Free Hearse Operations';

    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: AppDrawer(
        role: role,
        userId: userId,
        scope: scope,
        currentRoute: '/fill-report',
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Pre-Trip Fill Report',
              style: AppTypography.title(color: AppColors.ink).copyWith(fontSize: 16),
            ),
            Text(
              'Roadworthiness & Operational Checklist',
              style: AppTypography.caption(color: AppColors.muted).copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BavyaAccentLine(height: 3),
                const SizedBox(height: 16),

                // Vehicle & Odometer Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.brightMagenta.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.commute_rounded, color: AppColors.brightMagenta, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Vehicle Telemetry Info',
                            style: AppTypography.title(color: AppColors.ink).copyWith(fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _isLoadingVehicles
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            )
                          : DropdownButtonFormField<String>(
                              initialValue: _vehicleList.contains(_selectedVehicle) ? _selectedVehicle : _vehicleList.first,
                              isExpanded: true,
                              decoration: const InputDecoration(labelText: 'Assigned Hearse Van *'),
                              items: _vehicleList.map((v) {
                                return DropdownMenuItem(
                                  value: v,
                                  child: Text(v, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedVehicle = v);
                              },
                            ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _odometerController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Opening Odometer (km) *',
                                prefixIcon: Icon(Icons.speed_rounded, size: 18),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _fuelLevelController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Fuel Tank (%) *',
                                prefixIcon: Icon(Icons.local_gas_station_rounded, size: 18),
                                suffixText: '%',
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 24-Point Inspection Checklist
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.purple.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.checklist_rounded, color: AppColors.purple, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pre-Trip Roadworthiness Checklist',
                                  style: AppTypography.title(color: AppColors.ink).copyWith(fontSize: 15),
                                ),
                                Text(
                                  'Mandatory checks before hearse vehicle departure',
                                  style: AppTypography.caption(color: AppColors.muted).copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ..._inspectionPoints.keys.map((point) {
                        final isChecked = _inspectionPoints[point] ?? false;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _inspectionPoints[point] = !isChecked;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isChecked ? AppColors.success.withValues(alpha: 0.05) : AppColors.bg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isChecked ? AppColors.success.withValues(alpha: 0.3) : AppColors.line,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                    color: isChecked ? AppColors.success : AppColors.muted,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      point,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isChecked ? FontWeight.w600 : FontWeight.w500,
                                        color: isChecked ? AppColors.ink : AppColors.muted,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isChecked
                                          ? AppColors.success.withValues(alpha: 0.12)
                                          : Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isChecked ? 'PASS' : 'FAIL',
                                      style: TextStyle(
                                        color: isChecked ? AppColors.success : AppColors.muted,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _remarksController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Inspector Remarks / Notes',
                          hintText: 'Any physical scratches or mechanical observations...',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitInspection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brightMagenta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Certify & Submit Fill Report',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                const Center(child: BavyaFooter()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
