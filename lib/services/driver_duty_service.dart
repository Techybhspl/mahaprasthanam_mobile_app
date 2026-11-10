import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

/// Driver Duty, Vehicle Assignment, and Pre-check Operations Service
class DriverDutyService {
  final ApiClient _apiClient;

  DriverDutyService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetch vehicle assigned to the authenticated driver
  /// Endpoint: GET /vehicle-drivers/mine
  Future<Map<String, dynamic>?> getMyAssignedVehicle() async {
    try {
      final response = await _apiClient.get(ApiConstants.vehicleDriversMine);
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching assigned vehicle: $e');
      return null;
    }
  }

  /// Carry-forward validation for Odometer reading
  /// Endpoint: GET /submissions/carry-forward/:templateId/:vehicleId
  Future<int?> getCarryForwardOdometer({
    required int templateId,
    required int vehicleId,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.carryForward}/$templateId/$vehicleId',
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final lastOdo = response.data['last_odometer'] ?? response.data['closing_odometer'];
          if (lastOdo != null) {
            return int.tryParse(lastOdo.toString());
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching carry-forward odometer: $e');
      return null;
    }
  }

  /// Log driver duty break (Meal, Rest, Refuel, Maintenance wait)
  /// Endpoint: POST /breaks
  Future<bool> submitDutyBreak({
    required int vehicleId,
    required String breakType, // 'LUNCH', 'TEA', 'REST', 'MAINTENANCE'
    required DateTime startTime,
    DateTime? endTime,
    String? remarks,
  }) async {
    try {
      final payload = {
        'vehicle_id': vehicleId,
        'break_type': breakType,
        'start_time': startTime.toIso8601String(),
        if (endTime != null) 'end_time': endTime.toIso8601String(),
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      };

      final response = await _apiClient.post(
        ApiConstants.breaks,
        data: payload,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error submitting duty break: $e');
      return false;
    }
  }

  /// Query live active beneficiary transit trip for current driver
  /// Endpoint: GET /beneficiaries/live/active
  Future<Map<String, dynamic>?> getActiveTransitTrip() async {
    try {
      final response = await _apiClient.get(ApiConstants.beneficiariesActive);
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error checking active transit trip: $e');
      return null;
    }
  }
}
