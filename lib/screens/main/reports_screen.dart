import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bavya_footer.dart';
import '../../widgets/brand_logo.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDistrict = 'All 26 Districts';
  String _dateFilter = 'This Month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _exportExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting Statewide Government Excel Report ($_dateFilter • $_selectedDistrict)...'),
        backgroundColor: AppColors.purple,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        currentRoute: '/reports',
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Government Reports & Analytics',
              style: AppTypography.title(color: AppColors.ink).copyWith(fontSize: 16),
            ),
            Text(
              'Compliance, Kilometers & Fleet Utilization',
              style: AppTypography.caption(color: AppColors.muted).copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Export Excel',
            icon: const Icon(Icons.download_rounded, color: AppColors.purple),
            onPressed: _exportExcel,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.purple,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.purple,
          indicatorWeight: 3,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Compliance'),
            Tab(text: 'Cumulative'),
            Tab(text: 'KM Trend'),
            Tab(text: 'Project Zones'),
            Tab(text: 'Vehicle Utilization'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const BavyaAccentLine(height: 3),

            // Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDistrict,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'All 26 Districts', child: Text('All 26 Districts')),
                        DropdownMenuItem(value: 'Guntur', child: Text('Guntur')),
                        DropdownMenuItem(value: 'Krishna', child: Text('Krishna')),
                        DropdownMenuItem(value: 'Visakhapatnam', child: Text('Visakhapatnam')),
                        DropdownMenuItem(value: 'Tirupati', child: Text('Tirupati')),
                        DropdownMenuItem(value: 'Kurnool', child: Text('Kurnool')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedDistrict = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _dateFilter,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Today', child: Text('Today')),
                        DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                        DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                        DropdownMenuItem(value: 'Year to Date', child: Text('Year to Date')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _dateFilter = v);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildComplianceTab(),
                  _buildCumulativeTab(),
                  _buildKmTrendTab(),
                  _buildProjectZonesTab(),
                  _buildVehicleUtilizationTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMetricSummaryRow(
          '98.4%', 'Roster Compliance',
          '172 / 175', 'Vehicles Active',
          AppColors.success,
        ),
        const SizedBox(height: 14),
        _buildReportCard(
          title: 'Daily Pre-Trip Roadworthiness Inspections',
          value: '99.1% Verified',
          desc: '172 inspections recorded today with verified photo proofs and GPS stamps.',
          status: 'Compliant',
          color: AppColors.success,
        ),
        const SizedBox(height: 10),
        _buildReportCard(
          title: 'Daily Rest / Lunch Break Logging',
          value: '96.8% Recorded',
          desc: 'Roster fatigue prevention policy enforced across all hearse drivers.',
          status: 'Normal',
          color: AppColors.info,
        ),
        const SizedBox(height: 10),
        _buildReportCard(
          title: 'Vehicle Fitness & PUC Expiration Watch',
          value: '3 Renewals Pending',
          desc: '2 vehicles in Guntur and 1 in Nellore due for annual fitness inspection.',
          status: 'Attention',
          color: AppColors.orange,
        ),
        const SizedBox(height: 20),
        const Center(child: BavyaFooter()),
      ],
    );
  }

  Widget _buildCumulativeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMetricSummaryRow(
          '14,892', 'Deceased Cases',
          '1,482,900', 'Kilometers Run',
          AppColors.brightMagenta,
        ),
        const SizedBox(height: 14),
        _buildReportCard(
          title: 'Single-Body Mortuary Transits',
          value: '13,420 Completed',
          desc: 'Direct hospital mortuary to native cremation/burial grounds.',
          status: 'Active',
          color: AppColors.purple,
        ),
        const SizedBox(height: 10),
        _buildReportCard(
          title: 'Multi-Body Mass Transit Missions',
          value: '1,472 Delivered',
          desc: 'Coordinated shared transit during mass casualties or emergency incidents.',
          status: 'Normal',
          color: AppColors.info,
        ),
        const SizedBox(height: 10),
        _buildReportCard(
          title: 'Average Transit Leg Distance',
          value: '99.6 KM',
          desc: 'Statewide average transit corridor length across rural and urban AP.',
          status: 'Verified',
          color: AppColors.success,
        ),
        const SizedBox(height: 20),
        const Center(child: BavyaFooter()),
      ],
    );
  }

  Widget _buildKmTrendTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMetricSummaryRow(
          '48,210 km', 'This Week Total',
          '+4.2%', 'vs Last Week',
          AppColors.purple,
        ),
        const SizedBox(height: 14),
        _buildReportCard(
          title: 'High-Utilization Corridor: Guntur -> Tenali',
          value: '4,280 km (43 Trips)',
          desc: 'Highest volume transit leg for GGH Guntur mortuary transfers.',
          status: 'High Demand',
          color: AppColors.brightMagenta,
        ),
        const SizedBox(height: 10),
        _buildReportCard(
          title: 'Coastal Corridor: Visakhapatnam -> Srikakulam',
          value: '3,890 km (28 Trips)',
          desc: 'Inter-district deceased transit along NH-16 highway corridor.',
          status: 'Normal',
          color: AppColors.info,
        ),
        const SizedBox(height: 10),
        _buildReportCard(
          title: 'Rayalaseema Corridor: Tirupati -> Chittoor',
          value: '2,940 km (22 Trips)',
          desc: 'SVIMS & Ruia Hospital mortuary outbound transfers.',
          status: 'Normal',
          color: AppColors.success,
        ),
        const SizedBox(height: 20),
        const Center(child: BavyaFooter()),
      ],
    );
  }

  Widget _buildProjectZonesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportCard(
          title: 'Zone 1 (North Coastal) - 6 Districts',
          value: '38 Vans • 3,420 Trips',
          desc: 'Srikakulam, Vizianagaram, Visakhapatnam, Anakapalli, Manyam, Alluri.',
          status: '100% On-Road',
          color: AppColors.success,
        ),
        const SizedBox(height: 10),
        _buildReportCard(
          title: 'Zone 2 (Central Coast) - 8 Districts',
          value: '54 Vans • 5,190 Trips',
          desc: 'Kakinada, Konaseema, East/West Godavari, Eluru, Krishna, NTR, Guntur.',
          status: '96% On-Road',
          color: AppColors.info,
        ),
        const SizedBox(height: 10),
        _buildReportCard(
          title: 'Zone 3 (South Coast) - 4 Districts',
          value: '28 Vans • 2,410 Trips',
          desc: 'Bapatla, Palnadu, Prakasam, SPSR Nellore.',
          status: '98% On-Road',
          color: AppColors.purple,
        ),
        const SizedBox(height: 10),
        _buildReportCard(
          title: 'Zone 4 (Rayalaseema) - 8 Districts',
          value: '55 Vans • 3,872 Trips',
          desc: 'Kurnool, Nandyal, Anantapur, Sri Sathya Sai, Kadapa, Chittoor, Tirupati.',
          status: '95% On-Road',
          color: AppColors.orange,
        ),
        const SizedBox(height: 20),
        const Center(child: BavyaFooter()),
      ],
    );
  }

  Widget _buildVehicleUtilizationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportCard(
          title: 'AP 16 MP 1042 (Force Trax Hearse)',
          value: '14,242 KM • Guntur Depot',
          desc: 'Today: 2 Completed Duties • Fuel Avg: 11.8 KM/L • Status: Active Duty',
          status: 'Optimal',
          color: AppColors.success,
        ),
        const SizedBox(height: 10),
        _buildReportCard(
          title: 'AP 39 TE 1080 (Tata Winger Mortuary)',
          value: '18,890 KM • Vijayawada Depot',
          desc: 'Today: 3 Completed Duties • Fuel Avg: 11.2 KM/L • Status: Active Duty',
          status: 'Optimal',
          color: AppColors.success,
        ),
        const SizedBox(height: 10),
        _buildReportCard(
          title: 'AP 31 MP 0921 (Force Cruiser Hearse)',
          value: '12,410 KM • Visakhapatnam Depot',
          desc: 'Scheduled 10,000 km Oil & Tyre servicing completed yesterday.',
          status: 'Depot Standby',
          color: AppColors.info,
        ),
        const SizedBox(height: 10),
        _buildReportCard(
          title: 'AP 04 MP 1102 (Force Trax Hearse)',
          value: '19,200 KM • Kadapa Depot',
          desc: 'Off-Road: Radiator coolant leakage under Wave 2 workshop repair.',
          status: 'Off-Road',
          color: AppColors.danger,
        ),
        const SizedBox(height: 20),
        const Center(child: BavyaFooter()),
      ],
    );
  }

  Widget _buildMetricSummaryRow(
    String val1, String lbl1,
    String val2, String lbl2,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(val1, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(lbl1, style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.line),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(val2, style: const TextStyle(color: AppColors.ink, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(lbl2, style: const TextStyle(color: AppColors.muted, fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String value,
    required String desc,
    required String status,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.ink),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
        ],
      ),
    );
  }
}
