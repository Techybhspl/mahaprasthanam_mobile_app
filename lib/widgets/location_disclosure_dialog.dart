import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'gradient_button.dart';

class LocationDisclosureDialog extends StatelessWidget {
  final VoidCallback onConsent;
  final VoidCallback? onDecline;

  const LocationDisclosureDialog({
    super.key,
    required this.onConsent,
    this.onDecline,
  });

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LocationDisclosureDialog(
        onConsent: () => Navigator.of(ctx).pop(true),
        onDecline: () => Navigator.of(ctx).pop(false),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.roleDriver.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppColors.roleDriver,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Location Access Disclosure',
              style: AppTypography.h3(color: AppColors.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Mahaprastanam collects device location data during active deceased transit trips to:',
              style: AppTypography.body(color: AppColors.inkLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            _buildBullet('Verify vehicle transit corridors and dispatch points in real time'),
            _buildBullet('Embed GPS and timestamp proof watermarks onto odometer photos'),
            _buildBullet('Assist government health coordinators with ambulance/hearse tracking'),
            const SizedBox(height: 14),
            Text(
              'Location data is collected strictly during active duty and is encrypted during transmission.',
              style: AppTypography.caption(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GradientButton(
              text: 'Accept & Allow Location',
              gradientColors: const [AppColors.roleDriver, AppColors.brightMagenta],
              onPressed: onConsent,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onDecline ?? () => Navigator.of(context).pop(false),
              child: Text(
                'Not Now',
                style: AppTypography.caption(color: AppColors.muted).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption(color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}
