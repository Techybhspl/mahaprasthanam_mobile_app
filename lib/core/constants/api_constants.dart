class ApiConstants {
  ApiConstants._();

  // Production API Base URL
  static const String baseUrl = 'https://one.bhspl.in/mp/api';

  // Scoped Project Configuration
  static const int mahaprastanamProjectId = 4;
  static const String projectName = 'MAHAPRASTHANAM - AP';

  // Auth & Profile Endpoints
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';
  static const String fcmToken = '/auth/fcm-token';
  static const String language = '/auth/language';
  static const String profileStats = '/auth/profile-stats';

  // Beneficiary Deceased Transit Endpoints
  static const String beneficiaries = '/beneficiaries';
  static String beneficiaryDetail(int tripId) => '/beneficiaries/$tripId';
  static const String activeTrip = '/beneficiaries/live/active';
  static const String beneficiariesActive = activeTrip;
  static String tripBodyAction(int tripId, int bodyId) =>
      '/beneficiaries/$tripId/bodies/$bodyId';
  static const String beneficiaryStats = '/beneficiaries/dashboard/stats';
  static const String beneficiaryExport = '/beneficiaries/export';

  // Trip Feedback
  static const String feedbackTrips = '/feedback/trips';
  static String tripFeedback(int tripId) => '/feedback/trip/$tripId';
  static const String feedback = '/feedback';

  // Vehicle & Driver Operations
  static const String myVehicle = '/vehicle-drivers/mine';
  static const String vehicleDriversMine = myVehicle;
  static const String vehicleDrivers = '/vehicle-drivers';
  static String vehicleDriverDetail(int mappingId) =>
      '/vehicle-drivers/$mappingId';
  static const String vehicles = '/vehicles';
  static String vehicleDetail(int id) => '/vehicles/$id';
  static String vehicleHistory(int id) => '/vehicles/$id/history';
  static String vehicleActiveDrivers(int id) => '/vehicles/$id/active-drivers';
  static String projectVehicles(int projectId) => '/projects/$projectId/vehicles';

  // Vehicle Compliance & Metrics
  static const String complianceList = '/vehicles/compliance/list';
  static const String complianceMetrics = '/vehicles/compliance/metrics';
  static const String complianceDashboard = '/vehicles/compliance/dashboard';
  static const String compliance = '/vehicles/compliance';
  static String complianceDetail(int docId) => '/vehicles/compliance/$docId';
  static String approveCompliance(int docId) =>
      '/vehicles/compliance/$docId/approve';
  static String rejectCompliance(int docId) =>
      '/vehicles/compliance/$docId/reject';

  // Maintenance Module
  static const String maintenance = '/maintenance';
  static String maintenanceDetail(int id) => '/maintenance/$id';
  static const String maintenanceAlerts = '/maintenance/alerts';
  static const String maintenanceStats = '/maintenance/dashboard/stats';
  static const String maintenanceExport = '/maintenance/export';

  // Fuel Module
  static const String fuel = '/fuel';
  static String fuelDetail(int id) => '/fuel/$id';
  static const String fuelKpis = '/fuel/kpis';
  static const String fuelDashboard = '/fuel/dashboard';
  static const String fuelGeography = '/fuel/geography';

  // Off-Road (Vehicle Downtime) & Multi-Wave Approval
  static const String offroad = '/offroad';
  static String offroadDetail(int id) => '/offroad/$id';
  static String offroadFull(int id) => '/offroad/$id/full';
  static String offroadClassify(int id) => '/offroad/$id/classify';
  static String offroadIssues(int id) => '/offroad/$id/issues';
  static String offroadParts(int id) => '/offroad/$id/parts';
  static String offroadBills(int id) => '/offroad/$id/bills';
  static String offroadSubmitApproval(int id) =>
      '/offroad/$id/submit-approval';
  static String offroadApproveWave(int id, int wave) =>
      '/offroad/$id/approve/$wave';
  static const String offroadApprovals = '/offroad/approvals';

  // Driver Duty Breaks
  static const String breaks = '/breaks';
  static String breakDetail(int recordId) => '/breaks/$recordId';

  // Submissions & Dynamic Forms
  static const String submissions = '/submissions';
  static String submissionDetail(int id) => '/submissions/$id';
  static const String pendingSubmissions = '/submissions/pending';
  static const String submissionsPending = pendingSubmissions;
  static String checkSubmission(int templateId, int vehicleId, String date) =>
      '/submissions/check/$templateId/$vehicleId/$date';
  static String carryForward(int templateId, int vehicleId) =>
      '/submissions/carry-forward/$templateId/$vehicleId';
  static String reviewSubmission(int id) => '/submissions/$id/review';
  static String requestSubmissionEdit(int id) => '/submissions/$id/request-edit';

  // Templates
  static const String templates = '/templates';
  static String templateDetail(int id) => '/templates/$id';
  static const String validationPresets = '/templates/validation-presets';

  // GPS Telematics
  static const String liveGpsVehicles = '/gps/vehicles';
  static const String gpsHistory = '/gps/history';

  // Media & Attachments
  static const String uploadPhoto = '/photos/upload';
  static String photoFile(String filename) => '/photos/file/$filename';
  static const String uploadAttachment = '/attachments/upload';
  static String attachmentsByModule(String module, int referenceId) =>
      '/attachments/module/$module/$referenceId';

  // Role-Specific Dashboards
  static const String dashboardAdmin = '/dashboard/admin';
  static const String dashboardCoo = '/dashboard/coo';
  static String dashboardManager(int projectId) => '/dashboard/manager/$projectId';
  static String dashboardSpm(int projectId) => '/dashboard/spm/$projectId';
  static String dashboardRm(int projectId) => '/dashboard/rm/$projectId';
  static String dashboardDm(int projectId) => '/dashboard/dm/$projectId';
  static String dashboardOe(int projectId) => '/dashboard/oe/$projectId';
  static String dashboardHr(int projectId) => '/dashboard/hr/$projectId';
  static String dashboardStaff(int projectId) => '/dashboard/staff/$projectId';
  static String dashboardFleet(int projectId) => '/dashboard/fleet/$projectId';
  static const String dashboardFleetAll = '/dashboard/fleet';
  static const String dashboardPendingTasks = '/dashboard/pending-tasks';
  static const String dashboardRecentActivity = '/dashboard/recent-activity';
  static const String dashboardBoeActivity = '/dashboard/boe/activity';

  // Project Settings & Geography
  static String disabledModules(int projectId) =>
      '/settings/disabled-modules/project/$projectId';
  static const String geographyHierarchy = '/geography/hierarchy';
  static const String geographyDistricts = '/geography/districts';

  // System
  static const String healthCheck = '/api/health';

  // Headers
  static const String headerAuthorization = 'Authorization';
  static const String headerActiveRole = 'X-Active-Role';
  static const String headerContentType = 'Content-Type';
  static const String contentTypeJson = 'application/json';
  static const String contentTypeMultipart = 'multipart/form-data';

  // All 26 Administrative Districts of Andhra Pradesh (per System Architecture)
  static const List<String> apDistricts26 = [
    'Alluri Sitharama Raju',
    'Anakapalli',
    'Ananthapuramu',
    'Annamayya',
    'Bapatla',
    'Chittoor',
    'Dr. B.R. Ambedkar Konaseema',
    'East Godavari',
    'Eluru',
    'Guntur',
    'Kakinada',
    'Krishna',
    'Kurnool',
    'Nandyal',
    'NTR (Vijayawada)',
    'Palnadu',
    'Parvathipuram Manyam',
    'Prakasam',
    'Sri Potti Sriramulu Nellore',
    'Sri Sathya Sai',
    'Srikakulam',
    'Tirupati',
    'Visakhapatnam',
    'Vizianagaram',
    'West Godavari',
    'YSR Kadapa',
  ];
}
