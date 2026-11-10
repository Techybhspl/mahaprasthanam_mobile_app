import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class TelematicsService {
  Future<bool> checkPermission() async {
    try {
      final status = await Geolocator.checkPermission();
      return status == LocationPermission.always || status == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  Future<Position?> getCurrentCoordinates() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (e) {
      debugPrint('Failed to get location coordinates: $e');
      return null;
    }
  }

  String formatWatermark({
    required Position? position,
    required String vehicleNumber,
    required String odoType, // 'START' or 'END'
    int? odometerReading,
  }) {
    final nowStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final coordStr = position != null
        ? '${position.latitude.toStringAsFixed(4)}°N, ${position.longitude.toStringAsFixed(4)}°E'
        : 'GPS: Station Depot';
    final odoStr = odometerReading != null ? ' | ODO: $odometerReading KM' : '';

    return 'MAHAPRASTHANAM • $vehicleNumber • $odoType$odoStr\n$coordStr • $nowStr';
  }
}
