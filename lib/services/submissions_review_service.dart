import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/user_role.dart';

/// Submission Daily Review Model
class PendingSubmission {
  final int id;
  final int templateId;
  final String templateTitle;
  final int vehicleId;
  final String vehicleNumber;
  final String submittedByRole;
  final String submitterName;
  final DateTime submissionDate;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED', 'REQUESTED_EDIT'
  final Map<String, dynamic> data;

  const PendingSubmission({
    required this.id,
    required this.templateId,
    required this.templateTitle,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.submittedByRole,
    required this.submitterName,
    required this.submissionDate,
    required this.status,
    required this.data,
  });

  factory PendingSubmission.fromJson(Map<String, dynamic> json) {
    return PendingSubmission(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      templateId: json['template_id'] is int
          ? json['template_id']
          : int.tryParse(json['template_id']?.toString() ?? '0') ?? 0,
      templateTitle: json['template_title']?.toString() ?? 'Daily Vehicle Submission',
      vehicleId: json['vehicle_id'] is int
          ? json['vehicle_id']
          : int.tryParse(json['vehicle_id']?.toString() ?? '0') ?? 0,
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      submittedByRole: json['submitted_by_role']?.toString() ?? 'DRIVER',
      submitterName: json['submitter_name']?.toString() ?? 'Field Operator',
      submissionDate: json['submission_date'] != null
          ? DateTime.tryParse(json['submission_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: json['status']?.toString() ?? 'PENDING',
      data: json['data'] is Map<String, dynamic> ? json['data'] : {},
    );
  }
}

/// Hierarchical Submissions Review Service
class SubmissionsReviewService {
  final ApiClient _apiClient;

  SubmissionsReviewService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetch pending submissions waiting for approval
  /// Endpoint: GET /submissions/pending
  Future<List<PendingSubmission>> getPendingSubmissions() async {
    try {
      final response = await _apiClient.get(ApiConstants.submissionsPending);
      if (response.statusCode == 200 && response.data != null) {
        final List items = response.data is List
            ? response.data
            : (response.data['data'] as List? ?? []);
        return items.map((item) => PendingSubmission.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching pending submissions: $e');
      return [];
    }
  }

  /// Review a pending submission
  /// Validates whether reviewer has IT weight dominance over submitter
  /// Endpoint: PATCH /submissions/:id/review
  Future<bool> reviewSubmission({
    required int submissionId,
    required UserRole reviewerRole,
    required UserRole submitterRole,
    required String action, // 'APPROVED', 'REJECTED', 'REQUESTED_EDIT'
    String? remarks,
  }) async {
    if (!reviewerRole.canReviewSubmissionsOf(submitterRole)) {
      debugPrint('Reviewer ${reviewerRole.roleCode} lacks hierarchy clearance to review ${submitterRole.roleCode}');
      return false;
    }

    try {
      final payload = {
        'action': action,
        'reviewer_role': reviewerRole.roleCode,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      };

      final response = await _apiClient.patch(
        '${ApiConstants.submissions}/$submissionId/review',
        data: payload,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error reviewing submission: $e');
      return false;
    }
  }
}
