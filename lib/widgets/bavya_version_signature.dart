import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'brand_logo.dart';

/// An official signature and version badge for the side menu and footer
class BavyaVersionSignature extends StatelessWidget {
  final bool isDark;
  final String versionString;

  const BavyaVersionSignature({
    super.key,
    this.isDark = false,
    this.versionString = 'v1.0.0+1',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App Version Highlight Pill
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          AppColors.roleAdmin.withValues(alpha: 0.25),
                          AppColors.purple.withValues(alpha: 0.25),
                        ]
                      : [
                          const Color(0xFFE0F2FE),
                          const Color(0xFFF1F5F9),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.roleAdmin.withValues(alpha: 0.4) : const Color(0xFFBAE6FD),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'APP $versionString • STABLE',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0369A1),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // BAVYA Logo Emblem & Signature
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/bavya_logo.png',
                  height: 20,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => Image.asset(
                    'assets/images/bavya-icon.png',
                    height: 20,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx2, err2, stack2) => const Icon(
                      Icons.local_hospital_rounded,
                      size: 18,
                      color: AppColors.purple,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'POWERED BY BAVYA',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.purple,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // 4-Color Signature Accent Bar
          const SizedBox(
            width: 80,
            child: BavyaAccentLine(height: 2.5),
          ),

          const SizedBox(height: 6),

          Text(
            'Govt. of Andhra Pradesh • Free Hearse Operations',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white54 : AppColors.muted,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
