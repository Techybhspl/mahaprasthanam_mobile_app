import 'package:flutter_test/flutter_test.dart';
import 'package:mahaprastanam/core/constants/api_constants.dart';
import 'package:mahaprastanam/models/dashboard_stats_model.dart';
import 'package:mahaprastanam/models/user_role.dart';

void main() {
  group('Dashboard Endpoint Role Routing Tests', () {
    test('UserRole.dashboardEndpoint maps every role to the exact documented API endpoint', () {
      const projectId = 4;

      // Executive / Admin
      expect(UserRole.admin.dashboardEndpoint(projectId), ApiConstants.dashboardAdmin);
      expect(UserRole.coo.dashboardEndpoint(projectId), ApiConstants.dashboardCoo);
      expect(UserRole.spm.dashboardEndpoint(projectId), ApiConstants.dashboardSpm(projectId));

      // Regional & Zonal
      expect(UserRole.rm.dashboardEndpoint(projectId), ApiConstants.dashboardRm(projectId));
      expect(UserRole.zm.dashboardEndpoint(projectId), ApiConstants.dashboardDm(projectId));
      expect(UserRole.districtManager.dashboardEndpoint(projectId), ApiConstants.dashboardDm(projectId));

      // Operations & Field Exec
      expect(UserRole.oe.dashboardEndpoint(projectId), ApiConstants.dashboardOe(projectId));
      expect(UserRole.fe.dashboardEndpoint(projectId), ApiConstants.dashboardOe(projectId));

      // Human Resources
      expect(UserRole.hr.dashboardEndpoint(projectId), ApiConstants.dashboardHr(projectId));

      // Fleet Heads & Managers
      expect(UserRole.fleetManager.dashboardEndpoint(projectId), ApiConstants.dashboardFleet(projectId));
      expect(UserRole.sfm.dashboardEndpoint(projectId), ApiConstants.dashboardFleet(projectId));
      expect(UserRole.sfh.dashboardEndpoint(projectId), ApiConstants.dashboardFleet(projectId));

      // Driver & Ground Staff
      expect(UserRole.driver.dashboardEndpoint(projectId), ApiConstants.dashboardStaff(projectId));
      expect(UserRole.staff.dashboardEndpoint(projectId), ApiConstants.dashboardStaff(projectId));

      // Back Office Exec
      expect(UserRole.boe.dashboardEndpoint(projectId), ApiConstants.dashboardManager(projectId));
    });
  });

  group('DashboardStatsModel Unit Tests', () {
    test('DashboardStatsModel.fromJson parses complete live API response format', () {
      final json = {
        'status': 'success',
        'data': {
          'vehicle_status': {
            'total_vehicles': 108,
            'on_road': 98,
            'off_road': 10,
            'backup_vehicles': 12,
          },
          'previous_day': {
            'trips': 142,
            'case_run_km': 18500,
            'fuel_run_km': 19200,
            'fuel_liters': 1680.5,
            'avg_mileage': 11.01,
          },
          'monthly': {
            'trips': 4120,
            'case_run_km': 490000,
            'total_fuel_run_km': 510000,
            'fuel_consumption_liters': 45200.0,
            'avg_mileage_kmpl': 10.84,
          },
          'operational_summary': {
            'today_trips': 38,
            'call_center_executives': 24,
            'cce_present': 22,
            'cce_absent': 2,
            'today_covid_cases': 3,
            'total_covid_cases': 148,
            'consolidate_trips': 4158,
            'previous_month_trips': 3980,
          },
          'zm_list': [
            {
              'name': 'M. Hafeez',
              'zone': 'Rayalaseema 1',
              'trips': 124,
              'case_run_km': 16200,
              'fuel_run_km': 16800,
              'fuel_liters': 1480.0,
            }
          ],
          'call_center_data': [
            {
              'name': 'Uma Devi',
              'inbound': 45,
              'outbound': 12,
              'duration': '04:12:30',
            }
          ],
          'trip_locations_data': [
            {
              'location': 'GGH Vijayawada',
              'count': 18,
            }
          ]
        }
      };

      final model = DashboardStatsModel.fromJson(json);

      expect(model.vehicleStatus.totalVehicles, 108);
      expect(model.vehicleStatus.onRoadVehicles, 98);
      expect(model.vehicleStatus.offRoadVehicles, 10);
      expect(model.vehicleStatus.backupVehicles, 12);

      expect(model.previousDay.trips, 142);
      expect(model.previousDay.caseRunKm, '18,500');
      expect(model.previousDay.fuelRunKm, '19,200');
      expect(model.previousDay.fuelLiters, '1680.5');
      expect(model.previousDay.avgMileage, '11.0 KMPL');

      expect(model.monthly.trips, 4120);
      expect(model.monthly.caseRunKm, '490,000');
      expect(model.monthly.fuelRunKm, '510,000');
      expect(model.monthly.fuelLiters, '45200.0');
      expect(model.monthly.avgMileage, '10.8 KMPL');

      expect(model.opSummary.todayTrips, 38);
      expect(model.opSummary.callCenterExecutives, 24);
      expect(model.opSummary.ccePresent, 22);
      expect(model.opSummary.cceAbsent, 2);
      expect(model.opSummary.todayCovidCases, 3);
      expect(model.opSummary.totalCovidCases, 148);

      expect(model.zmList.length, 1);
      expect(model.zmList.first.name, 'M. Hafeez');
      expect(model.zmList.first.zone, 'Rayalaseema 1');

      expect(model.callCenterList.length, 1);
      expect(model.callCenterList.first.name, 'Uma Devi');
      expect(model.callCenterList.first.inbound, 45);

      expect(model.tripLocationsList.length, 1);
      expect(model.tripLocationsList.first.location, 'GGH Vijayawada');
      expect(model.tripLocationsList.first.count, '18 Trips');
    });

    test('DashboardStatsModel.mergeAuxiliaryData combines live beneficiary, fuel and vehicle data', () {
      final initial = DashboardStatsModel.empty();

      final benStats = {
        'total_trips': 350,
        'today_trips': 14,
        'prev_day_trips': 28,
        'total_km': 42000,
        'today_covid_cases': 2,
        'total_covid_cases': 89,
        'locations': [
          {'location': 'GGH Guntur', 'count': 15}
        ]
      };

      final fuelStats = {
        'total_fuel': 3800.5,
        'avg_mileage': 11.2,
        'total_fuel_run_km': 42500,
      };

      final vehicleList = [
        {'id': 1, 'status': 'ACTIVE', 'is_backup': false},
        {'id': 2, 'status': 'OFF_ROAD', 'is_backup': false},
        {'id': 3, 'status': 'OPERATIONAL', 'is_backup': true},
      ];

      final merged = initial.mergeAuxiliaryData(
        beneficiaryStats: benStats,
        fuelStats: fuelStats,
        vehicleList: vehicleList,
      );

      // Vehicles (Per specification: operational total = total - backup = 3 - 1 = 2; onRoad = operational - offRoad = 2 - 1 = 1)
      expect(merged.vehicleStatus.totalVehicles, 2);
      expect(merged.vehicleStatus.offRoadVehicles, 1);
      expect(merged.vehicleStatus.onRoadVehicles, 1);
      expect(merged.vehicleStatus.backupVehicles, 1);

      // Beneficiaries
      expect(merged.opSummary.todayTrips, 14);
      expect(merged.opSummary.todayCovidCases, 2);
      expect(merged.opSummary.totalCovidCases, 89);
      expect(merged.previousDay.trips, 28);
      expect(merged.monthly.trips, 350);

      // Fuel
      expect(merged.monthly.fuelLiters, '3800.5');
      expect(merged.monthly.avgMileage, '11.2');

      // Locations
      expect(merged.tripLocationsList.length, 1);
      expect(merged.tripLocationsList.first.location, 'GGH Guntur');
      expect(merged.tripLocationsList.first.count, '15 Trips');
    });

    test('DashboardStatsModel parses production backend shapes (needs_attention, hospitals, boe, heatmap)', () {
      final adminJson = {
        'needs_attention': [
          {
            'id': 4,
            'name': 'MAHA PRASTHANAM',
            'vehicles': 55,
            'offroad_open': 2,
            'staff_count': 17,
          }
        ],
        'heatmap': {
          '2026-11-01': {'4': 3},
          '2026-11-02': {'4': 5},
          '2026-11-06': {'4': 3},
        }
      };

      final initial = DashboardStatsModel.fromJson(adminJson);
      expect(initial.vehicleStatus.totalVehicles, 55);
      expect(initial.vehicleStatus.offRoadVehicles, 2);
      expect(initial.vehicleStatus.onRoadVehicles, 53);
      // Monthly trips strictly from live API metrics (0 when not specified in JSON)
      expect(initial.monthly.trips, 0);

      final benStats = {
        'body_funnel': {'PENDING': 1454, 'TRIP_STARTED': 1, 'TRIP_ENDED': 0},
        'funnel': {'PENDING': 1453, 'IN_PROGRESS': 1, 'COMPLETED': 0},
        'hospitals': [
          {'hospital': 'VIJAYAWADA GGH', 'trips': 254},
          {'hospital': 'GUNTUR GGH', 'trips': 214},
        ],
        'boe': [
          {'user': 'Ch.Uma Durga Devi', 'forms': 1760, 'avg_seconds': 126},
          {'user': 'Durga mani', 'forms': 1176, 'avg_seconds': 121},
        ],
      };

      final merged = initial.mergeAuxiliaryData(beneficiaryStats: benStats);
      expect(merged.tripLocationsList.length, 2);
      expect(merged.tripLocationsList.first.location, 'VIJAYAWADA GGH');
      expect(merged.callCenterList.length, 2);
      expect(merged.callCenterList.first.name, 'Ch.Uma Durga Devi');
      expect(merged.opSummary.consolidateTrips, 1454);
      expect(merged.opSummary.todayTrips, 1);
    });

    test('DashboardStatsModel.fromJson parses custom_metrics payload per Mobile API Integration Specification', () {
      final json = {
        'custom_metrics': {
          'row1': {
            'total_vehicles': 54,
            'on_road': 54,
            'off_road': 0,
            'backup_vehicles': 1,
          },
          'row2': {
            'yesterday_trips': 5,
            'yesterday_case_km': 164.0,
            'yesterday_fuel_run_km': 0.0,
            'yesterday_fuel': 0.0,
            'yesterday_avg_mileage': 0.0,
          },
          'row3': {
            'month_trips': 154,
            'month_case_km': 9747.0,
            'month_fuel_run_km': 2693.0,
            'month_fuel': 232.2,
            'month_avg_mileage': 11.6,
          },
          'maha_prasthanam': {
            'cce_present': 5,
            'cce_absent': 0,
            'total_cce': 5,
            'consolidated_trips': 22,
            'last_month_trips': 21,
            'today_calls': 1,
            'today_trips': 0,
            'call_center_data': [
              {
                'duration': '02:57:42',
                'inbound': 1,
                'outbound': 0,
                'user_name': 'CH.UMA DURGA DEVI',
              }
            ]
          },
          'zone_stats_monthly': [
            {
              'case_run_km': 49,
              'fuel': 0,
              'fuel_run_km': 0,
              'trips': 1,
              'vehicles': 1,
              'zm_name': 'D.Pavan kumar',
              'zone_name': 'Capital Zone',
            }
          ]
        }
      };

      final model = DashboardStatsModel.fromJson(json);

      // Row 1: Vehicle Status
      expect(model.vehicleStatus.totalVehicles, 54);
      expect(model.vehicleStatus.onRoadVehicles, 54);
      expect(model.vehicleStatus.offRoadVehicles, 0);
      expect(model.vehicleStatus.backupVehicles, 1);

      // Row 2: Previous Day Performance
      expect(model.previousDay.trips, 5);
      expect(model.previousDay.caseRunKm, '164');
      expect(model.previousDay.fuelRunKm, '0');
      expect(model.previousDay.fuelLiters, '0.0');
      expect(model.previousDay.avgMileage, '0.0 KMPL');

      // Row 3: Monthly Performance
      expect(model.monthly.trips, 154);
      expect(model.monthly.caseRunKm, '9,747');
      expect(model.monthly.fuelRunKm, '2,693');
      expect(model.monthly.fuelLiters, '232.2');
      expect(model.monthly.avgMileage, '11.6 KMPL');

      // Maha Prasthanam Operational Summary & CCE
      expect(model.opSummary.todayTrips, 0);
      expect(model.opSummary.callCenterExecutives, 5);
      expect(model.opSummary.ccePresent, 5);
      expect(model.opSummary.cceAbsent, 0);
      expect(model.opSummary.consolidateTrips, 22);
      expect(model.callCenterList.length, 1);
      expect(model.callCenterList.first.name, 'CH.UMA DURGA DEVI');

      // Trip Locations (18 AP GGH healthcare locations)
      expect(model.tripLocationsList.length, 18);
      expect(model.tripLocationsList.first.location, 'ANANTAPUR GGH');
      expect(model.tripLocationsList.first.count, '0 Trips');

      // ZM Performance
      expect(model.zmList.length, 1);
      expect(model.zmList.first.name, 'D.Pavan kumar');
      expect(model.zmList.first.zone, 'Capital Zone');

      // Merging auxiliary data MUST strictly preserve todayTrips = 0 and today's locations from authoritative maha_prasthanam
      final mergedWithAux = model.mergeAuxiliaryData(
        beneficiaryStats: {
          'body_funnel': {'TRIP_STARTED': 1},
          'funnel': {'IN_PROGRESS': 1},
          'hospitals': [
            {'hospital': 'ELURU GGH', 'trips': 22},
          ],
        },
      );
      expect(mergedWithAux.opSummary.todayTrips, 0);
      expect(mergedWithAux.tripLocationsList.first.count, '0 Trips');
      expect(mergedWithAux.tripLocationsList.first.hasTrips, isFalse);
      expect(mergedWithAux.tripLocationsList.first.tripCount, 0);

      // Verify TripLocationItem with positive count hasTrips == true for highlighting
      const itemWithTrips = TripLocationItem(location: 'ONGOLE GGH', count: '2 Trips');
      expect(itemWithTrips.hasTrips, isTrue);
      expect(itemWithTrips.tripCount, 2);

      const itemZeroTrips = TripLocationItem(location: 'PIDUGURALLA GGH', count: '0 Trips');
      expect(itemZeroTrips.hasTrips, isFalse);
      expect(itemZeroTrips.tripCount, 0);
    });
  });
}
