import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/beneficiary_trip_model.dart';
import '../../models/trip_body_model.dart';
import '../../providers/beneficiary_provider.dart';
import '../../widgets/bavya_footer.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/location_disclosure_dialog.dart';
import '../../widgets/watermarked_camera_card.dart';

class BeneficiaryFormScreen extends StatefulWidget {
  final BeneficiaryTripModel? initialTrip;

  const BeneficiaryFormScreen({
    super.key,
    this.initialTrip,
  });

  @override
  State<BeneficiaryFormScreen> createState() => _BeneficiaryFormScreenState();
}

class _BeneficiaryFormScreenState extends State<BeneficiaryFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _localId;
  late TextEditingController _tripDateController;
  late TextEditingController _hospitalController;
  late TextEditingController _vehicleController;
  late TextEditingController _driverController;
  late TextEditingController _attendantNameController;
  late TextEditingController _attendantPhoneController;
  late TextEditingController _odoStartController;
  late TextEditingController _odoEndController;
  late TextEditingController _mandalController;
  late TextEditingController _villageController;
  late TextEditingController _destinationController;
  late TextEditingController _remarksController;

  String? _odoStartImagePath;
  String? _odoEndImagePath;

  List<TripBodyModel> _bodies = [];

  List<String> get _districts => ApiConstants.apDistricts26;

  late String _startDistrict;
  late String _destDistrict;

  @override
  void initState() {
    super.initState();
    final trip = widget.initialTrip;

    _localId = trip?.localId ?? DateTime.now().millisecondsSinceEpoch.toString();
    _tripDateController = TextEditingController(
      text: trip?.tripDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _hospitalController = TextEditingController(
      text: trip?.hospitalName ?? 'Government General Hospital, Vijayawada',
    );
    _vehicleController = TextEditingController(
      text: trip?.vehicleNumber ?? 'AP-16-MP-1042',
    );
    _driverController = TextEditingController(
      text: trip?.driverName ?? 'Ravi Kumar',
    );
    _attendantNameController = TextEditingController(
      text: trip?.attendantName ?? '',
    );
    _attendantPhoneController = TextEditingController(
      text: trip?.attendantPhone ?? '',
    );
    _odoStartController = TextEditingController(
      text: trip != null ? trip.odoStart.toString() : '45120',
    );
    _odoEndController = TextEditingController(
      text: trip?.odoEnd != null ? trip!.odoEnd.toString() : '',
    );
    _mandalController = TextEditingController(
      text: trip?.mandalName ?? 'Tenali',
    );
    _villageController = TextEditingController(
      text: trip?.village ?? 'Angalakuduru',
    );
    _destinationController = TextEditingController(
      text: trip?.destination ?? 'Native Village Graveyard',
    );
    _remarksController = TextEditingController(
      text: trip?.remarks ?? '',
    );

    _startDistrict = _districts.first;
    _destDistrict = _districts.first;

    _odoStartImagePath = trip?.odoStartImagePath;
    _odoEndImagePath = trip?.odoEndImagePath;

    if (trip != null && trip.bodies.isNotEmpty) {
      _bodies = List.from(trip.bodies);
    } else {
      // Default initial body
      _bodies.add(
        const TripBodyModel(
          name: '',
          age: 50,
          gender: 'Male',
          caste: 'BC',
          caseType: 'DC',
          dcMlcNumber: '',
          isCovid: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tripDateController.dispose();
    _hospitalController.dispose();
    _vehicleController.dispose();
    _driverController.dispose();
    _attendantNameController.dispose();
    _attendantPhoneController.dispose();
    _odoStartController.dispose();
    _odoEndController.dispose();
    _mandalController.dispose();
    _villageController.dispose();
    _destinationController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _addDeceasedBody() {
    setState(() {
      _bodies.add(
        const TripBodyModel(
          name: '',
          age: 45,
          gender: 'Female',
          caste: 'OC',
          caseType: 'DC',
          dcMlcNumber: '',
          isCovid: false,
        ),
      );
    });
  }

  void _removeDeceasedBody(int index) {
    if (_bodies.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one deceased profile is required.')),
      );
      return;
    }
    setState(() {
      _bodies.removeAt(index);
    });
  }

  BeneficiaryTripModel _constructTripModel({required String status}) {
    final startOdo = int.tryParse(_odoStartController.text.trim()) ?? 0;
    final endOdo = int.tryParse(_odoEndController.text.trim());

    return BeneficiaryTripModel(
      id: widget.initialTrip?.id,
      localId: _localId,
      tripDate: _tripDateController.text.trim(),
      regionId: 1,
      startDistrictId: _districts.indexOf(_startDistrict) + 1,
      destDistrictId: _districts.indexOf(_destDistrict) + 1,
      hospitalName: _hospitalController.text.trim(),
      vehicleId: 42,
      vehicleNumber: _vehicleController.text.trim(),
      driverName: _driverController.text.trim(),
      attendantName: _attendantNameController.text.trim(),
      attendantPhone: _attendantPhoneController.text.trim(),
      odoStart: startOdo,
      odoEnd: endOdo,
      mandalName: _mandalController.text.trim(),
      village: _villageController.text.trim(),
      destination: _destinationController.text.trim(),
      remarks: _remarksController.text.trim(),
      status: status,
      bodies: _bodies,
      odoStartImagePath: _odoStartImagePath,
      odoEndImagePath: _odoEndImagePath,
      createdAt: widget.initialTrip?.createdAt ?? DateTime.now().toIso8601String(),
      isSynced: false,
    );
  }

  Future<void> _handleSaveDraft() async {
    final trip = _constructTripModel(status: 'DRAFT');
    final provider = Provider.of<BeneficiaryProvider>(context, listen: false);
    final success = await provider.saveDraft(trip);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Trip draft saved offline in SQLite' : 'Failed to save draft',
          ),
          backgroundColor: success ? AppColors.success : AppColors.danger,
        ),
      );
      if (success) Navigator.of(context).pop();
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the validation errors in the form.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final tripDateStr = _tripDateController.text.trim();
    final parsedTripDate = DateTime.tryParse(tripDateStr);
    if (parsedTripDate != null) {
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day, 23, 59, 59);
      if (parsedTripDate.isAfter(todayMidnight)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip date cannot be in the future.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
    }

    final attendantPhoneClean = _attendantPhoneController.text.replaceAll(RegExp(r'\D'), '');
    if (attendantPhoneClean.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendant phone number must have at least 10 digits.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final startOdo = int.tryParse(_odoStartController.text.trim()) ?? 0;
    final endOdo = int.tryParse(_odoEndController.text.trim());

    // Odometer range rule (0 to 999,999 KM)
    if (startOdo < 0 || startOdo > 999999 || (endOdo != null && (endOdo < 0 || endOdo > 999999))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Odometer readings must be between 0 and 999,999 KM.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Odometer continuity rule
    if (endOdo != null && endOdo < startOdo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Closing Odometer ($endOdo KM) must be greater than or equal to Starting Odometer ($startOdo KM).',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Verify bodies have valid names
    for (int i = 0; i < _bodies.length; i++) {
      if (_bodies[i].name.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter the name for Deceased Body #${i + 1}.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
    }

    // Request location disclosure if not yet granted
    await LocationDisclosureDialog.show(context);
    if (!mounted) return;

    final trip = _constructTripModel(status: 'SUBMITTED');
    final provider = Provider.of<BeneficiaryProvider>(context, listen: false);
    final success = await provider.submitTrip(trip);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
              ? 'Beneficiary transit trip successfully submitted!'
              : 'Saved locally for upload when network is available.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Beneficiary Deceased Transit',
              style: AppTypography.title(color: AppColors.ink).copyWith(fontSize: 16),
            ),
            Text(
              'Dignified & Noble Citizen Journey Record',
              style: AppTypography.caption(color: AppColors.muted).copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BavyaAccentLine(height: 3),
                const SizedBox(height: 16),

                // Section 1: Trip Telematics & Vehicle
                _buildSectionCard(
                  title: '1. Vehicle & Dispatch Telematics',
                  icon: Icons.local_shipping_rounded,
                  accentColor: AppColors.roleDriver,
                  children: [
                    TextFormField(
                      controller: _tripDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Trip Date',
                        prefixIcon: Icon(Icons.calendar_today_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _vehicleController,
                            decoration: const InputDecoration(
                              labelText: 'Assigned Vehicle',
                              prefixIcon: Icon(Icons.directions_car_rounded, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _driverController,
                            decoration: const InputDecoration(
                              labelText: 'Driver Name',
                              prefixIcon: Icon(Icons.person_rounded, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _hospitalController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Hospital name is required' : null,
                      decoration: const InputDecoration(
                        labelText: 'Source Hospital / Mortuary *',
                        prefixIcon: Icon(Icons.local_hospital_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            key: ValueKey('start_$_startDistrict'),
                            initialValue: _startDistrict,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Pickup District'),
                            items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (v) => setState(() => _startDistrict = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            key: ValueKey('dest_$_destDistrict'),
                            initialValue: _destDistrict,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Destination District'),
                            items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (v) => setState(() => _destDistrict = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _mandalController,
                            decoration: const InputDecoration(labelText: 'Destination Mandal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _villageController,
                            decoration: const InputDecoration(labelText: 'Village / Town'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _destinationController,
                      decoration: const InputDecoration(
                        labelText: 'Final Transit Destination / Crematorium',
                        prefixIcon: Icon(Icons.place_rounded, size: 20),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Section 2: Attendant Information
                _buildSectionCard(
                  title: '2. Family Attendant Details',
                  icon: Icons.family_restroom_rounded,
                  accentColor: AppColors.purple,
                  children: [
                    TextFormField(
                      controller: _attendantNameController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Attendant name is required' : null,
                      decoration: const InputDecoration(
                        labelText: 'Attendant / Family Relative Name *',
                        prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _attendantPhoneController,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Attendant phone number is required';
                        if (v.length < 10) return 'Enter a valid 10-digit mobile number';
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Attendant Contact Phone (10 digits) *',
                        prefixIcon: Icon(Icons.phone_rounded, size: 20),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Section 3: Odometer Integrity & Photo Proofs
                _buildSectionCard(
                  title: '3. Odometer Verification & Photo Proof',
                  icon: Icons.speed_rounded,
                  accentColor: AppColors.brightMagenta,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _odoStartController,
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            decoration: const InputDecoration(
                              labelText: 'Starting ODO (KM) *',
                              prefixIcon: Icon(Icons.play_circle_outline_rounded, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _odoEndController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Closing ODO (KM)',
                              prefixIcon: Icon(Icons.stop_circle_outlined, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    WatermarkedCameraCard(
                      label: 'Starting Odometer Photo with GPS Stamp',
                      odoType: 'START',
                      vehicleNumber: _vehicleController.text,
                      odometerReading: int.tryParse(_odoStartController.text),
                      initialImagePath: _odoStartImagePath,
                      onImageCaptured: (path, watermark) {
                        setState(() => _odoStartImagePath = path);
                      },
                    ),
                    const SizedBox(height: 12),
                    WatermarkedCameraCard(
                      label: 'Closing Odometer Photo with GPS Stamp',
                      odoType: 'END',
                      vehicleNumber: _vehicleController.text,
                      odometerReading: int.tryParse(_odoEndController.text),
                      initialImagePath: _odoEndImagePath,
                      onImageCaptured: (path, watermark) {
                        setState(() => _odoEndImagePath = path);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Section 4: Deceased Citizen Profiles (Multi-Body Support)
                _buildSectionCard(
                  title: '4. Deceased Citizen Profile (${_bodies.length} ${_bodies.length > 1 ? "Bodies" : "Body"})',
                  icon: Icons.airline_seat_flat_rounded,
                  accentColor: AppColors.roleDistrictManager,
                  headerAction: TextButton.icon(
                    onPressed: _addDeceasedBody,
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.purple),
                    label: Text(
                      '+ Add Body',
                      style: AppTypography.caption(color: AppColors.purple).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  children: [
                    ..._bodies.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final body = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.lineDark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Deceased Profile #${idx + 1}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.title(color: AppColors.ink).copyWith(fontSize: 13.5),
                                  ),
                                ),
                                if (_bodies.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                                    onPressed: () => _removeDeceasedBody(idx),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              initialValue: body.name,
                              decoration: const InputDecoration(
                                labelText: 'Deceased Full Name *',
                                prefixIcon: Icon(Icons.person_rounded, size: 20),
                              ),
                              onChanged: (val) {
                                _bodies[idx] = _bodies[idx].copyWith(name: val);
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: body.age.toString(),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'Age (Years)'),
                                    onChanged: (val) {
                                      _bodies[idx] = _bodies[idx].copyWith(
                                        age: int.tryParse(val) ?? 0,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    key: ValueKey('gender_${idx}_${body.gender}'),
                                    initialValue: body.gender,
                                    isExpanded: true,
                                    decoration: const InputDecoration(labelText: 'Gender'),
                                    items: ['Male', 'Female', 'Other']
                                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                        .toList(),
                                    onChanged: (val) {
                                      _bodies[idx] = _bodies[idx].copyWith(gender: val ?? 'Male');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    key: ValueKey('caste_${idx}_${body.caste}'),
                                    initialValue: body.caste,
                                    isExpanded: true,
                                    decoration: const InputDecoration(labelText: 'Category / Caste'),
                                    items: ['BC', 'SC', 'ST', 'OC', 'Minority']
                                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                        .toList(),
                                    onChanged: (val) {
                                      _bodies[idx] = _bodies[idx].copyWith(caste: val ?? 'BC');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    key: ValueKey('casetype_${idx}_${body.caseType}'),
                                    initialValue: body.caseType,
                                    isExpanded: true,
                                    decoration: const InputDecoration(labelText: 'Case Type'),
                                    items: [
                                      const DropdownMenuItem(value: 'DC', child: Text('DC (Death Cert.)')),
                                      const DropdownMenuItem(value: 'MLC', child: Text('MLC (Medico-Legal)')),
                                    ],
                                    onChanged: (val) {
                                      _bodies[idx] = _bodies[idx].copyWith(caseType: val ?? 'DC');
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              initialValue: body.dcMlcNumber,
                              decoration: const InputDecoration(
                                labelText: 'DC / MLC Certificate Ref No.',
                                prefixIcon: Icon(Icons.assignment_outlined, size: 20),
                              ),
                              onChanged: (val) {
                                _bodies[idx] = _bodies[idx].copyWith(dcMlcNumber: val);
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 24),

                // Form Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _handleSaveDraft,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                          side: const BorderSide(color: AppColors.purple),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.save_as_rounded, size: 18, color: AppColors.purple),
                        label: Text(
                          'Save Draft',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.button(color: AppColors.purple).copyWith(fontSize: 13.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        text: 'Submit Trip',
                        icon: Icons.check_circle_rounded,
                        gradientColors: const [AppColors.roleDriver, AppColors.brightMagenta],
                        onPressed: _handleSubmit,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                const Center(child: BavyaFooter()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<Widget> children,
    Widget? headerAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.03),
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
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: accentColor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title(color: AppColors.ink).copyWith(fontSize: 14.5),
                      ),
                    ),
                  ],
                ),
              ),
              ?headerAction,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
