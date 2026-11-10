import 'package:flutter/material.dart';

/// Breakdown & Off-Road Incident Model with Multi-Wave Approvals
/// Corresponds to backend module: `/offroad`
class OffroadIncident {
  final int? id;
  final int vehicleId;
  final String vehicleNumber;
  final String district;
  final DateTime incidentDate;
  final String location;
  final String reason;
  final double estimatedCost;
  final int currentWave; // 1, 2, or 3
  final String status; // 'REPORTED', 'ESTIMATED', 'WAVE1_PENDING', 'WAVE1_APPROVED', 'WAVE2_PENDING', 'WAVE2_APPROVED', 'WAVE3_PENDING', 'APPROVED', 'REJECTED'
  final String? assignedWorkshop;
  final String? replacementVehicleNumber;
  final String? remarks;

  const OffroadIncident({
    this.id,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.district,
    required this.incidentDate,
    required this.location,
    required this.reason,
    required this.estimatedCost,
    this.currentWave = 1,
    this.status = 'REPORTED',
    this.assignedWorkshop,
    this.replacementVehicleNumber,
    this.remarks,
  });

  /// Wave required based on estimated repair amount
  /// Wave 1: <= 10,000 INR
  /// Wave 2: 10,001 - 50,000 INR
  /// Wave 3: > 50,000 INR
  static int requiredWaveForCost(double cost) {
    if (cost <= 10000) return 1;
    if (cost <= 50000) return 2;
    return 3;
  }

  factory OffroadIncident.fromJson(Map<String, dynamic> json) {
    final cost = (json['estimated_cost'] is num)
        ? (json['estimated_cost'] as num).toDouble()
        : double.tryParse(json['estimated_cost']?.toString() ?? '0.0') ?? 0.0;

    return OffroadIncident(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      vehicleId: json['vehicle_id'] is int
          ? json['vehicle_id']
          : int.tryParse(json['vehicle_id']?.toString() ?? '0') ?? 0,
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      incidentDate: json['incident_date'] != null
          ? DateTime.tryParse(json['incident_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      location: json['location']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      estimatedCost: cost,
      currentWave: json['current_wave'] is int
          ? json['current_wave']
          : int.tryParse(json['current_wave']?.toString() ?? '1') ?? 1,
      status: json['status']?.toString() ?? 'REPORTED',
      assignedWorkshop: json['assigned_workshop']?.toString(),
      replacementVehicleNumber: json['replacement_vehicle_number']?.toString(),
      remarks: json['remarks']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'vehicle_id': vehicleId,
      'vehicle_number': vehicleNumber,
      'district': district,
      'incident_date': incidentDate.toIso8601String().split('T').first,
      'location': location,
      'reason': reason,
      'estimated_cost': estimatedCost,
      'current_wave': currentWave,
      'status': status,
      if (assignedWorkshop != null) 'assigned_workshop': assignedWorkshop,
      if (replacementVehicleNumber != null)
        'replacement_vehicle_number': replacementVehicleNumber,
      if (remarks != null) 'remarks': remarks,
    };
  }

  Color get statusBadgeColor {
    switch (status) {
      case 'APPROVED':
        return const Color(0xFF2E7D32);
      case 'REJECTED':
        return const Color(0xFFE53935);
      case 'WAVE1_PENDING':
      case 'WAVE2_PENDING':
      case 'WAVE3_PENDING':
      case 'REPORTED':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF1976D2);
    }
  }
}
