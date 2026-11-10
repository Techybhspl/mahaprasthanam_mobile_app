import 'package:flutter_test/flutter_test.dart';
import 'package:mahaprastanam/models/beneficiary_trip_model.dart';
import 'package:mahaprastanam/models/trip_body_model.dart';
import 'package:mahaprastanam/models/user_role.dart';

void main() {
  group('UserRole Unit Tests', () {
    test('UserRole prefixes, titles, and labels', () {
      expect(UserRole.driver.idPrefix, 'DRV-');
      expect(UserRole.driver.title, 'Driver');
      expect(UserRole.driver.shortLabel, 'Driver');
      expect(UserRole.driver.idLabel, 'Driver ID Number');

      expect(UserRole.fleetManager.idPrefix, 'FLT-');
      expect(UserRole.fleetManager.title, 'Fleet Manager');
      expect(UserRole.fleetManager.shortLabel, 'Fleet Mgr');
      expect(UserRole.fleetManager.idLabel, 'Fleet Officer Badge');

      expect(UserRole.districtManager.idPrefix, 'DM-');
      expect(UserRole.districtManager.title, 'District Manager');
      expect(UserRole.districtManager.shortLabel, 'District Mgr');
      expect(UserRole.districtManager.idLabel, 'District Admin ID');
    });
  });

  group('TripBodyModel Unit Tests', () {
    test('TripBodyModel serialization and defaults', () {
      const body = TripBodyModel(
        id: 101,
        name: 'Venkata Rao',
        age: 58,
        gender: 'Male',
        caste: 'BC',
        caseType: 'DC',
        dcMlcNumber: 'DC/2026/9821',
        isCovid: false,
      );

      final json = body.toJson();
      expect(json['name'], 'Venkata Rao');
      expect(json['age'], 58);
      expect(json['case_type'], 'DC');
      expect(json['is_covid'], false);

      final restored = TripBodyModel.fromJson(json);
      expect(restored.id, 101);
      expect(restored.name, 'Venkata Rao');
      expect(restored.age, 58);
      expect(restored.gender, 'Male');
      expect(restored.caste, 'BC');
      expect(restored.caseType, 'DC');
      expect(restored.dcMlcNumber, 'DC/2026/9821');
      expect(restored.isCovid, isFalse);
    });

    test('TripBodyModel Medico-Legal Case (MLC) with COVID flag', () {
      const body = TripBodyModel(
        name: 'Suresh Kumar',
        age: 42,
        gender: 'Male',
        caste: 'SC',
        caseType: 'MLC',
        dcMlcNumber: 'MLC-GUNTUR-402',
        isCovid: true,
      );

      final json = body.toJson();
      expect(json['case_type'], 'MLC');
      expect(json['is_covid'], true);

      final restored = TripBodyModel.fromJson(json);
      expect(restored.caseType, 'MLC');
      expect(restored.isCovid, isTrue);
    });
  });

  group('BeneficiaryTripModel Unit Tests', () {
    test('Calculated distance in km (odoEnd - odoStart)', () {
      const trip = BeneficiaryTripModel(
        localId: 'trip_test_01',
        vehicleNumber: 'AP 39 TM 1008',
        vehicleId: 42,
        driverName: 'Ramu K',
        attendantName: 'Ravi Teja',
        attendantPhone: '9876543210',
        hospitalName: 'RIMS Govt Hospital, Kadapa',
        startDistrictId: 1,
        destDistrictId: 1,
        mandalName: 'Pulivendula',
        village: 'Bakrapuram',
        destination: 'Pulivendula, YSR Kadapa',
        odoStart: 45200,
        odoEnd: 45285,
        tripDate: '2026-10-24',
        createdAt: '2026-10-24T12:00:00Z',
        status: 'SUBMITTED',
        bodies: [
          TripBodyModel(
            name: 'Lakshmi Devi',
            age: 64,
            gender: 'Female',
            caste: 'OC',
            caseType: 'DC',
            dcMlcNumber: 'DC/2026/112',
          ),
        ],
      );

      expect(trip.totalKilometers, 85);
      expect(trip.bodies.length, 1);
    });

    test('Multi-body transit trip detection', () {
      const multiTrip = BeneficiaryTripModel(
        localId: 'trip_test_02',
        vehicleNumber: 'AP 16 TJ 5522',
        vehicleId: 19,
        driverName: 'Chaitanya V',
        attendantName: 'Krishna',
        attendantPhone: '9123456789',
        hospitalName: 'GGH Vijayawada',
        startDistrictId: 2,
        destDistrictId: 2,
        mandalName: 'Machilipatnam',
        village: 'Chilakalapudi',
        destination: 'Machilipatnam',
        odoStart: 28000,
        odoEnd: 28070,
        tripDate: '2026-10-24',
        createdAt: '2026-10-24T14:30:00Z',
        status: 'DRAFT',
        bodies: [
          TripBodyModel(
            name: 'Body A',
            age: 30,
            gender: 'Male',
            caste: 'BC',
            caseType: 'DC',
            dcMlcNumber: 'DC-001',
          ),
          TripBodyModel(
            name: 'Body B',
            age: 25,
            gender: 'Female',
            caste: 'BC',
            caseType: 'DC',
            dcMlcNumber: 'DC-002',
          ),
        ],
      );

      expect(multiTrip.bodies.length, 2);
      expect(multiTrip.totalKilometers, 70);
    });

    test('SQLite serialization round-trip', () {
      const original = BeneficiaryTripModel(
        id: 5092,
        localId: 'local_sqlite_101',
        vehicleNumber: 'AP 07 TH 4401',
        vehicleId: 12,
        driverName: 'Koteswara Rao',
        attendantName: 'Anil Kumar',
        attendantPhone: '9440123456',
        hospitalName: 'District Hospital, Guntur',
        startDistrictId: 3,
        destDistrictId: 3,
        mandalName: 'Tenali',
        village: 'Burripalem',
        destination: 'Tenali, Guntur Dt',
        odoStart: 62100,
        odoReach: 62110,
        odoEnd: 62145,
        odoStartImagePath: '/storage/emulated/0/DCIM/odo_start.jpg',
        odoEndImagePath: '/storage/emulated/0/DCIM/odo_end.jpg',
        tripDate: '2026-10-24',
        createdAt: '2026-10-24T16:00:00Z',
        status: 'SUBMITTED',
        isSynced: true,
        bodies: [
          TripBodyModel(
            name: 'Peddaiah',
            age: 72,
            gender: 'Male',
            caste: 'BC',
            caseType: 'DC',
            dcMlcNumber: 'DC-TENALI-889',
          ),
        ],
      );

      final dbMap = original.toDbMap();
      expect(dbMap['vehicle_number'], 'AP 07 TH 4401');
      expect(dbMap['odo_start'], 62100);
      expect(dbMap['odo_end'], 62145);
      expect(dbMap['is_synced'], 1);

      final restored = BeneficiaryTripModel.fromJson(dbMap);
      expect(restored.localId, 'local_sqlite_101');
      expect(restored.vehicleNumber, 'AP 07 TH 4401');
      expect(restored.driverName, 'Koteswara Rao');
      expect(restored.totalKilometers, 45);
      expect(restored.isSynced, isTrue);
      expect(restored.bodies.length, 1);
      expect(restored.bodies.first.name, 'Peddaiah');
    });
  });
}
