import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Represents a purposeful semantic vector icon entry in the vector database
class VectorIconEntry {
  final String key;
  final String label;
  final String purpose;
  final String category;
  final IconData active;
  final IconData outline;
  final Color accentColor;

  const VectorIconEntry({
    required this.key,
    required this.label,
    required this.purpose,
    required this.category,
    required this.active,
    required this.outline,
    required this.accentColor,
  });

  /// Render the vector icon with custom size and color overrides
  Widget render({
    double size = 20,
    Color? color,
    bool isOutline = false,
  }) {
    return Icon(
      isOutline ? outline : active,
      size: size,
      color: color ?? accentColor,
    );
  }
}

/// Centralized Purpose-Driven Vector Database for Mahaprastanam Operations
/// Maps operational workflows and governance domains to purposeful vector glyphs.
class AppVectorIcons {
  // ==========================================
  // 1. MAIN OPERATIONAL & FIELD VECTORS
  // ==========================================
  static const dashboard = VectorIconEntry(
    key: 'dashboard',
    label: 'Dashboard',
    purpose: 'Executive state telematics & operational command summary',
    category: 'Main',
    active: Icons.dashboard_rounded,
    outline: Icons.dashboard_outlined,
    accentColor: AppColors.roleAdmin,
  );

  static const fillReport = VectorIconEntry(
    key: 'fill_report',
    label: 'Fill Report',
    purpose: '24-point roadworthiness verification & daily pre-trip certification',
    category: 'Main',
    active: Icons.assignment_turned_in_rounded,
    outline: Icons.assignment_outlined,
    accentColor: AppColors.roleDriver,
  );

  static const submissions = VectorIconEntry(
    key: 'submissions',
    label: 'Submissions',
    purpose: 'Hierarchical workflow approval inbox and managerial sign-offs',
    category: 'Main',
    active: Icons.fact_check_rounded,
    outline: Icons.fact_check_outlined,
    accentColor: AppColors.roleDistrictManager,
  );

  static const reports = VectorIconEntry(
    key: 'reports',
    label: 'Reports',
    purpose: 'Government MIS analytics, trip logs, and KPI performance exports',
    category: 'Main',
    active: Icons.analytics_rounded,
    outline: Icons.analytics_outlined,
    accentColor: AppColors.purple,
  );

  static const fuelIntel = VectorIconEntry(
    key: 'fuel',
    label: 'Fuel Intel',
    purpose: 'Smart diesel fuel disbursement, receipt logs, and mileage telemetry',
    category: 'Main',
    active: Icons.local_gas_station_rounded,
    outline: Icons.local_gas_station_outlined,
    accentColor: AppColors.orange,
  );

  static const breakLog = VectorIconEntry(
    key: 'breaks',
    label: 'Break Log',
    purpose: 'Shift rest compliance, tea pauses, and driver alertness rosters',
    category: 'Main',
    active: Icons.free_breakfast_rounded,
    outline: Icons.free_breakfast_outlined,
    accentColor: AppColors.roleDriver,
  );

  static const feedback = VectorIconEntry(
    key: 'feedback',
    label: 'Feedback',
    purpose: 'Beneficiary family redressal and field service satisfaction feedback',
    category: 'Main',
    active: Icons.reviews_rounded,
    outline: Icons.reviews_outlined,
    accentColor: AppColors.brightMagenta,
  );

  // ==========================================
  // 2. BENEFICIARY & MORTUARY CARE VECTORS
  // ==========================================
  static const beneficiaryIntake = VectorIconEntry(
    key: 'beneficiary_intake',
    label: 'Beneficiary Intake',
    purpose: 'Morgue handover, deceased profile registration, and next-of-kin documentation',
    category: 'Beneficiary',
    active: Icons.person_add_rounded,
    outline: Icons.person_add_outlined,
    accentColor: AppColors.purple,
  );

  static const liveCorridor = VectorIconEntry(
    key: 'live_corridor',
    label: 'Live Corridor',
    purpose: 'Real-time GPS interstate transit corridor tracking with speed telematics',
    category: 'Beneficiary',
    active: Icons.alt_route_rounded,
    outline: Icons.alt_route_outlined,
    accentColor: AppColors.roleAdmin,
  );

  static const retrievedDrafts = VectorIconEntry(
    key: 'drafts',
    label: 'Retrieved Drafts',
    purpose: 'Locally cached offline forms and synchronized emergency intake drafts',
    category: 'Beneficiary',
    active: Icons.cloud_sync_rounded,
    outline: Icons.cloud_sync_outlined,
    accentColor: AppColors.amber,
  );

  static const beneficiaryHistory = VectorIconEntry(
    key: 'beneficiary_history',
    label: 'Beneficiary Archive',
    purpose: 'Digitized statewide mortal remains transfer records and history',
    category: 'Beneficiary',
    active: Icons.manage_history_rounded,
    outline: Icons.manage_history_outlined,
    accentColor: AppColors.muted,
  );

  // ==========================================
  // 3. VEHICLE REPAIRS & MAINTENANCE VECTORS
  // ==========================================
  static const fleetMaintenance = VectorIconEntry(
    key: 'vehicle_maintenance',
    label: 'Maintenance Dashboard',
    purpose: '17-workflow workshop job-cards, preventive maintenance, and tyre logs',
    category: 'Maintenance',
    active: Icons.build_circle_rounded,
    outline: Icons.build_circle_outlined,
    accentColor: AppColors.roleFleetManager,
  );

  static const compliance = VectorIconEntry(
    key: 'compliance',
    label: 'Compliance & Expirations',
    purpose: 'Fitness Certificate (FC), Insurance, PUC, and Tax renewal alerts',
    category: 'Maintenance',
    active: Icons.verified_user_rounded,
    outline: Icons.verified_user_outlined,
    accentColor: AppColors.danger,
  );

  // ==========================================
  // 4. FLEET & TELEMATICS VECTORS
  // ==========================================
  static const vehicleManagement = VectorIconEntry(
    key: 'vehicles',
    label: 'Vehicle Management',
    purpose: 'Statewide hearse fleet inventory, district allocation, and readiness',
    category: 'Fleet',
    active: Icons.airport_shuttle_rounded,
    outline: Icons.airport_shuttle_outlined,
    accentColor: AppColors.roleFleetManager,
  );

  static const ambulance = VectorIconEntry(
    key: 'ambulance',
    label: 'Hearse Ambulance',
    purpose: 'Specialized 108 Free Hearse Ambulance Van & Mortuary Transit vehicle',
    category: 'Fleet',
    active: Icons.airport_shuttle_rounded,
    outline: Icons.airport_shuttle_outlined,
    accentColor: AppColors.yellow,
  );

  static const offroadManagement = VectorIconEntry(
    key: 'offroad',
    label: 'Off-Road Fleet',
    purpose: 'Accidental, major workshop breakdown, and grounding telemetry',
    category: 'Fleet',
    active: Icons.car_crash_rounded,
    outline: Icons.car_crash_outlined,
    accentColor: AppColors.danger,
  );

  static const gpsTracking = VectorIconEntry(
    key: 'gps',
    label: 'GPS Tracking',
    purpose: 'Real-time multi-satellite GPS locator, geo-fencing, and live breadcrumbs',
    category: 'Fleet',
    active: Icons.satellite_alt_rounded,
    outline: Icons.satellite_alt_outlined,
    accentColor: AppColors.roleAdmin,
  );

  // ==========================================
  // 5. MANAGEMENT & GOVERNANCE VECTORS
  // ==========================================
  static const projects = VectorIconEntry(
    key: 'projects',
    label: 'Project',
    purpose: 'Public-private health mission contract scope & service agreements',
    category: 'Management',
    active: Icons.business_center_rounded,
    outline: Icons.business_center_outlined,
    accentColor: AppColors.teal,
  );

  static const templates = VectorIconEntry(
    key: 'templates',
    label: 'Templates',
    purpose: 'Standard operating procedure (SOP) blueprints and checklist formats',
    category: 'Management',
    active: Icons.description_rounded,
    outline: Icons.description_outlined,
    accentColor: AppColors.purple,
  );

  static const users = VectorIconEntry(
    key: 'users',
    label: 'Users',
    purpose: 'Workforce RBAC directory, security profiles, and credential control',
    category: 'Management',
    active: Icons.group_rounded,
    outline: Icons.group_outlined,
    accentColor: AppColors.roleAdmin,
  );

  static const vehicleDrivers = VectorIconEntry(
    key: 'vehicle_drivers',
    label: 'Vehicle Drivers',
    purpose: 'Pilot/driver rostering, hearse assignment pairing, and phone contacts',
    category: 'Management',
    active: Icons.badge_rounded,
    outline: Icons.badge_outlined,
    accentColor: AppColors.roleDriver,
  );

  static const geography = VectorIconEntry(
    key: 'geography',
    label: 'Geography',
    purpose: 'District zones, hospital mortuary coordinates, and regional coverage',
    category: 'Management',
    active: Icons.map_rounded,
    outline: Icons.map_outlined,
    accentColor: AppColors.teal,
  );

  static const importData = VectorIconEntry(
    key: 'import',
    label: 'Import Data',
    purpose: 'Bulk CSV vehicle roster imports and government legacy record migration',
    category: 'Management',
    active: Icons.file_upload_rounded,
    outline: Icons.file_upload_outlined,
    accentColor: AppColors.roleFleetManager,
  );

  static const settings = VectorIconEntry(
    key: 'settings',
    label: 'Settings',
    purpose: 'Application telemetry sync intervals, notifications, and parameters',
    category: 'Management',
    active: Icons.tune_rounded,
    outline: Icons.tune_outlined,
    accentColor: AppColors.muted,
  );

  // ==========================================
  // 6. ACCOUNT & PROFILE VECTORS
  // ==========================================
  static const profile = VectorIconEntry(
    key: 'profile',
    label: 'Profile',
    purpose: 'Personnel credentials, designated district scope, and employee info',
    category: 'Account',
    active: Icons.manage_accounts_rounded,
    outline: Icons.manage_accounts_outlined,
    accentColor: AppColors.purple,
  );

  // ==========================================
  // VECTOR DATABASE REGISTRY MAP
  // ==========================================
  static const Map<String, VectorIconEntry> registry = {
    'dashboard': dashboard,
    'fill_report': fillReport,
    'submissions': submissions,
    'reports': reports,
    'fuel': fuelIntel,
    'breaks': breakLog,
    'feedback': feedback,
    'beneficiary': beneficiaryIntake,
    'live-trip': liveCorridor,
    'drafts': retrievedDrafts,
    'history': beneficiaryHistory,
    'vehicle_maintenance': fleetMaintenance,
    'compliance': compliance,
    'vehicles': vehicleManagement,
    'ambulance': ambulance,
    'offroad': offroadManagement,
    'gps': gpsTracking,
    'projects': projects,
    'templates': templates,
    'users': users,
    'vehicle_driver_management': vehicleDrivers,
    'geography': geography,
    'import': importData,
    'settings': settings,
    'profile': profile,
  };

  /// Lookup a vector entry by its module key with a reliable fallback
  static VectorIconEntry getByModuleKey(String moduleKey) {
    return registry[moduleKey] ?? dashboard;
  }

  /// Render vector icon directly for a module key
  static Widget buildVector(
    String moduleKey, {
    double size = 20,
    Color? color,
    bool isOutline = false,
  }) {
    final entry = getByModuleKey(moduleKey);
    return entry.render(size: size, color: color, isOutline: isOutline);
  }
}
