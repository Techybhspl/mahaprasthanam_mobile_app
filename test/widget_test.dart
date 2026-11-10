import 'package:flutter_test/flutter_test.dart';
import 'package:mahaprastanam/main.dart';
import 'package:mahaprastanam/screens/login_screen.dart';
import 'package:mahaprastanam/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders branding, govt badge, and role pills', (WidgetTester tester) async {
    await tester.pumpWidget(const MahaprastanamApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Verify SplashScreen is loaded
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('MAHAPRASTHANAM'), findsOneWidget);
    expect(find.text('GOVT. OF ANDHRA PRADESH'), findsOneWidget);

    // Verify all 3 roles are present in the splash preview
    expect(find.text('Driver'), findsOneWidget);
    expect(find.text('Fleet Mgr'), findsOneWidget);
    expect(find.text('District Mgr'), findsOneWidget);

    // Verify Continue to Login button
    expect(find.text('Continue to Login'), findsOneWidget);

    // Settle splash timer
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('SplashScreen manual continue navigates to LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MahaprastanamApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Tap Continue to Login
    final continueBtn = find.text('Continue to Login');
    await tester.tap(continueBtn);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify LoginScreen is shown
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Operations Sign In'), findsOneWidget);
    expect(find.text('Mobile Number / Employee ID'), findsOneWidget);
    expect(find.text('Access Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
