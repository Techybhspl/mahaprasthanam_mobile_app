import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/offroad_model.dart';
import '../models/user_role.dart';

/// Breakdown & Off-Road Incident Service with Multi-Wave Approvals
/// Module: `/offroad`
class OffroadService {
  final ApiClient _apiClient;

  OffroadService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Report vehicle breakdown or off-road condition
  /// Endpoint: POST /offroad
  Future<OffroadIncident?> reportIncident(OffroadIncident incident) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.offroad,
        data: incident.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return OffroadIncident.fromJson(response.data as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error reporting offroad incident: $e');
      return null;
    }
  }

  /// List offroad incidents with optional status or district filters
  /// Endpoint: GET /offroad
  Future<List<OffroadIncident>> getIncidents({
    String? status,
    String? district,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (district != null) queryParams['district'] = district;

      final response = await _apiClient.get(
        ApiConstants.offroad,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List items = response.data is List
            ? response.data
            : (response.data['data'] as List? ?? []);
        return items.map((item) => OffroadIncident.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching offroad incidents: $e');
      return [];
    }
  }

  /// Submit approval / rejection for an offroad wave
  /// Checks role authority against wave requirements
  /// Endpoint: POST /offroad/approvals or PATCH /offroad/:id/approve
  Future<bool> submitWaveApproval({
    required int offroadId,
    required int wave,
    required UserRole userRole,
    required bool isApproved,
    String? remarks,
  }) async {
    // Validate that the user role has wave authority
    if (!userRole.canApproveWave(wave)) {
      debugPrint('Role ${userRole.roleCode} is not authorized to approve Wave $wave');
      return false;
    }

    try {
      final payload = {
        'offroad_id': offroadId,
        'wave': wave,
        'decision': isApproved ? 'APPROVED' : 'REJECTED',
        'role': userRole.roleCode,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      };

      final response = await _apiClient.post(
        ApiConstants.offroadApprovals,
        data: payload,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error submitting wave approval: $e');
      return false;
    }
  }
}
