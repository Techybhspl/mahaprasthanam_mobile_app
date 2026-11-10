import 'package:flutter/material.dart';

/// Vehicle Maintenance Record Model
/// Corresponds to backend module: `/maintenance`
class MaintenanceRecord {
  final int? id;
  final int vehicleId;
  final String vehicleNumber;
  final String maintenanceType; // 'SCHEDULED', 'EMERGENCY', 'TYRE', 'BATTERY', 'ALIGNMENT'
  final String description;
  final double cost;
  final String? invoiceNumber;
  final String? serviceCenter;
  final DateTime recordDate;
  final int? odometerReading;
  final String status; // 'PENDING', 'IN_PROGRESS', 'COMPLETED'

  const MaintenanceRecord({
    this.id,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.maintenanceType,
    required this.description,
    required this.cost,
    this.invoiceNumber,
    this.serviceCenter,
    required this.recordDate,
    this.odometerReading,
    this.status = 'COMPLETED',
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      vehicleId: json['vehicle_id'] is int
          ? json['vehicle_id']
          : int.tryParse(json['vehicle_id']?.toString() ?? '0') ?? 0,
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      maintenanceType: json['maintenance_type']?.toString() ?? 'SCHEDULED',
      description: json['description']?.toString() ?? '',
      cost: (json['cost'] is num) ? (json['cost'] as num).toDouble() : double.tryParse(json['cost']?.toString() ?? '0.0') ?? 0.0,
      invoiceNumber: json['invoice_number']?.toString(),
      serviceCenter: json['service_center']?.toString(),
      recordDate: json['record_date'] != null
          ? DateTime.tryParse(json['record_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      odometerReading: json['odometer_reading'] is int
          ? json['odometer_reading']
          : int.tryParse(json['odometer_reading']?.toString() ?? ''),
      status: json['status']?.toString() ?? 'COMPLETED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'vehicle_id': vehicleId,
      'vehicle_number': vehicleNumber,
      'maintenance_type': maintenanceType,
      'description': description,
      'cost': cost,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (serviceCenter != null) 'service_center': serviceCenter,
      'record_date': recordDate.toIso8601String().split('T').first,
      if (odometerReading != null) 'odometer_reading': odometerReading,
      'status': status,
    };
  }
}

/// Regulatory Expiry Alert for Fleet Compliance
/// Covers Fitness, Insurance, Pollution (PUC), and Road Tax
class ComplianceAlert {
  final int vehicleId;
  final String vehicleNumber;
  final String district;
  final String complianceType; // 'FITNESS', 'INSURANCE', 'PUC', 'ROAD_TAX'
  final DateTime expiryDate;
  final int daysRemaining;
  final String status; // 'CRITICAL', 'EXPIRING_SOON', 'VALID'

  const ComplianceAlert({
    required this.vehicleId,
    required this.vehicleNumber,
    required this.district,
    required this.complianceType,
    required this.expiryDate,
    required this.daysRemaining,
    required this.status,
  });

  factory ComplianceAlert.fromJson(Map<String, dynamic> json) {
    return ComplianceAlert(
      vehicleId: json['vehicle_id'] is int
          ? json['vehicle_id']
          : int.tryParse(json['vehicle_id']?.toString() ?? '0') ?? 0,
      vehicleNumber: json['vehicle_number']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      complianceType: json['compliance_type']?.toString() ?? 'FITNESS',
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      daysRemaining: json['days_remaining'] is int
          ? json['days_remaining']
          : int.tryParse(json['days_remaining']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'VALID',
    );
  }

  Color get statusColor {
    if (daysRemaining <= 0) return const Color(0xFFE53935); // Critical expired (Red)
    if (daysRemaining <= 15) return const Color(0xFFF57C00); // Warning expiring soon (Orange)
    return const Color(0xFF2E7D32); // Safe (Green)
  }
}
