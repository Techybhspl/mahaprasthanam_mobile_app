import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'brand_logo.dart';

class BavyaFooter extends StatelessWidget {
  final bool isDark;

  const BavyaFooter({
    super.key,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            text: 'Powered by ',
            style: AppTypography.caption(
              color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.muted,
            ),
            children: [
              TextSpan(
                text: 'BAVYA HEALTH SERVICES',
                style: AppTypography.caption(
                  color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.purple,
                ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.6),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const SizedBox(
          width: 80,
          child: BavyaAccentLine(height: 2.5),
        ),
        const SizedBox(height: 6),
        Text(
          'v1.0.0 • Mahaprastanam Operations Suite',
          style: AppTypography.caption(
            color: isDark ? Colors.white.withValues(alpha: 0.45) : AppColors.muted.withValues(alpha: 0.7),
          ).copyWith(fontSize: 10.5),
        ),
      ],
    );
  }
}
