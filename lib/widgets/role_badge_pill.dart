import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/user_role.dart';

class RoleBadgePill extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final bool isCompact;
  final bool isDark;
  final VoidCallback? onTap;

  const RoleBadgePill({
    super.key,
    required this.role,
    this.isSelected = false,
    this.isCompact = false,
    this.isDark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = isSelected
        ? role.color
        : (isDark
            ? Colors.white.withValues(alpha: 0.10)
            : role.color.withValues(alpha: 0.08));

    final textColor = isSelected
        ? Colors.white
        : (isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.ink);

    final iconColor = isSelected
        ? Colors.white
        : role.color;

    final borderColor = isSelected
        ? role.color
        : (isDark
            ? Colors.white.withValues(alpha: 0.18)
            : role.color.withValues(alpha: 0.22));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 6 : 10,
            vertical: isCompact ? 7 : 8,
          ),
          decoration: BoxDecoration(
            color: activeBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: role.color.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : role.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  role.icon,
                  size: isCompact ? 14 : 16,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  role.shortLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.roleLabel(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ).copyWith(fontSize: isCompact ? 11.5 : 12.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
