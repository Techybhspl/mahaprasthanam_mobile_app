import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahaprastanam/models/user_role.dart';
import 'package:mahaprastanam/providers/auth_provider.dart';
import 'package:mahaprastanam/providers/beneficiary_provider.dart';
import 'package:mahaprastanam/screens/beneficiary/beneficiary_form_screen.dart';
import 'package:mahaprastanam/screens/beneficiary/live_corridor_screen.dart';
import 'package:mahaprastanam/screens/fleet/gps_tracking_screen.dart';
import 'package:mahaprastanam/screens/fleet/vehicle_management_screen.dart';
import 'package:mahaprastanam/screens/login_screen.dart';
import 'package:mahaprastanam/screens/main/break_log_screen.dart';
import 'package:mahaprastanam/screens/main/feedback_screen.dart';
import 'package:mahaprastanam/screens/management/projects_screen.dart';
import 'package:mahaprastanam/screens/profile/profile_screen.dart';
import 'package:mahaprastanam/screens/role_dashboard_screen.dart';
import 'package:mahaprastanam/widgets/app_bottom_nav_bar.dart';
import 'package:mahaprastanam/widgets/app_drawer.dart';
import 'package:mahaprastanam/widgets/bavya_footer.dart';
import 'package:mahaprastanam/widgets/bavya_version_signature.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});
  Widget buildTestableWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BeneficiaryProvider()),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('LoginScreen renders unified login without widget overflow or exceptions', (WidgetTester tester) async {
    // Set typical compact phone dimensions (360x640)
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Operations Sign In'), findsOneWidget);
    expect(find.text('Mobile Number / Employee ID'), findsOneWidget);
    expect(find.text('Access Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('BeneficiaryFormScreen renders and adds body without widget overflow or exceptions', (WidgetTester tester) async {
    // Set typical compact phone dimensions (360x640)
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableWidget(const BeneficiaryFormScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(BeneficiaryFormScreen), findsOneWidget);

    // Scroll down to ensure + Add Body is visible before tapping
    final addBodyBtn = find.text('+ Add Body');
    if (addBodyBtn.evaluate().isNotEmpty) {
      await tester.ensureVisible(addBodyBtn);
      await tester.pumpAndSettle();
      await tester.tap(addBodyBtn);
      await tester.pumpAndSettle();
    }

    // Verify two profiles exist
    expect(find.text('Deceased Profile #1'), findsOneWidget);
    expect(find.text('Deceased Profile #2'), findsOneWidget);
  });

  testWidgets('RoleDashboardScreen renders and pins BavyaFooter to bottom without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableWidget(
      const RoleDashboardScreen(
        role: UserRole.driver,
        userId: 'DRV-1001',
        scope: 'Telangana Central',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(RoleDashboardScreen), findsOneWidget);
    expect(find.byType(BavyaFooter), findsOneWidget);
    expect(find.textContaining('BAVYA HEALTH SERVICES'), findsOneWidget);
    expect(find.text('End Duty & Sign Out'), findsOneWidget);
  });

  testWidgets('RoleDashboardScreen sign out confirmation logs user out and navigates to LoginScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableWidget(
      const RoleDashboardScreen(
        role: UserRole.driver,
        userId: 'DRV-1001',
        scope: 'Telangana Central',
      ),
    ));
    await tester.pumpAndSettle();

    // Tap the Sign Out icon in the AppBar
    final signOutBtn = find.byTooltip('Sign Out');
    expect(signOutBtn, findsOneWidget);
    await tester.tap(signOutBtn);
    await tester.pumpAndSettle();

    // Verify confirmation dialog appears
    expect(find.text('Are you sure you want to end your current session and sign out of Mahaprastanam Operations?'), findsOneWidget);

    // Tap confirm 'Sign Out' in dialog
    final confirmBtn = find.widgetWithText(ElevatedButton, 'Sign Out');
    expect(confirmBtn, findsOneWidget);
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Verify user is navigated to LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('RoleDashboardScreen renders clean operational layout with all action options delegated to side menu', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableWidget(
      const RoleDashboardScreen(
        role: UserRole.admin,
        userId: '9999900000',
        scope: 'Statewide Unrestricted Governance',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(RoleDashboardScreen), findsOneWidget);
    expect(find.text('SUPER ADMIN • UNRESTRICTED ACCESS'), findsOneWidget);

    // Dashboard sections present
    expect(find.text('VEHICLE STATUS'), findsOneWidget);
    expect(find.text('PREVIOUS DAY PERFORMANCE'), findsOneWidget);
    expect(find.text('MONTHLY PERFORMANCE'), findsOneWidget);
    expect(find.text('Maha Prasthanam Operational Summary'), findsOneWidget);
    expect(find.text('TRIP LOCATIONS DATA'), findsOneWidget);

    // Redundant inline action tiles removed from below TRIP LOCATIONS DATA
    expect(find.text('PATIENT & BENEFICIARY OPERATIONS'), findsNothing);
    expect(find.text('FLEET MAINTENANCE & INCIDENT MANAGEMENT'), findsNothing);
    expect(find.text('APPROVALS & OPERATIONS GOVERNANCE'), findsNothing);
    expect(find.text('TELEMATICS, INTELLIGENCE & ADMINISTRATION'), findsNothing);
  });

  testWidgets('RoleDashboardScreen for Driver delegates workflows to AppDrawer with appropriate role scoping', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableWidget(
      const RoleDashboardScreen(
        role: UserRole.driver,
        userId: 'DRV-1001',
        scope: 'Guntur Central',
      ),
    ));
    await tester.pumpAndSettle();

    // Redundant inline action tiles removed from dashboard
    expect(find.text('PATIENT & BENEFICIARY OPERATIONS'), findsNothing);
    expect(find.text('TELEMATICS, INTELLIGENCE & ADMINISTRATION'), findsNothing);

    // Verify Bottom Navigation Bar is present for Driver with role-tailored destinations
    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(find.text('Intake'), findsOneWidget);
    expect(find.text('Corridor'), findsOneWidget);

    // Open AppDrawer to verify side menu navigation
    final menuBtn = find.byTooltip('Navigation Menu');
    expect(menuBtn, findsOneWidget);
    await tester.tap(menuBtn);
    await tester.pumpAndSettle();

    // Permitted Driver Workflows in AppDrawer (scoped to AppDrawer)
    Finder inDrawer(String label) => find.descendant(of: find.byType(AppDrawer), matching: find.text(label));
    expect(inDrawer('Fill Report'), findsOneWidget);
    expect(inDrawer('Break'), findsOneWidget);
    expect(inDrawer('Live Transit Corridor'), findsOneWidget);
  });

  testWidgets('RoleDashboardScreen left menu bar (AppDrawer) opens and renders all web navigation items for Super Admin', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableWidget(
      const RoleDashboardScreen(
        role: UserRole.admin,
        userId: '9999900000',
        scope: 'Statewide Unrestricted Governance',
      ),
    ));
    await tester.pumpAndSettle();

    // Verify Bottom Navigation Bar for Admin
    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(find.text('Transit'), findsOneWidget);
    expect(find.text('Approvals'), findsOneWidget);

    // Tap the hamburger menu button in AppBar
    final menuBtn = find.byTooltip('Navigation Menu');
    expect(menuBtn, findsOneWidget);
    await tester.tap(menuBtn);
    await tester.pumpAndSettle();

    // Verify AppDrawer opened
    expect(find.byType(AppDrawer), findsOneWidget);
    expect(find.text('SUPER ADMIN'), findsOneWidget);

    Finder inDrawer(String label) => find.descendant(of: find.byType(AppDrawer), matching: find.text(label));

    // Section 1: MAIN
    expect(inDrawer('MAIN'), findsOneWidget);
    expect(inDrawer('Dashboard'), findsOneWidget);
    expect(inDrawer('Fill Report'), findsOneWidget);
    expect(inDrawer('Submissions'), findsOneWidget);
    expect(inDrawer('Reports'), findsOneWidget);
    expect(inDrawer('Fuel Intel'), findsOneWidget);
    expect(inDrawer('Break'), findsOneWidget);
    expect(inDrawer('Feedback'), findsOneWidget);

    // Section 2: BENEFICIARY
    expect(inDrawer('BENEFICIARY'), findsOneWidget);
    expect(inDrawer('New Beneficiary Intake'), findsOneWidget);
    expect(inDrawer('Live Transit Corridor'), findsOneWidget);
    expect(inDrawer('Retrieved Data (Drafts)'), findsOneWidget);
    expect(inDrawer('Beneficiary Data (History)'), findsOneWidget);

    // Section 3: VEHICLE REPAIRS AND MAINTENANCE
    expect(inDrawer('VEHICLE REPAIRS AND MAINTENANCE'), findsOneWidget);
    expect(inDrawer('Maintenance Dashboard (17 Workflows)'), findsOneWidget);
    expect(inDrawer('Compliance & Expirations'), findsOneWidget);

    // Section 4: FLEET
    expect(inDrawer('FLEET'), findsOneWidget);
    expect(inDrawer('Vehicle Management'), findsOneWidget);
    expect(inDrawer('Off-Road'), findsOneWidget);
    expect(inDrawer('GPS Tracking'), findsOneWidget);

    // Section 5: MANAGEMENT
    expect(inDrawer('MANAGEMENT'), findsOneWidget);
    expect(inDrawer('Project'), findsOneWidget);
    expect(inDrawer('Templates'), findsOneWidget);
    expect(inDrawer('Users'), findsOneWidget);
    expect(inDrawer('Vehicle Drivers'), findsOneWidget);
    expect(inDrawer('Geography'), findsOneWidget);
    expect(inDrawer('Import Data'), findsOneWidget);
    expect(inDrawer('Settings'), findsOneWidget);

    // Section 6: ACCOUNT (Sign Out removed from drawer in favor of top-bar and dedicated version signature)
    expect(inDrawer('ACCOUNT'), findsOneWidget);
    expect(inDrawer('Profile'), findsOneWidget);
    expect(inDrawer('Sign Out'), findsNothing);

    // Highlighted App Version & Powered by BAVYA Signature
    expect(find.byType(BavyaVersionSignature), findsOneWidget);
    expect(find.text('POWERED BY BAVYA'), findsOneWidget);
    expect(find.textContaining('v1.0.0+1'), findsOneWidget);
  });

  testWidgets('AppDrawer menu item navigation pushes exact dedicated screens', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(450, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    Future<void> openDrawerAndTap(String itemText) async {
      final menuBtn = find.byTooltip('Navigation Menu');
      await tester.tap(menuBtn);
      await tester.pumpAndSettle();
      final item = find.descendant(of: find.byType(AppDrawer), matching: find.text(itemText));
      expect(item, findsOneWidget);
      await tester.tap(item, warnIfMissed: false);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(buildTestableWidget(
      const RoleDashboardScreen(
        role: UserRole.admin,
        userId: '9999900000',
        scope: 'Statewide Unrestricted Governance',
      ),
    ));
    await tester.pumpAndSettle();

    // 1. Live Transit Corridor -> LiveCorridorScreen
    await openDrawerAndTap('Live Transit Corridor');
    expect(find.byType(LiveCorridorScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(LiveCorridorScreen))).pop();
    await tester.pumpAndSettle();

    // 2. Break -> BreakLogScreen
    await openDrawerAndTap('Break');
    expect(find.byType(BreakLogScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(BreakLogScreen))).pop();
    await tester.pumpAndSettle();

    // 3. Feedback -> FeedbackScreen
    await openDrawerAndTap('Feedback');
    expect(find.byType(FeedbackScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(FeedbackScreen))).pop();
    await tester.pumpAndSettle();

    // 4. Vehicle Management -> VehicleManagementScreen
    await openDrawerAndTap('Vehicle Management');
    expect(find.byType(VehicleManagementScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(VehicleManagementScreen))).pop();
    await tester.pumpAndSettle();

    // 5. GPS Tracking -> GpsTrackingScreen
    await openDrawerAndTap('GPS Tracking');
    expect(find.byType(GpsTrackingScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(GpsTrackingScreen))).pop();
    await tester.pumpAndSettle();

    // 6. Project -> ProjectsScreen
    await openDrawerAndTap('Project');
    expect(find.byType(ProjectsScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(ProjectsScreen))).pop();
    await tester.pumpAndSettle();

    // 7. Profile -> ProfileScreen
    await openDrawerAndTap('Profile');
    expect(find.byType(ProfileScreen), findsOneWidget);
    Navigator.of(tester.element(find.byType(ProfileScreen))).pop();
    await tester.pumpAndSettle();
  });
}
