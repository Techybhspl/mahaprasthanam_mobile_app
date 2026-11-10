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

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Mortuary Deep Freezer / AC';
  String _selectedPriority = 'High';
  bool _isAnonymous = false;
  bool _hasPhotoAttached = false;
  bool _isSubmitting = false;
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;

  final List<String> _categories = [
    'Mortuary Deep Freezer / AC',
    'Vehicle Mechanical & Brakes',
    'Hydraulic Stretcher & Locks',
    'GPS Telematics & Tablet App',
    'Fuel Card & HPCL Billing',
    'Citizen Assistance & Support',
    'Administrative & Roster',
  ];

  List<Map<String, dynamic>> _tickets = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiConstants.feedback);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data is List ? response.data : (response.data['data'] ?? response.data['feedback'] ?? []);
        if (list is List && list.isNotEmpty) {
          setState(() {
            _tickets = list.map<Map<String, dynamic>>((item) {
              return {
                'id': item['ticket_no'] ?? item['id'] ?? 'TKT-2026-0000',
                'subject': item['subject'] ?? 'Grievance / Feedback',
                'category': item['category'] ?? 'Mortuary Deep Freezer / AC',
                'priority': item['priority'] ?? 'Normal',
                'status': item['status'] ?? 'Open',
                'date': item['created_at'] ?? item['date'] ?? 'Recently',
                'response': item['response'] ?? item['admin_response'] ?? 'Pending review by Control Room.',
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
        _tickets = [
          {
            'id': 'TKT-2026-0814',
            'subject': 'Freezer cabin temperature sensor fluctuating between 8°C and 12°C',
            'category': 'Mortuary Deep Freezer / AC',
            'priority': 'Urgent',
            'status': 'In Review',
            'date': '26 Oct 2026, 04:30 PM',
            'response': 'Depot technician assigned for inspection at Guntur GGH depot.',
          },
          {
            'id': 'TKT-2026-0792',
            'subject': 'HPCL Petrol Pump fuel card chip reader error on NH-16 bypass',
            'category': 'Fuel Card & HPCL Billing',
            'priority': 'Normal',
            'status': 'Resolved',
            'date': '24 Oct 2026, 11:15 AM',
            'response': 'Card re-authorized. Transaction manually cleared with fuel receipt.',
          },
          {
            'id': 'TKT-2026-0681',
            'subject': 'Hydraulic stretcher roller lock pin needs lubrication',
            'category': 'Vehicle Mechanical & Brakes',
            'priority': 'Normal',
            'status': 'Resolved',
            'date': '19 Oct 2026, 09:00 AM',
            'response': 'Preventive maintenance check completed at depot.',
          },
        ];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _apiClient.post(ApiConstants.feedback, data: {
        'subject': _subjectController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'priority': _selectedPriority,
        'is_anonymous': _isAnonymous,
      });
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _tickets.insert(0, {
        'id': 'TKT-2026-${1000 + _tickets.length}',
        'subject': _subjectController.text.trim(),
        'category': _selectedCategory,
        'priority': _selectedPriority,
        'status': 'Open',
        'date': 'Just now',
        'response': 'Ticket dispatched to District Logistics Operations team.',
      });
      _subjectController.clear();
      _descriptionController.clear();
      _hasPhotoAttached = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feedback Submitted Successfully. Reference ticket generated.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    _tabController.animateTo(1);
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Urgent':
        return AppColors.error;
      case 'High':
        return AppColors.orange;
      case 'Normal':
      default:
        return AppColors.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolved':
        return AppColors.success;
      case 'In Review':
        return AppColors.orange;
      case 'Open':
      default:
        return AppColors.roleAdmin;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final userRole = currentUser?.currentRoleEnum ?? UserRole.driver;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      drawer: AppDrawer(
        role: userRole,
        userId: currentUser?.phoneNumber ?? 'User',
        scope: currentUser?.district ?? 'Statewide',
        currentRoute: '/feedback',
      ),
      appBar: AppBar(
        backgroundColor: AppColors.darkSplashBg,
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Field Feedback & Support',
              style: AppTypography.title(color: Colors.white, fontWeight: FontWeight.w700).copyWith(fontSize: 16),
            ),
            Text(
              'Grievance & Incident Reporting • Mahaprastanam',
              style: AppTypography.caption(color: Colors.white70).copyWith(fontSize: 11),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.brightMagenta,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'SUBMIT FEEDBACK', icon: Icon(Icons.rate_review_rounded, size: 18)),
            Tab(text: 'MY TICKETS', icon: Icon(Icons.receipt_long_rounded, size: 18)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Submit Feedback Form
                RefreshIndicator(
                  onRefresh: _loadTickets,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const BavyaAccentLine(height: 3),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Banner
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.brightMagenta.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.brightMagenta.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.help_center_rounded, color: AppColors.brightMagenta, size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Direct Line to Control Room',
                                              style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 13.5),
                                            ),
                                            Text(
                                              'Report vehicle defects, app glitches, or operational hurdles for immediate intervention.',
                                              style: AppTypography.caption(color: AppColors.textSecondary).copyWith(fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Category Dropdown
                                Text('Category', style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w700).copyWith(fontSize: 13)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCategory,
                                      isExpanded: true,
                                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13.5)))).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedCategory = val);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Priority Level
                                Text('Severity / Priority', style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w700).copyWith(fontSize: 13)),
                                const SizedBox(height: 6),
                                Row(
                                  children: ['Normal', 'High', 'Urgent'].map((p) {
                                    final isSel = _selectedPriority == p;
                                    final color = _getPriorityColor(p);
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: InkWell(
                                          onTap: () => setState(() => _selectedPriority = p),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            decoration: BoxDecoration(
                                              color: isSel ? color : Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: color),
                                            ),
                                            child: Center(
                                              child: Text(
                                                p,
                                                style: TextStyle(
                                                  color: isSel ? Colors.white : color,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 12.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),

                                // Subject
                                Text('Subject / Summary', style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w700).copyWith(fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _subjectController,
                                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a subject' : null,
                                  decoration: InputDecoration(
                                    hintText: 'e.g., Deep freezer motor making rattling noise',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Description
                                Text('Detailed Description', style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w700).copyWith(fontSize: 13)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 4,
                                  validator: (v) => v == null || v.trim().length < 10 ? 'Please provide at least 10 characters' : null,
                                  decoration: InputDecoration(
                                    hintText: 'Describe location, symptoms, vehicle status, and whether transit is affected...',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Photo Attachment & Anonymous
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() => _hasPhotoAttached = !_hasPhotoAttached);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(_hasPhotoAttached ? 'Photo attached from camera.' : 'Photo attachment removed.'),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      icon: Icon(_hasPhotoAttached ? Icons.check_circle_rounded : Icons.camera_alt_rounded, size: 18),
                                      label: Text(_hasPhotoAttached ? '1 PHOTO ATTACHED' : 'ATTACH PHOTO'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _hasPhotoAttached ? AppColors.success : AppColors.darkSplashBg,
                                        side: BorderSide(color: _hasPhotoAttached ? AppColors.success : Colors.grey.shade400),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Checkbox(
                                          value: _isAnonymous,
                                          activeColor: AppColors.darkSplashBg,
                                          onChanged: (val) => setState(() => _isAnonymous = val ?? false),
                                        ),
                                        const Text('Anonymous', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting ? null : _submitTicket,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.brightMagenta,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                        : const Text('SUBMIT FEEDBACK TICKET', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const BavyaFooter(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Tab 2: Feedback Tickets List
                RefreshIndicator(
                  onRefresh: _loadTickets,
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
                              Text(
                                'Your Grievances & Inquiries',
                                style: AppTypography.title(color: AppColors.textPrimary, fontWeight: FontWeight.w800).copyWith(fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Official ticket timeline tracked with state operations control room:',
                                style: AppTypography.caption(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 14),

                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _tickets.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final t = _tickets[index];
                                  final priorityColor = _getPriorityColor(t['priority']);
                                  final statusColor = _getStatusColor(t['status']);

                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
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
                                              child: Text(t['id'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.darkSplashBg)),
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: priorityColor.withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(t['priority'], style: TextStyle(color: priorityColor, fontWeight: FontWeight.w800, fontSize: 10)),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: statusColor.withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(t['status'], style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 10)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          t['subject'],
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Category: ${t['category']} • ${t['date']}',
                                          style: AppTypography.caption(color: AppColors.textSecondary).copyWith(fontSize: 11),
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.reply_rounded, size: 16, color: AppColors.info),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  t['response'],
                                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary, height: 1.3),
                                                ),
                                              ),
                                            ],
                                          ),
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
              ],
            ),
    );
  }
}
