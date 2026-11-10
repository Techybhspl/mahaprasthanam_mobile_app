import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/maintenance_model.dart';

/// Fleet Maintenance & Statutory Compliance Alert Service
/// Module: `/maintenance`
class MaintenanceService {
  final ApiClient _apiClient;

  MaintenanceService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetch vehicle maintenance history
  /// Endpoint: GET /maintenance
  Future<List<MaintenanceRecord>> getRecords({int? vehicleId}) async {
    try {
      final queryParams = vehicleId != null ? {'vehicle_id': vehicleId} : null;
      final response = await _apiClient.get(
        ApiConstants.maintenance,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List items = response.data is List
            ? response.data
            : (response.data['data'] as List? ?? []);
        return items.map((item) => MaintenanceRecord.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching maintenance records: $e');
      return [];
    }
  }

  /// Create a new maintenance entry
  /// Endpoint: POST /maintenance
  Future<bool> createRecord(MaintenanceRecord record) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.maintenance,
        data: record.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error creating maintenance record: $e');
      return false;
    }
  }

  /// Fetch compliance & statutory document expiry alerts (Fitness, Insurance, PUC, Road Tax)
  /// Endpoint: GET /maintenance/alerts
  Future<List<ComplianceAlert>> getComplianceAlerts({String? district}) async {
    try {
      final queryParams = district != null ? {'district': district} : null;
      final response = await _apiClient.get(
        ApiConstants.maintenanceAlerts,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List items = response.data is List
            ? response.data
            : (response.data['data'] as List? ?? []);
        return items.map((item) => ComplianceAlert.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching compliance alerts: $e');
      return [];
    }
  }
}
