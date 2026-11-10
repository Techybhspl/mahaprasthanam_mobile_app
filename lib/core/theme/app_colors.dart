import 'package:flutter/material.dart';

/// Mahaprastanam / Bavya Brand Colors
/// Built on the official design tokens and 4-color brand gradient bar
class AppColors {
  AppColors._();

  // Core Brand Palette
  static const Color purple = Color(0xFF4A148C);
  static const Color deepPurple = Color(0xFF2E0854);
  static const Color darkSplashBg = Color(0xFF160228);
  static const Color midSplashBg = Color(0xFF280545);
  static const Color magenta = Color(0xFFC2185B);
  static const Color brightMagenta = Color(0xFFCC004C);
  static const Color red = Color(0xFFE53935);
  static const Color orange = Color(0xFFF57C00);
  static const Color amber = Color(0xFFFBB040);
  static const Color yellow = Color(0xFFFABC41);
  static const Color teal = Color(0xFF00695C);

  // Official Logo 4-Color Accent Bar
  static const List<Color> logoColors = [
    Color(0xFFFABC41), // Yellow
    Color(0xFFFB8B00), // Orange
    Color(0xFFCC004C), // Magenta
    Color(0xFF4D148C), // Purple
  ];

  // Brand Gradients
  static const List<Color> brandGradient = [
    purple,
    magenta,
    red,
    orange,
  ];

  static const List<Color> splashGradient = [
    darkSplashBg,
    midSplashBg,
    Color(0xFF38006B),
  ];

  static const List<Color> buttonGradient = [
    brightMagenta,
    purple,
  ];

  static const List<Color> cardGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFFAFAFE),
  ];

  // Role-Specific Accent Colors
  static const Color roleDriver = Color(0xFFF57C00); // Energetic amber/orange
  static const Color roleFleetManager = Color(0xFF7B1FA2); // Vivid Royal Purple (DFM/SFM)
  static const Color roleDistrictManager = Color(0xFFC2185B); // Authority Magenta (DM/RM)
  static const Color roleAdmin = Color(0xFF1A237E); // Executive Deep Navy
  static const Color roleExecutive = Color(0xFF00695C); // Deep Teal (COO/SPM)
  static const Color roleFieldExec = Color(0xFF0277BD); // Sky Blue (FE/OE)
  static const Color roleBackOffice = Color(0xFF4527A0); // Deep Indigo (BOE)

  // Neutrals & Surface Colors
  static const Color ink = Color(0xFF1D1B29);
  static const Color inkLight = Color(0xFF2C283E);
  static const Color muted = Color(0xFF6B6880);
  static const Color line = Color(0xFFECECF2);
  static const Color lineDark = Color(0xFFDCDCE6);
  static const Color bg = Color(0xFFF6F5FB);
  static const Color card = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);

  // Status & Feedback
  static const Color success = Color(0xFF2E7D32);
  static const Color busy = Color(0xFFF9A825);
  static const Color danger = Color(0xFFE53935);
  static const Color info = Color(0xFF1976D2);
  static const Color error = danger;

  // Semantic Aliases
  static const Color textPrimary = ink;
  static const Color textSecondary = muted;
  static const Color lightGrey = bg;
  static const Color roleFleet = roleFleetManager;
  static const Color roleDm = roleDistrictManager;
  static const Color roleBoe = roleBackOffice;
}
