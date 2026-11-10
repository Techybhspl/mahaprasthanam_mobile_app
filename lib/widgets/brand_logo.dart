import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

/// The iconic 4-color horizontal accent line
/// [Yellow -> Orange -> Magenta -> Purple]
class BavyaAccentLine extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const BavyaAccentLine({
    super.key,
    this.height = 4,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
        child: Row(
          mainAxisSize: width == null ? MainAxisSize.max : MainAxisSize.min,
          children: AppColors.logoColors.map((color) {
            return Expanded(
              child: Container(
                height: height,
                color: color,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Official Government & Operations Header Badge
class GovtEmblemBadge extends StatelessWidget {
  final bool isDark;

  const GovtEmblemBadge({
    super.key,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.purple.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : AppColors.purple.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/ap-govt-logo.png',
            height: 20,
            width: 20,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/GOVTLOGO-removebg-preview.png',
              height: 20,
              width: 20,
              errorBuilder: (ctx, err, stack) => const Icon(
                Icons.account_balance_rounded,
                size: 16,
                color: AppColors.amber,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'GOVT. OF ANDHRA PRADESH',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.badge(
                color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.ink,
              ).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Brand Logo & Mahaprastanam Wordmark
class BrandLogo extends StatelessWidget {
  final double height;
  final bool showAccentLine;
  final bool isDark;
  final String? subtitle;

  const BrandLogo({
    super.key,
    this.height = 70,
    this.showAccentLine = true,
    this.isDark = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand Mark
        Image.asset(
          'assets/images/bavya-wordmark.png',
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Elegant Vector Fallback
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.brandGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'BAVYA',
                  style: AppTypography.h1(
                    color: isDark ? Colors.white : AppColors.purple,
                    fontWeight: FontWeight.w900,
                  ).copyWith(letterSpacing: 1.5),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 10),

        // Service Title
        Text(
          'MAHAPRASTHANAM',
          style: AppTypography.h2(
            color: isDark ? Colors.white : AppColors.ink,
            fontWeight: FontWeight.w800,
          ).copyWith(
            fontSize: 21,
            letterSpacing: 2.2,
          ),
        ),

        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: AppTypography.subtitle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.75)
                  : AppColors.muted,
            ).copyWith(fontSize: 12.5, letterSpacing: 0.5),
          ),
        ],

        if (showAccentLine) ...[
          const SizedBox(height: 14),
          const SizedBox(
            width: 120,
            child: BavyaAccentLine(height: 4),
          ),
        ],
      ],
    );
  }
}
