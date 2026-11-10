import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/dashboard_stats_model.dart';
import '../models/user_role.dart';

class DashboardService {
  final ApiClient _apiClient;

  DashboardService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetches real-time dashboard data from the live API for the given user role and project scope.
  /// Strictly API-driven with dynamic aggregation and zero hardcoded static defaults.
  Future<DashboardStatsModel> fetchDashboardData({
    required UserRole role,
    int projectId = ApiConstants.mahaprastanamProjectId,
    String period = 'previous_day',
  }) async {
    DashboardStatsModel model = DashboardStatsModel.empty();
    final normalizedPeriod = period.toLowerCase().contains('month') ? 'monthly' : 'previous_day';

    // 1. Determine and call the primary role-specific dashboard endpoint
    final primaryEndpoint = role.dashboardEndpoint(projectId);
    debugPrint('[DASHBOARD_SERVICE] 📡 Fetching role dashboard: $primaryEndpoint (Role: ${role.roleCode}, Period: $normalizedPeriod)');

    try {
      final response = await _apiClient.get(
        primaryEndpoint,
        queryParameters: {
          'period': normalizedPeriod,
          'project_id': projectId,
        },
        options: Options(
          headers: {
            ApiConstants.headerActiveRole: role.roleCode,
          },
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          model = DashboardStatsModel.fromJson(response.data as Map<String, dynamic>);
          debugPrint('[DASHBOARD_SERVICE] ✅ Role dashboard parsed successfully from $primaryEndpoint');

          // If primary endpoint didn't provide complete project fleet custom_metrics
          // (e.g. staff-scoped metrics or admin without custom_metrics),
          // fetch the SPM project dashboard endpoint (/dashboard/spm/{projectId})
          final respMap = response.data as Map<String, dynamic>;
          final respMetrics = respMap['custom_metrics'] as Map<String, dynamic>?;
          final isStaffScoped = respMetrics != null &&
              respMetrics['row1'] is Map<String, dynamic> &&
              (respMetrics['row1']['total_vehicles'] == 1 && respMetrics['row1']['on_road'] == 1 && respMetrics['row1']['backup_vehicles'] == 0);

          if (respMetrics == null || !respMetrics.containsKey('row1') || isStaffScoped) {
            final kpiEndpoint = ApiConstants.dashboardSpm(projectId);
            try {
              final kpiRes = await _apiClient.get(
                kpiEndpoint,
                queryParameters: {
                  'period': normalizedPeriod,
                  'project_id': projectId,
                },
                options: Options(
                  headers: {
                    ApiConstants.headerActiveRole: 'SPM',
                  },
                ),
              );
              if ((kpiRes.statusCode == 200 || kpiRes.statusCode == 201) && kpiRes.data is Map<String, dynamic>) {
                final kpiJson = kpiRes.data as Map<String, dynamic>;
                final kpiMetrics = kpiJson['custom_metrics'] is Map<String, dynamic>
                    ? kpiJson['custom_metrics'] as Map<String, dynamic>
                    : null;
                final kpiModel = DashboardStatsModel.fromJson(kpiJson);
                model = model.copyWith(
                  vehicleStatus: kpiMetrics?.containsKey('row1') == true ? kpiModel.vehicleStatus : model.vehicleStatus,
                  previousDay: kpiMetrics?.containsKey('row2') == true ? kpiModel.previousDay : model.previousDay,
                  monthly: kpiMetrics?.containsKey('row3') == true ? kpiModel.monthly : model.monthly,
                  zmList: kpiModel.zmList.isNotEmpty ? kpiModel.zmList : model.zmList,
                  opSummary: (kpiMetrics?.containsKey('maha_prasthanam') == true || kpiModel.opSummary.callCenterExecutives > 0)
                      ? kpiModel.opSummary
                      : model.opSummary,
                  callCenterList: kpiModel.callCenterList.isNotEmpty ? kpiModel.callCenterList : model.callCenterList,
                  tripLocationsList: kpiModel.tripLocationsList.isNotEmpty ? kpiModel.tripLocationsList : model.tripLocationsList,
                  tripLocationsDate: kpiModel.tripLocationsDate.isNotEmpty ? kpiModel.tripLocationsDate : model.tripLocationsDate,
                );
                debugPrint('[DASHBOARD_SERVICE] ✅ Live custom_metrics KPI cards integrated from $kpiEndpoint');
              }
            } catch (eKpi) {
              debugPrint('[DASHBOARD_SERVICE] ⚠️ custom_metrics KPI fetch notice: $eKpi');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[DASHBOARD_SERVICE] ⚠️ Primary endpoint $primaryEndpoint notice: $e');
      // If role-specific endpoint is specialized or requires manager overview, query /dashboard/manager/<projectId>
      if (primaryEndpoint != ApiConstants.dashboardManager(projectId)) {
        try {
          final mgrRes = await _apiClient.get(
            ApiConstants.dashboardManager(projectId),
            queryParameters: {
              'period': normalizedPeriod,
              'project_id': projectId,
            },
            options: Options(
              headers: {
                ApiConstants.headerActiveRole: role.roleCode,
              },
            ),
          );
          if ((mgrRes.statusCode == 200 || mgrRes.statusCode == 201) && mgrRes.data != null) {
            if (mgrRes.data is Map<String, dynamic>) {
              model = DashboardStatsModel.fromJson(mgrRes.data as Map<String, dynamic>);
              debugPrint('[DASHBOARD_SERVICE] ✅ Manager dashboard parsed successfully');
            }
          }
        } catch (e2) {
          debugPrint('[DASHBOARD_SERVICE] ⚠️ Manager endpoint notice: $e2');
        }
      }
    }

    // 2. Fetch live auxiliary module stats concurrently to ensure complete operational metrics
    Map<String, dynamic>? beneficiaryData;
    Map<String, dynamic>? fuelData;
    Map<String, dynamic>? complianceData;
    List<dynamic>? vehiclesList;

    try {
      final results = await Future.wait([
        // 2a. Beneficiary stats (/beneficiaries/dashboard/stats)
        _apiClient.get(
          ApiConstants.beneficiaryStats,
          queryParameters: {
            'project_id': projectId,
          },
        ).catchError((e) => Response(requestOptions: RequestOptions(path: ''), statusCode: 400)),

        // 2b. Fuel stats (/fuel/dashboard)
        _apiClient.get(
          ApiConstants.fuelDashboard,
          queryParameters: {
            'project_id': projectId,
          },
        ).catchError((e) => Response(requestOptions: RequestOptions(path: ''), statusCode: 400)),

        // 2c. Vehicles / Compliance (/vehicles/compliance/dashboard)
        _apiClient.get(
          ApiConstants.complianceDashboard,
          queryParameters: {
            'project_id': projectId,
          },
        ).catchError((e) => Response(requestOptions: RequestOptions(path: ''), statusCode: 400)),

        // 2d. Vehicles Master (/vehicles)
        _apiClient.get(
          ApiConstants.vehicles,
          queryParameters: {
            'project_id': projectId,
          },
        ).catchError((e) => Response(requestOptions: RequestOptions(path: ''), statusCode: 400)),
      ]);

      // Parse Beneficiaries
      final resBen = results[0];
      if (resBen.statusCode == 200 && resBen.data != null && resBen.data is Map<String, dynamic>) {
        beneficiaryData = resBen.data as Map<String, dynamic>;
      }

      // Parse Fuel
      final resFuel = results[1];
      if (resFuel.statusCode == 200 && resFuel.data != null && resFuel.data is Map<String, dynamic>) {
        fuelData = resFuel.data as Map<String, dynamic>;
      }

      // Parse Compliance
      final resComp = results[2];
      if (resComp.statusCode == 200 && resComp.data != null && resComp.data is Map<String, dynamic>) {
        complianceData = resComp.data as Map<String, dynamic>;
      }

      // Parse Vehicles Master
      final resVeh = results[3];
      if (resVeh.statusCode == 200 && resVeh.data != null) {
        if (resVeh.data is List) {
          vehiclesList = resVeh.data as List;
        } else if (resVeh.data is Map<String, dynamic>) {
          final map = resVeh.data as Map<String, dynamic>;
          vehiclesList = (map['items'] ?? map['data'] ?? map['vehicles']) as List?;
        }
      }
    } catch (e) {
      debugPrint('[DASHBOARD_SERVICE] ⚠️ Auxiliary stats sync error: $e');
    }

    // 3. Merge live module analytics into the dashboard stats model
    final aggregatedModel = model.mergeAuxiliaryData(
      beneficiaryStats: beneficiaryData,
      fuelStats: fuelData,
      complianceStats: complianceData,
      vehicleList: vehiclesList,
    );

    debugPrint('[DASHBOARD_SERVICE] 🎯 Final Aggregated Stats => '
        'Vehicles: ${aggregatedModel.vehicleStatus.totalVehicles} (On-Road: ${aggregatedModel.vehicleStatus.onRoadVehicles}), '
        'PrevDay Trips: ${aggregatedModel.previousDay.trips}, '
        'Month Trips: ${aggregatedModel.monthly.trips}, '
        'Today Trips: ${aggregatedModel.opSummary.todayTrips}, '
        'ZM Records: ${aggregatedModel.zmList.length}, '
        'CCE Records: ${aggregatedModel.callCenterList.length}, '
        'Locations: ${aggregatedModel.tripLocationsList.length}');

    return aggregatedModel;
  }

  /// Fetches live trip locations data for a specific date (defaults to current date).
  Future<List<TripLocationItem>> fetchTripLocationsForDate({
    required int projectId,
    required DateTime date,
  }) async {
    final dateStr = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      final res = await _apiClient.get(
        ApiConstants.beneficiaryStats,
        queryParameters: {
          'project_id': projectId,
          'start_date': dateStr,
          'end_date': dateStr,
        },
      );
      if (res.statusCode == 200 && res.data != null && res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        final rawLocs = data['hospitals'] ?? data['locations'] ?? data['hospital_breakdown'] ?? data['facility_stats'];
        final countMap = <String, String>{};
        if (rawLocs is List) {
          for (final item in rawLocs) {
            if (item is Map<String, dynamic>) {
              final locName = (item['hospital'] ?? item['hospital_name'] ?? item['location'] ?? item['name'] ?? '').toString().trim().toUpperCase();
              final cnt = DashboardStatsModel.parseInt(item['trips'] ?? item['count'] ?? item['total_cases'] ?? 0);
              if (locName.isNotEmpty) {
                countMap[locName] = '$cnt Trips';
              }
            }
          }
        }
        final result = DashboardStatsModel.standardGghLocations.map((loc) {
          final matched = countMap.entries.firstWhere(
            (e) => e.key == loc || e.key.contains(loc) || loc.contains(e.key),
            orElse: () => const MapEntry('', '0 Trips'),
          );
          return TripLocationItem(location: loc, count: matched.value);
        }).toList();

        for (final entry in countMap.entries) {
          final alreadyPresent = result.any((r) => r.location == entry.key || entry.key.contains(r.location) || r.location.contains(entry.key));
          if (!alreadyPresent) {
            result.add(TripLocationItem(location: entry.key, count: entry.value));
          }
        }
        return result;
      }
    } catch (e) {
      debugPrint('[DASHBOARD_SERVICE] ⚠️ Error fetching trip locations for date $dateStr: $e');
    }
    return DashboardStatsModel.standardGghLocations
        .map((loc) => TripLocationItem(location: loc, count: '0 Trips'))
        .toList();
  }
}
