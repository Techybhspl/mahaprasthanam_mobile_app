import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/telematics_service.dart';

class WatermarkedCameraCard extends StatefulWidget {
  final String label;
  final String odoType; // 'START' or 'END'
  final String vehicleNumber;
  final int? odometerReading;
  final String? initialImagePath;
  final Function(String imagePath, String watermarkText) onImageCaptured;

  const WatermarkedCameraCard({
    super.key,
    required this.label,
    required this.odoType,
    required this.vehicleNumber,
    this.odometerReading,
    this.initialImagePath,
    required this.onImageCaptured,
  });

  @override
  State<WatermarkedCameraCard> createState() => _WatermarkedCameraCardState();
}

class _WatermarkedCameraCardState extends State<WatermarkedCameraCard> {
  final ImagePicker _picker = ImagePicker();
  final TelematicsService _telematics = TelematicsService();

  String? _imagePath;
  String? _watermarkText;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImagePath;
  }

  Future<void> _capturePhoto() async {
    setState(() => _isCapturing = true);
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (photo != null) {
        final position = await _telematics.getCurrentCoordinates();
        final watermark = _telematics.formatWatermark(
          position: position,
          vehicleNumber: widget.vehicleNumber,
          odoType: widget.odoType,
          odometerReading: widget.odometerReading,
        );

        setState(() {
          _imagePath = photo.path;
          _watermarkText = watermark;
        });

        widget.onImageCaptured(photo.path, watermark);
      }
    } catch (e) {
      debugPrint('Camera capture error: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _imagePath != null ? AppColors.success.withValues(alpha: 0.5) : AppColors.line,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        _imagePath != null ? Icons.check_circle_rounded : Icons.photo_camera_rounded,
                        color: _imagePath != null ? AppColors.success : AppColors.purple,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.title(color: AppColors.ink).copyWith(fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_imagePath != null) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _capturePhoto,
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.muted),
                    label: Text(
                      'Retake',
                      style: AppTypography.caption(color: AppColors.muted).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_imagePath != null && !kIsWeb && File(_imagePath!).existsSync()) ...[
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.file(
                      File(_imagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                  ),
                  child: Text(
                    _watermarkText ?? 'MAHAPRASTHANAM • GPS & TIMESTAMP WATERMARK',
                    style: AppTypography.caption(color: Colors.white).copyWith(
                      fontSize: 10.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isCapturing ? null : _capturePhoto,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.lineDark,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: _isCapturing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.2),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_a_photo_rounded,
                                  color: AppColors.purple,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap to Capture Photo with GPS Stamp',
                                  style: AppTypography.caption(color: AppColors.muted).copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
