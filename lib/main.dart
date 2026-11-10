import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/beneficiary_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initializeSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => BeneficiaryProvider(),
        ),
      ],
      child: const MahaprastanamApp(),
    ),
  );
}

class MahaprastanamApp extends StatelessWidget {
  const MahaprastanamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mahaprastanam Fleet Operations',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
