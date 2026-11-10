import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahaprastanam/models/maintenance_model.dart';
import 'package:mahaprastanam/models/offroad_model.dart';
import 'package:mahaprastanam/models/user_role.dart';
import 'package:mahaprastanam/services/submissions_review_service.dart';

void main() {
  group('Role Hierarchy & IT Weights Unit Tests', () {
    test('IT weight values are assigned correctly across all 15 roles', () {
      expect(UserRole.driver.hierarchyLevel, 1.0);
      expect(UserRole.staff.hierarchyLevel, 1.0);
      expect(UserRole.boe.hierarchyLevel, 1.0);
      expect(UserRole.hr.hierarchyLevel, 1.5);
      expect(UserRole.oe.hierarchyLevel, 2.0);
      expect(UserRole.zm.hierarchyLevel, 2.0);
      expect(UserRole.districtManager.hierarchyLevel, 2.0);
      expect(UserRole.fe.hierarchyLevel, 3.0);
      expect(UserRole.rm.hierarchyLevel, 3.0);
      expect(UserRole.fleetManager.hierarchyLevel, 3.0);
      expect(UserRole.sfm.hierarchyLevel, 4.0);
      expect(UserRole.sfh.hierarchyLevel, 5.0);
      expect(UserRole.spm.hierarchyLevel, 6.0);
      expect(UserRole.coo.hierarchyLevel, 7.0);
      expect(UserRole.admin.hierarchyLevel, 8.0);
    });

    test('Submission review hierarchy rule: IT[reviewer] > IT[submitter] and IT >= 2.0', () {
      // Driver (1.0), Staff (1.0), BOE (1.0), HR (1.5) are Level 1, cannot review
      expect(UserRole.driver.canReviewSubmissionsOf(UserRole.driver), isFalse);
      expect(UserRole.boe.canReviewSubmissionsOf(UserRole.driver), isFalse);
      expect(UserRole.hr.canReviewSubmissionsOf(UserRole.driver), isFalse);

      // District Manager (2.0) is Level 2+, outranks Driver (1.0), Staff (1.0), BOE (1.0), HR (1.5)
      expect(UserRole.districtManager.canReviewSubmissionsOf(UserRole.driver), isTrue);
      expect(UserRole.districtManager.canReviewSubmissionsOf(UserRole.boe), isTrue);
      expect(UserRole.districtManager.canReviewSubmissionsOf(UserRole.hr), isTrue);

      // District Manager (2.0) does NOT outrank Fleet Manager (3.0) or FE (3.0)
      expect(UserRole.districtManager.canReviewSubmissionsOf(UserRole.fleetManager), isFalse);

      // Fleet Manager (3.0) and FE (3.0) outrank DM (2.0) and Driver (1.0)
      expect(UserRole.fleetManager.canReviewSubmissionsOf(UserRole.districtManager), isTrue);
      expect(UserRole.fleetManager.canReviewSubmissionsOf(UserRole.driver), isTrue);
      expect(UserRole.fe.canReviewSubmissionsOf(UserRole.driver), isTrue);

      // SFM (4.0) outranks Fleet Manager (3.0)
      expect(UserRole.sfm.canReviewSubmissionsOf(UserRole.fleetManager), isTrue);

      // Admin (8.0) can review anyone
      for (final role in UserRole.values) {
        expect(UserRole.admin.canReviewSubmissionsOf(role), isTrue);
      }
    });

    test('Multi-wave off-road approval matrix rules', () {
      // Wave 1: DM, RM, SFM, SFH, COO, ADMIN
      expect(UserRole.driver.canApproveWave(1), isFalse);
      expect(UserRole.districtManager.canApproveWave(1), isTrue);
      expect(UserRole.rm.canApproveWave(1), isTrue);

      // Wave 2: SFM, SFH, COO, ADMIN
      expect(UserRole.districtManager.canApproveWave(2), isFalse);
      expect(UserRole.sfm.canApproveWave(2), isTrue);
      expect(UserRole.sfh.canApproveWave(2), isTrue);

      // Wave 3: COO, ADMIN only
      expect(UserRole.sfm.canApproveWave(3), isFalse);
      expect(UserRole.coo.canApproveWave(3), isTrue);
      expect(UserRole.admin.canApproveWave(3), isTrue);
    });
  });

  group('Off-Road Incident & Wave Cost Rules', () {
    test('Cost threshold calculation for required wave', () {
      expect(OffroadIncident.requiredWaveForCost(4500.0), 1);
      expect(OffroadIncident.requiredWaveForCost(10000.0), 1);
      expect(OffroadIncident.requiredWaveForCost(10001.0), 2);
      expect(OffroadIncident.requiredWaveForCost(50000.0), 2);
      expect(OffroadIncident.requiredWaveForCost(50001.0), 3);
      expect(OffroadIncident.requiredWaveForCost(120000.0), 3);
    });

    test('OffroadIncident JSON round-trip serialization', () {
      final incident = OffroadIncident(
        id: 701,
        vehicleId: 16,
        vehicleNumber: 'AP-16-MP-1044',
        district: 'Guntur',
        incidentDate: DateTime(2026, 10, 27),
        location: 'Mangalagiri Depot Gate 2',
        reason: 'Alternator failure & burnt wiring harness',
        estimatedCost: 9200.0,
        currentWave: 1,
        status: 'WAVE1_PENDING',
      );

      final json = incident.toJson();
      expect(json['id'], 701);
      expect(json['vehicle_number'], 'AP-16-MP-1044');
      expect(json['district'], 'Guntur');
      expect(json['estimated_cost'], 9200.0);
      expect(json['current_wave'], 1);
      expect(json['status'], 'WAVE1_PENDING');

      final restored = OffroadIncident.fromJson(json);
      expect(restored.id, 701);
      expect(restored.vehicleNumber, 'AP-16-MP-1044');
      expect(restored.estimatedCost, 9200.0);
      expect(restored.currentWave, 1);
    });
  });

  group('Maintenance & Compliance Alert Tests', () {
    test('MaintenanceRecord serialization', () {
      final record = MaintenanceRecord(
        id: 301,
        vehicleId: 10,
        vehicleNumber: 'AP-16-MP-1042',
        maintenanceType: 'TYRE',
        description: 'Front dual tyre change',
        cost: 16000.0,
        invoiceNumber: 'INV-7721',
        serviceCenter: 'MRF Tyres Vijayawada',
        recordDate: DateTime(2026, 10, 25),
        odometerReading: 45000,
        status: 'COMPLETED',
      );

      final json = record.toJson();
      expect(json['cost'], 16000.0);
      expect(json['maintenance_type'], 'TYRE');
      expect(json['odometer_reading'], 45000);

      final restored = MaintenanceRecord.fromJson(json);
      expect(restored.id, 301);
      expect(restored.cost, 16000.0);
      expect(restored.maintenanceType, 'TYRE');
      expect(restored.serviceCenter, 'MRF Tyres Vijayawada');
    });

    test('ComplianceAlert statusColor logic', () {
      final expired = ComplianceAlert(
        vehicleId: 1,
        vehicleNumber: 'AP-16-MP-1040',
        district: 'NTR',
        complianceType: 'FITNESS',
        expiryDate: DateTime.now().subtract(const Duration(days: 2)),
        daysRemaining: -2,
        status: 'CRITICAL',
      );
      expect(expired.statusColor.toARGB32(), const Color(0xFFE53935).toARGB32());

      final expiringSoon = ComplianceAlert(
        vehicleId: 2,
        vehicleNumber: 'AP-16-MP-1041',
        district: 'Guntur',
        complianceType: 'PUC',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        daysRemaining: 5,
        status: 'EXPIRING_SOON',
      );
      expect(expiringSoon.statusColor.toARGB32(), const Color(0xFFF57C00).toARGB32());

      final valid = ComplianceAlert(
        vehicleId: 3,
        vehicleNumber: 'AP-16-MP-1042',
        district: 'Krishna',
        complianceType: 'INSURANCE',
        expiryDate: DateTime.now().add(const Duration(days: 60)),
        daysRemaining: 60,
        status: 'VALID',
      );
      expect(valid.statusColor.toARGB32(), const Color(0xFF2E7D32).toARGB32());
    });
  });

  group('PendingSubmission Model Unit Tests', () {
    test('PendingSubmission parse and check data mapping', () {
      final sub = PendingSubmission.fromJson({
        'id': 401,
        'template_id': 1,
        'template_title': 'Daily Hearse Van Trip Log',
        'vehicle_id': 12,
        'vehicle_number': 'AP-16-MP-1042',
        'submitted_by_role': 'DRIVER',
        'submitter_name': 'Ravi Kumar',
        'submission_date': '2026-10-27T08:30:00Z',
        'status': 'PENDING',
        'data': {
          'closing_odo': 45310,
          'fuel_litres': 25,
        },
      });

      expect(sub.id, 401);
      expect(sub.submittedByRole, 'DRIVER');
      expect(sub.vehicleNumber, 'AP-16-MP-1042');
      expect(sub.data['closing_odo'], 45310);
      expect(sub.status, 'PENDING');
    });
  });
}
