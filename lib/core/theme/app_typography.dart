import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for Mahaprastanam (Increased base font sizes per user request)
class AppTypography {
  AppTypography._();

  // Headings (Outfit)
  static TextStyle h1({Color color = AppColors.ink, FontWeight fontWeight = FontWeight.w700}) {
    return GoogleFonts.outfit(
      fontSize: 30,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.5,
    );
  }

  static TextStyle h2({Color color = AppColors.ink, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.outfit(
      fontSize: 25,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.3,
    );
  }

  static TextStyle h3({Color color = AppColors.ink, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // Titles & Highlights (Poppins)
  static TextStyle title({Color color = AppColors.ink, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.poppins(
      fontSize: 17.5,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle button({Color color = Colors.white, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.3,
    );
  }

  static TextStyle badge({Color color = AppColors.ink, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.2,
    );
  }

  static TextStyle roleLabel({Color color = AppColors.ink, FontWeight fontWeight = FontWeight.w700}) {
    return GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.4,
    );
  }

  // Body & Descriptions (Inter)
  static TextStyle body({Color color = AppColors.ink, FontWeight fontWeight = FontWeight.w400}) {
    return GoogleFonts.inter(
      fontSize: 15,
      fontWeight: fontWeight,
      color: color,
      height: 1.45,
    );
  }

  static TextStyle bodyMedium({Color color = AppColors.ink, FontWeight fontWeight = FontWeight.w500}) {
    return GoogleFonts.inter(
      fontSize: 15,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle subtitle({Color color = AppColors.muted, FontWeight fontWeight = FontWeight.w500}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle caption({Color color = AppColors.muted, FontWeight fontWeight = FontWeight.w400}) {
    return GoogleFonts.inter(
      fontSize: 13,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
