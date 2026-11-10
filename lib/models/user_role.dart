import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum UserRole {
  driver,
  fleetManager,
  districtManager,
  boe,
  staff,
  hr,
  oe,
  zm,
  fe,
  rm,
  sfm,
  sfh,
  spm,
  coo,
  admin;

  /// Primary mobile roles displayed in the quick role switcher
  static List<UserRole> get primaryMobileRoles => const [
        UserRole.driver,
        UserRole.boe,
        UserRole.fleetManager,
        UserRole.fe,
        UserRole.districtManager,
        UserRole.admin,
      ];

  String get roleCode {
    switch (this) {
      case UserRole.driver:
        return 'DRIVER';
      case UserRole.boe:
        return 'BOE';
      case UserRole.staff:
        return 'STAFF';
      case UserRole.hr:
        return 'HR';
      case UserRole.oe:
        return 'OE';
      case UserRole.districtManager:
        return 'DM';
      case UserRole.zm:
        return 'ZM';
      case UserRole.fleetManager:
        return 'DFM';
      case UserRole.fe:
        return 'FE';
      case UserRole.rm:
        return 'RM';
      case UserRole.sfm:
        return 'SFM';
      case UserRole.sfh:
        return 'SFH';
      case UserRole.spm:
        return 'SPM';
      case UserRole.coo:
        return 'COO';
      case UserRole.admin:
        return 'ADMIN';
    }
  }

  /// Numeric hierarchy level (IT weight) discovered from reverse engineering
  double get hierarchyLevel {
    switch (this) {
      case UserRole.admin:
        return 8.0;
      case UserRole.coo:
        return 7.0;
      case UserRole.spm:
        return 6.0;
      case UserRole.sfh:
        return 5.0;
      case UserRole.sfm:
        return 4.0;
      case UserRole.fleetManager: // DFM
      case UserRole.fe:
      case UserRole.rm:
        return 3.0;
      case UserRole.districtManager: // DM
      case UserRole.zm:
      case UserRole.oe:
        return 2.0;
      case UserRole.hr:
        return 1.5;
      case UserRole.boe:
      case UserRole.staff:
      case UserRole.driver:
        return 1.0;
    }
  }

  /// Rule: Can review submissions if IT[reviewer] > IT[submitter] and IT[reviewer] >= 2.0 (or ADMIN)
  bool canReviewSubmissionsOf(UserRole submitter) {
    if (this == UserRole.admin) return true;
    return hierarchyLevel >= 2.0 && hierarchyLevel > submitter.hierarchyLevel;
  }

  /// Off-road repair approval wave capability
  bool canApproveWave(int waveNumber) {
    if (this == UserRole.admin || this == UserRole.coo) return true;
    if (waveNumber == 1) {
      // Wave 1 (<= ₹10,000): DM, RM, SFM, SFH, SPM, COO, ADMIN
      return hierarchyLevel >= 2.0;
    } else if (waveNumber == 2) {
      // Wave 2 (₹10,001 to ₹50,000): SFM, SFH, SPM, COO, ADMIN
      return hierarchyLevel >= 4.0;
    } else if (waveNumber == 3) {
      // Wave 3 (> ₹50,000): COO, ADMIN
      return hierarchyLevel >= 7.0;
    }
    return false;
  }

  /// Returns the official documented role-specific dashboard API endpoint
  String dashboardEndpoint(int projectId) {
    switch (this) {
      case UserRole.admin:
        return '/dashboard/admin';
      case UserRole.coo:
        return '/dashboard/coo';
      case UserRole.spm:
        return '/dashboard/spm/$projectId';
      case UserRole.rm:
        return '/dashboard/rm/$projectId';
      case UserRole.districtManager:
      case UserRole.zm:
        return '/dashboard/dm/$projectId';
      case UserRole.oe:
      case UserRole.fe:
        return '/dashboard/oe/$projectId';
      case UserRole.hr:
        return '/dashboard/hr/$projectId';
      case UserRole.fleetManager:
      case UserRole.sfm:
      case UserRole.sfh:
        return '/dashboard/fleet/$projectId';
      case UserRole.driver:
      case UserRole.staff:
        return '/dashboard/staff/$projectId';
      case UserRole.boe:
        return '/dashboard/manager/$projectId';
    }
  }

  /// Checks static module access based on verified Role & Permission Matrix
  bool hasStaticPermission(String module) {
    if (this == UserRole.admin) return true;
    switch (module) {
      case 'beneficiary':
        return this == UserRole.boe ||
            this == UserRole.fe ||
            this == UserRole.spm ||
            this == UserRole.sfm ||
            this == UserRole.coo ||
            this == UserRole.sfh ||
            this == UserRole.zm ||
            this == UserRole.driver;
      case 'vehicle_maintenance':
      case 'vehicle_compliance':
        return this == UserRole.fleetManager ||
            this == UserRole.sfm ||
            this == UserRole.sfh ||
            this == UserRole.fe ||
            this == UserRole.spm ||
            this == UserRole.coo ||
            this == UserRole.districtManager ||
            this == UserRole.rm ||
            this == UserRole.zm ||
            this == UserRole.oe ||
            this == UserRole.driver;
      case 'offroad':
        return this != UserRole.hr;
      case 'submissions':
        return hierarchyLevel >= 2.0;
      case 'vehicles':
      case 'vehicle_driver_management':
        return this != UserRole.driver && this != UserRole.hr;
      case 'gps':
        return hierarchyLevel >= 2.0 ||
            this == UserRole.sfh ||
            this == UserRole.sfm ||
            this == UserRole.fe;
      case 'reports':
      case 'fuel':
        return hierarchyLevel >= 2.0 ||
            this == UserRole.fe ||
            this == UserRole.sfm ||
            this == UserRole.sfh;
      case 'breaks':
        return this == UserRole.driver ||
            this == UserRole.staff ||
            this == UserRole.boe ||
            this == UserRole.fe ||
            this == UserRole.sfm ||
            this == UserRole.sfh ||
            this == UserRole.spm;
      case 'driver_home':
      case 'live-trip':
        return this == UserRole.driver || this == UserRole.admin;
      case 'templates':
      case 'users':
      case 'settings':
      case 'projects':
        return this == UserRole.spm || this == UserRole.coo;
      case 'fill_report':
        return true;
      default:
        return false;
    }
  }

  static UserRole fromCode(String code) {
    final clean = code.trim().toUpperCase();
    for (final role in UserRole.values) {
      if (role.roleCode == clean) return role;
    }
    if (clean.contains('DRIVER')) return UserRole.driver;
    if (clean.contains('DFM') || clean.contains('FLEET')) return UserRole.fleetManager;
    if (clean.contains('SFM')) return UserRole.sfm;
    if (clean.contains('SFH') || clean.contains('FH')) return UserRole.sfh;
    if (clean.contains('DM') || clean.contains('DISTRICT')) return UserRole.districtManager;
    if (clean.contains('BOE') || clean.contains('BACK')) return UserRole.boe;
    if (clean.contains('FE') || clean.contains('FIELD')) return UserRole.fe;
    if (clean.contains('OE') || clean.contains('OPS')) return UserRole.oe;
    if (clean.contains('COO')) return UserRole.coo;
    if (clean.contains('SPM')) return UserRole.spm;
    if (clean.contains('ADMIN')) return UserRole.admin;
    return UserRole.driver;
  }

  String get title {
    switch (this) {
      case UserRole.driver:
        return 'Driver';
      case UserRole.boe:
        return 'Back Office Exec (BOE)';
      case UserRole.staff:
        return 'Field Staff';
      case UserRole.hr:
        return 'Human Resources';
      case UserRole.oe:
        return 'Operations Executive';
      case UserRole.districtManager:
        return 'District Manager';
      case UserRole.zm:
        return 'Zonal Manager';
      case UserRole.fleetManager:
        return 'Fleet Manager';
      case UserRole.fe:
        return 'Field Executive (FE)';
      case UserRole.rm:
        return 'Regional Manager';
      case UserRole.sfm:
        return 'State Fleet Manager';
      case UserRole.sfh:
        return 'State Fleet Head';
      case UserRole.spm:
        return 'State Program Manager';
      case UserRole.coo:
        return 'Chief Operating Officer';
      case UserRole.admin:
        return 'System Administrator';
    }
  }

  String get displayName => title;


  String get shortLabel {
    switch (this) {
      case UserRole.driver:
        return 'Driver';
      case UserRole.boe:
        return 'BOE';
      case UserRole.staff:
        return 'Staff';
      case UserRole.hr:
        return 'HR';
      case UserRole.oe:
        return 'OE';
      case UserRole.districtManager:
        return 'District Mgr';
      case UserRole.zm:
        return 'ZM';
      case UserRole.fleetManager:
        return 'Fleet Mgr';
      case UserRole.fe:
        return 'FE';
      case UserRole.rm:
        return 'RM';
      case UserRole.sfm:
        return 'SFM';
      case UserRole.sfh:
        return 'SFH';
      case UserRole.spm:
        return 'SPM';
      case UserRole.coo:
        return 'COO';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get subtitle {
    switch (this) {
      case UserRole.driver:
        return 'Vehicle Crew & Field Trip Operations';
      case UserRole.boe:
        return 'Hospital Call Center & Trip Intake';
      case UserRole.staff:
        return 'Field Support & Operations Team';
      case UserRole.hr:
        return 'Staff Attendance & Roster Management';
      case UserRole.oe:
        return 'Daily Dispatch & Submission Quality';
      case UserRole.districtManager:
        return 'District Operations & Wave 1 Approvals';
      case UserRole.zm:
        return 'Zonal Cluster Operational Oversight';
      case UserRole.fleetManager:
        return 'Depot Fleet Servicing & Off-Road Logs';
      case UserRole.fe:
        return 'Field Inspection & Verification';
      case UserRole.rm:
        return 'Regional Operations & Escalations';
      case UserRole.sfm:
        return 'Statewide Fleet & Wave 2 Approvals';
      case UserRole.sfh:
        return 'State Fleet Head & Technical Approvals';
      case UserRole.spm:
        return 'State Program Governance & Templates';
      case UserRole.coo:
        return 'Executive Operations & Wave 3 Approvals';
      case UserRole.admin:
        return 'Enterprise Administration & Global Config';
    }
  }

  String get dutyDescription {
    switch (this) {
      case UserRole.driver:
        return 'Active field trip management, GPS route navigation, and transit handoff logs.';
      case UserRole.boe:
        return 'Intake of emergency deceased transit calls, hospital liaison, and draft case creation.';
      case UserRole.staff:
        return 'General ground assistance and daily checklist submissions.';
      case UserRole.hr:
        return 'Staff attendance tracking, leave reviews, and crew roster allocations.';
      case UserRole.oe:
        return 'Monitoring vehicle readiness, dispatch quality, and preliminary audit verification.';
      case UserRole.districtManager:
        return 'District-wide service metrics, backup vehicle allocations, and Wave 1 cost approvals.';
      case UserRole.zm:
        return 'Multi-district zonal operations coordination and operational escalation.';
      case UserRole.fleetManager:
        return 'Depot vehicle readiness, driver shift allocation, maintenance, and fleet tracking.';
      case UserRole.fe:
        return 'Physical vehicle inspections, accident verification, and ground compliance audits.';
      case UserRole.rm:
        return 'Regional operations supervision and inter-district fleet mobility.';
      case UserRole.sfm:
        return 'State-level maintenance compliance, off-road coordination, and Wave 2 approvals.';
      case UserRole.sfh:
        return 'Central state fleet technical authority, inventory oversight, and major repairs.';
      case UserRole.spm:
        return 'Statewide program compliance, template management, and government reporting.';
      case UserRole.coo:
        return 'Executive performance governance across all zones and Wave 3 capital approvals.';
      case UserRole.admin:
        return 'Unrestricted system administration, user management, and security controls.';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.driver:
        return Icons.directions_car_filled_rounded;
      case UserRole.boe:
        return Icons.support_agent_rounded;
      case UserRole.staff:
        return Icons.badge_rounded;
      case UserRole.hr:
        return Icons.people_alt_rounded;
      case UserRole.oe:
        return Icons.assignment_turned_in_rounded;
      case UserRole.districtManager:
        return Icons.admin_panel_settings_rounded;
      case UserRole.zm:
        return Icons.share_location_rounded;
      case UserRole.fleetManager:
        return Icons.hub_rounded;
      case UserRole.fe:
        return Icons.fact_check_rounded;
      case UserRole.rm:
        return Icons.map_rounded;
      case UserRole.sfm:
        return Icons.car_repair_rounded;
      case UserRole.sfh:
        return Icons.engineering_rounded;
      case UserRole.spm:
        return Icons.assessment_rounded;
      case UserRole.coo:
        return Icons.business_center_rounded;
      case UserRole.admin:
        return Icons.security_rounded;
    }
  }

  Color get color {
    switch (this) {
      case UserRole.driver:
        return AppColors.roleDriver;
      case UserRole.boe:
        return AppColors.roleBackOffice;
      case UserRole.staff:
        return AppColors.muted;
      case UserRole.hr:
        return const Color(0xFF6A1B9A);
      case UserRole.oe:
        return AppColors.roleFieldExec;
      case UserRole.districtManager:
        return AppColors.roleDistrictManager;
      case UserRole.zm:
        return const Color(0xFFAD1457);
      case UserRole.fleetManager:
        return AppColors.roleFleetManager;
      case UserRole.fe:
        return AppColors.roleFieldExec;
      case UserRole.rm:
        return const Color(0xFF880E4F);
      case UserRole.sfm:
        return const Color(0xFF6A1B9A);
      case UserRole.sfh:
        return const Color(0xFF4A148C);
      case UserRole.spm:
        return AppColors.roleExecutive;
      case UserRole.coo:
        return AppColors.roleExecutive;
      case UserRole.admin:
        return AppColors.roleAdmin;
    }
  }

  String get idLabel {
    switch (this) {
      case UserRole.driver:
        return 'Driver ID Number';
      case UserRole.boe:
        return 'Back Office Officer ID';
      case UserRole.staff:
        return 'Field Staff ID';
      case UserRole.hr:
        return 'HR Employee ID';
      case UserRole.oe:
        return 'Operations Officer ID';
      case UserRole.districtManager:
        return 'District Admin ID';
      case UserRole.zm:
        return 'Zonal Manager ID';
      case UserRole.fleetManager:
        return 'Fleet Officer Badge';
      case UserRole.fe:
        return 'Field Inspector Badge';
      case UserRole.rm:
        return 'Regional Manager ID';
      case UserRole.sfm:
        return 'State Fleet Manager ID';
      case UserRole.sfh:
        return 'State Fleet Head ID';
      case UserRole.spm:
        return 'State Program ID';
      case UserRole.coo:
        return 'Executive Officer ID';
      case UserRole.admin:
        return 'System Admin ID';
    }
  }

  String get idPrefix {
    switch (this) {
      case UserRole.driver:
        return 'DRV-';
      case UserRole.boe:
        return 'BOE-';
      case UserRole.staff:
        return 'STF-';
      case UserRole.hr:
        return 'HR-';
      case UserRole.oe:
        return 'OE-';
      case UserRole.districtManager:
        return 'DM-';
      case UserRole.zm:
        return 'ZM-';
      case UserRole.fleetManager:
        return 'FLT-';
      case UserRole.fe:
        return 'FE-';
      case UserRole.rm:
        return 'RM-';
      case UserRole.sfm:
        return 'SFM-';
      case UserRole.sfh:
        return 'SFH-';
      case UserRole.spm:
        return 'SPM-';
      case UserRole.coo:
        return 'COO-';
      case UserRole.admin:
        return 'ADM-';
    }
  }

  String get defaultIdPlaceholder {
    switch (this) {
      case UserRole.driver:
        return '1042';
      case UserRole.boe:
        return '2010';
      case UserRole.staff:
        return '1105';
      case UserRole.hr:
        return '2201';
      case UserRole.oe:
        return '4102';
      case UserRole.districtManager:
        return '5501';
      case UserRole.zm:
        return '6201';
      case UserRole.fleetManager:
        return '3080';
      case UserRole.fe:
        return '3501';
      case UserRole.rm:
        return '7101';
      case UserRole.sfm:
        return '8001';
      case UserRole.sfh:
        return '8002';
      case UserRole.spm:
        return '9001';
      case UserRole.coo:
        return '9501';
      case UserRole.admin:
        return '9999';
    }
  }

  String get scopeLabel {
    switch (this) {
      case UserRole.driver:
        return 'Assigned Vehicle Unit';
      case UserRole.boe:
        return 'Dispatch Desk / Hospital';
      case UserRole.staff:
        return 'Assigned Field Mandal';
      case UserRole.hr:
        return 'Human Resources Division';
      case UserRole.oe:
      case UserRole.districtManager:
        return 'Supervised District';
      case UserRole.zm:
        return 'Supervised Zone';
      case UserRole.fleetManager:
      case UserRole.fe:
        return 'Depot Hub Location';
      case UserRole.rm:
        return 'Operational Region';
      case UserRole.sfm:
      case UserRole.sfh:
      case UserRole.spm:
      case UserRole.coo:
      case UserRole.admin:
        return 'Statewide Jurisdiction';
    }
  }

  List<String> get scopeOptions {
    switch (this) {
      case UserRole.driver:
        return const [
          'AP-16-MP-1042 (Vijayawada Urban)',
          'AP-07-MP-2081 (Guntur General)',
          'AP-31-MP-3015 (Visakhapatnam)',
          'AP-03-MP-4099 (Tirupati Central)',
        ];
      case UserRole.boe:
        return const [
          'GGH Vijayawada Dispatch Desk',
          'GGH Guntur Emergency Mortuary',
          'KGH Visakhapatnam Control Desk',
          'SVRR Hospital Tirupati Desk',
        ];
      case UserRole.fleetManager:
      case UserRole.fe:
        return const [
          'Central Zone Command Hub - Vijayawada',
          'North Coastal Operations Hub - Vizag',
          'South Rayalaseema Depot - Tirupati',
          'West Godavari Regional Depot - Eluru',
        ];
      case UserRole.districtManager:
      case UserRole.oe:
        return const [
          'NTR / Krishna District Administration',
          'Guntur District Administration',
          'Visakhapatnam District Administration',
          'Tirupati / Chittoor Administration',
          'Kurnool District Administration',
        ];
      case UserRole.zm:
        return const [
          'Zone 1: Srikakulam, Vizianagaram, Visakhapatnam',
          'Zone 2: East Godavari, West Godavari, Krishna',
          'Zone 3: Guntur, Prakasam, Nellore',
          'Zone 4: Chittoor, Kadapa, Anantapur, Kurnool',
        ];
      case UserRole.rm:
        return const [
          'Coastal Andhra Region',
          'Rayalaseema Region',
          'North Andhra Region',
        ];
      case UserRole.staff:
        return const [
          'Vijayawada Urban Cluster',
          'Guntur Rural Cluster',
          'Tirupati Pilgrim Zone',
        ];
      case UserRole.hr:
      case UserRole.sfm:
      case UserRole.sfh:
      case UserRole.spm:
      case UserRole.coo:
      case UserRole.admin:
        return const [
          'Andhra Pradesh State Operations HQ',
        ];
    }
  }
}

