class DashboardStatsModel {
  final VehicleStatusStats vehicleStatus;
  final PerformanceMetrics previousDay;
  final PerformanceMetrics monthly;
  final List<ZmPerformanceItem> zmList;
  final OpSummaryMetrics opSummary;
  final List<CallCenterItem> callCenterList;
  final List<TripLocationItem> tripLocationsList;
  final String tripLocationsDate;

  static const List<String> standardGghLocations = [
    'ANANTAPUR GGH',
    'ELURU GGH',
    'GUNTUR GGH',
    'KADAPA GGH',
    'KAKINADA GGH',
    'KUPPAM GGH',
    'KURNOOL GGH',
    'MACHILIPATNAM GGH',
    'NANDYAL GGH',
    'NELLORE GGH',
    'ONGOLE GGH',
    'PIDUGURALLA GGH',
    'RAJAHMUNDRY GGH',
    'SRIKAKULAM GGH',
    'TIRUPATI GGH',
    'VIJAYAWADA GGH',
    'VISAKHAPATNAM GGH',
    'VIZIANAGARAM GGH',
  ];

  const DashboardStatsModel({
    required this.vehicleStatus,
    required this.previousDay,
    required this.monthly,
    required this.zmList,
    required this.opSummary,
    required this.callCenterList,
    required this.tripLocationsList,
    this.tripLocationsDate = '',
  });

  factory DashboardStatsModel.empty() {
    return DashboardStatsModel(
      vehicleStatus: VehicleStatusStats.empty(),
      previousDay: PerformanceMetrics.empty(),
      monthly: PerformanceMetrics.empty(),
      zmList: const [],
      opSummary: OpSummaryMetrics.empty(),
      callCenterList: const [],
      tripLocationsList: const [],
      tripLocationsDate: '',
    );
  }

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    // Unnest data wrapper if present
    final root = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return DashboardStatsModel(
      vehicleStatus: VehicleStatusStats.fromJson(root),
      previousDay: PerformanceMetrics.fromDayJson(root, 'previous_day'),
      monthly: PerformanceMetrics.fromMonthJson(root),
      zmList: _parseZmList(root),
      opSummary: OpSummaryMetrics.fromJson(root),
      callCenterList: _parseCallCenterList(root),
      tripLocationsList: _parseTripLocationsList(root),
      tripLocationsDate: _parseTripLocationsDate(root),
    );
  }

  DashboardStatsModel copyWith({
    VehicleStatusStats? vehicleStatus,
    PerformanceMetrics? previousDay,
    PerformanceMetrics? monthly,
    List<ZmPerformanceItem>? zmList,
    OpSummaryMetrics? opSummary,
    List<CallCenterItem>? callCenterList,
    List<TripLocationItem>? tripLocationsList,
    String? tripLocationsDate,
  }) {
    return DashboardStatsModel(
      vehicleStatus: vehicleStatus ?? this.vehicleStatus,
      previousDay: previousDay ?? this.previousDay,
      monthly: monthly ?? this.monthly,
      zmList: zmList ?? this.zmList,
      opSummary: opSummary ?? this.opSummary,
      callCenterList: callCenterList ?? this.callCenterList,
      tripLocationsList: tripLocationsList ?? this.tripLocationsList,
      tripLocationsDate: tripLocationsDate ?? this.tripLocationsDate,
    );
  }

  /// Merges auxiliary live API responses (e.g., /beneficiaries/dashboard/stats, /fuel/dashboard, /vehicles)
  DashboardStatsModel mergeAuxiliaryData({
    Map<String, dynamic>? beneficiaryStats,
    Map<String, dynamic>? fuelStats,
    Map<String, dynamic>? complianceStats,
    List<dynamic>? vehicleList,
  }) {
    var updatedStatus = vehicleStatus;
    var updatedPrevDay = previousDay;
    var updatedMonthly = monthly;
    var updatedOpSummary = opSummary;
    var updatedZm = List<ZmPerformanceItem>.from(zmList);
    var updatedLocations = List<TripLocationItem>.from(tripLocationsList);
    var updatedCallCenter = List<CallCenterItem>.from(callCenterList);

    // 1. Merge Vehicles
    // If vehicleStatus was already populated from official custom_metrics.row1, preserve it as the source of truth.
    if (vehicleList != null && vehicleList.isNotEmpty) {
      int total = vehicleList.length;
      int offRoad = 0;
      int backup = 0;
      for (final v in vehicleList) {
        if (v is Map<String, dynamic>) {
          final status = (v['status'] ?? v['vehicle_status'] ?? '').toString().toUpperCase();
          final isBackup = v['is_backup'] == true ||
              v['operational_state'] == 'BACK_UP' ||
              (v['remarks']?.toString().toUpperCase().contains('BACKUP') ?? false);
          if (isBackup) backup++;
          if (status.contains('OFF') ||
              status.contains('DOWNTIME') ||
              status.contains('MAINTENANCE') ||
              status.contains('INACTIVE') ||
              status.contains('BREAKDOWN')) {
            offRoad++;
          }
        }
      }
      // Per Specification: NO. OF VEHICLES = Operational fleet (excludes backups)
      final operationalTotal = total > backup ? total - backup : total;
      final onRoad = operationalTotal > offRoad ? operationalTotal - offRoad : 0;

      if (updatedStatus.totalVehicles > 0) {
        // Retain verified row1 metrics, backfill auxiliary details if zero
        updatedStatus = VehicleStatusStats(
          totalVehicles: updatedStatus.totalVehicles,
          onRoadVehicles: updatedStatus.onRoadVehicles,
          offRoadVehicles: updatedStatus.offRoadVehicles > 0 ? updatedStatus.offRoadVehicles : offRoad,
          backupVehicles: updatedStatus.backupVehicles > 0 ? updatedStatus.backupVehicles : backup,
        );
      } else {
        updatedStatus = VehicleStatusStats(
          totalVehicles: operationalTotal,
          onRoadVehicles: onRoad,
          offRoadVehicles: offRoad,
          backupVehicles: backup,
        );
      }
    } else if (complianceStats != null && updatedStatus.totalVehicles == 0) {
      final summary = complianceStats['summary'] is Map<String, dynamic>
          ? complianceStats['summary'] as Map<String, dynamic>
          : complianceStats;
      final rawVehicles = complianceStats['vehicles'] is List ? complianceStats['vehicles'] as List : null;
      final total = _parseInt(summary['totalVehicles'] ?? summary['total_vehicles'] ?? summary['total'] ?? rawVehicles?.length);
      final offRoad = _parseInt(summary['expiredDocuments'] ?? summary['off_road'] ?? summary['inactive_vehicles']);
      final backup = _parseInt(summary['backup_vehicles'] ?? summary['backup']);
      final operationalTotal = total > backup ? total - backup : total;
      final onRoad = _parseInt(
        summary['compliantVehicles'] ?? summary['on_road'] ?? summary['active_vehicles'],
        operationalTotal > offRoad ? operationalTotal - offRoad : 0,
      );
      if (operationalTotal > 0) {
        updatedStatus = VehicleStatusStats(
          totalVehicles: operationalTotal,
          onRoadVehicles: onRoad,
          offRoadVehicles: offRoad,
          backupVehicles: backup,
        );
      }
    }

    // 2. Merge Beneficiary Stats (/beneficiaries/dashboard/stats)
    if (beneficiaryStats != null) {
      final bData = beneficiaryStats['data'] is Map<String, dynamic>
          ? beneficiaryStats['data'] as Map<String, dynamic>
          : beneficiaryStats;

      final totalTrips = _parseInt(bData['total_trips'] ?? bData['cases_delivered'] ?? bData['total_cases']);
      final todayTrips = _parseInt(bData['today_trips'] ?? bData['active_transit']);
      final prevDayTrips = _parseInt(bData['prev_day_trips'] ?? bData['yesterday_trips']);
      final covidToday = _parseInt(bData['today_covid_cases'] ?? bData['covid_today']);
      final covidTotal = _parseInt(bData['total_covid_cases'] ?? bData['covid_total']);
      final totalKm = _parseDouble(bData['total_km'] ?? bData['total_kilometers'] ?? bData['distance_km']);

      // Funnel breakdown
      final funnel = bData['funnel'] is Map<String, dynamic> ? bData['funnel'] as Map<String, dynamic> : null;
      final bodyFunnel = bData['body_funnel'] is Map<String, dynamic> ? bData['body_funnel'] as Map<String, dynamic> : null;
      final startedTrips = _parseInt(bodyFunnel?['TRIP_STARTED'] ?? funnel?['IN_PROGRESS']);
      final totalFunnelCases = _parseInt(funnel?['PENDING']) + _parseInt(funnel?['IN_PROGRESS']) + _parseInt(funnel?['COMPLETED']);

      final resolvedTotalCases = totalTrips > 0 ? totalTrips : totalFunnelCases;
      final resolvedTodayTrips = todayTrips > 0 ? todayTrips : startedTrips;

      if (!updatedOpSummary.isFromMahaPrasthanam &&
          (resolvedTodayTrips > 0 || resolvedTotalCases > 0 || covidToday > 0 || covidTotal > 0)) {
        updatedOpSummary = OpSummaryMetrics(
          todayTrips: updatedOpSummary.todayTrips > 0 ? updatedOpSummary.todayTrips : resolvedTodayTrips,
          callCenterExecutives: updatedOpSummary.callCenterExecutives,
          ccePresent: updatedOpSummary.ccePresent,
          cceAbsent: updatedOpSummary.cceAbsent,
          todayCovidCases: updatedOpSummary.todayCovidCases > 0 ? updatedOpSummary.todayCovidCases : covidToday,
          totalCovidCases: updatedOpSummary.totalCovidCases > 0 ? updatedOpSummary.totalCovidCases : covidTotal,
          consolidateTrips: updatedOpSummary.consolidateTrips > 0 ? updatedOpSummary.consolidateTrips : resolvedTotalCases,
          previousMonthTrips: updatedOpSummary.previousMonthTrips > 0
              ? updatedOpSummary.previousMonthTrips
              : _parseInt(bData['previous_month_trips'] ?? bData['prev_month_trips'] ?? 0),
          isFromMahaPrasthanam: false,
        );
      }

      if (prevDayTrips > 0 && updatedPrevDay.trips == 0) {
        updatedPrevDay = updatedPrevDay.copyWith(trips: prevDayTrips);
      }

      if (resolvedTotalCases > 0 || totalKm > 0) {
        updatedMonthly = updatedMonthly.copyWith(
          trips: resolvedTotalCases > 0 && updatedMonthly.trips == 0 ? resolvedTotalCases : updatedMonthly.trips,
          caseRunKm: totalKm > 0 && updatedMonthly.caseRunKm == '0' ? totalKm.toStringAsFixed(0) : updatedMonthly.caseRunKm,
        );
      }

      // Merge hospital / trip location clusters
      final rawLocs = bData['hospitals'] ?? bData['locations'] ?? bData['hospital_breakdown'] ?? bData['facility_stats'];
      if (rawLocs is List && rawLocs.isNotEmpty) {
        final locCountMap = <String, String>{};
        int hospitalTripsSum = 0;
        for (final item in rawLocs) {
          if (item is Map<String, dynamic>) {
            final locName = (item['hospital'] ?? item['hospital_name'] ?? item['location'] ?? item['name'] ?? 'Facility').toString();
            final cnt = _parseInt(item['trips'] ?? item['count'] ?? item['total_cases'] ?? 0);
            hospitalTripsSum += cnt;
            locCountMap[locName] = '$cnt Trips';
          }
        }

        if (!updatedOpSummary.isFromMahaPrasthanam) {
          if (updatedLocations.length >= standardGghLocations.length) {
            // Update matching standard GGH facilities while keeping the complete 18 locations list
            updatedLocations = updatedLocations.map((locItem) {
              final matched = locCountMap.entries.firstWhere(
                (e) => e.key.toUpperCase() == locItem.location.toUpperCase() ||
                    e.key.toUpperCase().contains(locItem.location.toUpperCase()) ||
                    locItem.location.toUpperCase().contains(e.key.toUpperCase()),
                orElse: () => const MapEntry('', ''),
              );
              if (matched.key.isNotEmpty) {
                return TripLocationItem(location: locItem.location, count: matched.value);
              }
              return locItem;
            }).toList();
          } else if (locCountMap.isNotEmpty) {
            updatedLocations = locCountMap.entries.map((e) => TripLocationItem(location: e.key, count: e.value)).toList();
          }
        }

        if (updatedMonthly.trips == 0 && hospitalTripsSum > 0) {
          updatedMonthly = updatedMonthly.copyWith(trips: hospitalTripsSum);
        }
      }

      // Merge Back Office / Call Center Executives
      // Preserve verified maha_prasthanam telephony executives; backfill if empty
      final rawBoe = bData['boe'] ?? bData['call_center_data'] ?? bData['executives'];
      if (rawBoe is List && rawBoe.isNotEmpty && updatedCallCenter.isEmpty) {
        final cceItems = <CallCenterItem>[];
        for (final b in rawBoe) {
          if (b is Map<String, dynamic>) {
            final forms = _parseInt(b['forms'] ?? b['calls'] ?? 0);
            cceItems.add(CallCenterItem(
              name: (b['user'] ?? b['name'] ?? 'Executive').toString(),
              inbound: forms,
              outbound: 0,
              duration: '${b['avg_seconds'] ?? 0}s',
            ));
          }
        }
        if (cceItems.isNotEmpty) {
          updatedCallCenter = cceItems;
          if (updatedOpSummary.callCenterExecutives == 0) {
            updatedOpSummary = updatedOpSummary.copyWith(
              callCenterExecutives: cceItems.length,
              ccePresent: cceItems.length,
              cceAbsent: 0,
            );
          }
        }
      }
    }

    // 3. Merge Fuel Stats (/fuel/dashboard)
    if (fuelStats != null) {
      final fData = fuelStats['data'] is Map<String, dynamic>
          ? fuelStats['data'] as Map<String, dynamic>
          : fuelStats;

      final totalLiters = _parseDouble(fData['total_fuel'] ?? fData['total_litres'] ?? fData['fuel_consumed_liters']);
      final avgMileage = _parseDouble(fData['avg_mileage'] ?? fData['fleet_avg_kmpl'] ?? fData['avg_kmpl']);
      final totalFuelKm = _parseDouble(fData['total_fuel_run_km'] ?? fData['fuel_run_km']);

      if (totalLiters > 0 || avgMileage > 0 || totalFuelKm > 0) {
        updatedMonthly = updatedMonthly.copyWith(
          fuelLiters: totalLiters > 0 ? totalLiters.toStringAsFixed(1) : updatedMonthly.fuelLiters,
          avgMileage: avgMileage > 0 ? avgMileage.toStringAsFixed(1) : updatedMonthly.avgMileage,
          fuelRunKm: totalFuelKm > 0 ? totalFuelKm.toStringAsFixed(0) : updatedMonthly.fuelRunKm,
        );
      }

      // Merge zone-wise breakdown if returned by fuel dashboard
      final rawZones = fData['zones'] ?? fData['zonal_summary'] ?? fData['regions'];
      if (rawZones is List && rawZones.isNotEmpty) {
        final zmItems = <ZmPerformanceItem>[];
        for (final z in rawZones) {
          if (z is Map<String, dynamic>) {
            zmItems.add(ZmPerformanceItem(
              name: z['manager_name'] ?? z['name'] ?? z['zm_name'] ?? 'Zonal Officer',
              zone: z['zone'] ?? z['zone_name'] ?? z['region'] ?? 'Zone',
              trips: (z['trips'] ?? z['total_trips'] ?? '0').toString(),
              caseRunKm: (z['case_run_km'] ?? z['distance_km'] ?? '0').toString(),
              fuelRunKm: (z['fuel_run_km'] ?? '0').toString(),
              fuelLiters: (z['fuel_liters'] ?? z['litres'] ?? '0.0').toString(),
            ));
          }
        }
        if (zmItems.isNotEmpty) {
          updatedZm = zmItems;
        }
      }
    }

    return copyWith(
      vehicleStatus: updatedStatus,
      previousDay: updatedPrevDay,
      monthly: updatedMonthly,
      zmList: updatedZm,
      opSummary: updatedOpSummary,
      callCenterList: updatedCallCenter,
      tripLocationsList: updatedLocations,
    );
  }

  static List<ZmPerformanceItem> _parseZmList(Map<String, dynamic> root) {
    final customMetrics = root['custom_metrics'] is Map<String, dynamic>
        ? root['custom_metrics'] as Map<String, dynamic>
        : null;
    final list = customMetrics?['zone_stats_monthly'] ??
        customMetrics?['zone_stats_yesterday'] ??
        root['zm_list'] ??
        root['zones'] ??
        root['zone_wise'] ??
        root['zonal_performance'];
    if (list is List) {
      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => ZmPerformanceItem.fromJson(item))
          .toList();
    }
    return const [];
  }

  static List<CallCenterItem> _parseCallCenterList(Map<String, dynamic> root) {
    final customMetrics = root['custom_metrics'] is Map<String, dynamic>
        ? root['custom_metrics'] as Map<String, dynamic>
        : null;
    final mp = customMetrics?['maha_prasthanam'] is Map<String, dynamic>
        ? customMetrics!['maha_prasthanam'] as Map<String, dynamic>
        : null;
    final list = mp?['call_center_data'] ??
        root['call_center_data'] ??
        root['call_center_list'] ??
        root['cce_list'] ??
        root['executives'] ??
        root['boe'];
    if (list is List) {
      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => CallCenterItem.fromJson(item))
          .toList();
    }
    return const [];
  }

  static List<TripLocationItem> _parseTripLocationsList(Map<String, dynamic> root) {
    final customMetrics = root['custom_metrics'] is Map<String, dynamic>
        ? root['custom_metrics'] as Map<String, dynamic>
        : null;
    final mp = customMetrics?['maha_prasthanam'] is Map<String, dynamic>
        ? customMetrics!['maha_prasthanam'] as Map<String, dynamic>
        : null;
    final list = mp?['trip_locations_data'] ??
        root['trip_locations_data'] ??
        root['trip_locations'] ??
        root['locations'] ??
        root['hospital_trips'] ??
        root['hospitals'];

    if (list is List && list.isNotEmpty) {
      if (mp != null) {
        final countMap = <String, String>{};
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final loc = (item['location'] ?? item['hospital_name'] ?? item['hospital'] ?? item['name'] ?? '').toString().trim().toUpperCase();
            final rawCount = item['count'] ?? item['trip_count'] ?? item['trips'] ?? 0;
            final countStr = rawCount.toString().endsWith('Trips') ? rawCount.toString() : '$rawCount Trips';
            if (loc.isNotEmpty) countMap[loc] = countStr;
          }
        }
        final result = standardGghLocations.map((loc) {
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

      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => TripLocationItem.fromJson(item))
          .toList();
    }

    if (mp != null) {
      return standardGghLocations
          .map((loc) => TripLocationItem(location: loc, count: '0 Trips'))
          .toList();
    }

    return const [];
  }

  static String _parseTripLocationsDate(Map<String, dynamic> root) {
    final customMetrics = root['custom_metrics'] is Map<String, dynamic>
        ? root['custom_metrics'] as Map<String, dynamic>
        : null;
    final mp = customMetrics?['maha_prasthanam'] is Map<String, dynamic>
        ? customMetrics!['maha_prasthanam'] as Map<String, dynamic>
        : null;
    final d = mp?['trip_locations_date'] ?? root['trip_locations_date'];
    if (d != null && d.toString().trim().isNotEmpty) {
      return d.toString().trim();
    }
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static String _formatKm(double km) {
    if (km == 0.0) return '0';
    final rounded = km.round();
    final str = rounded.toString();
    final regExp = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return str.replaceAll(regExp, ',');
  }

  static int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? fallback;
  }

  static int parseInt(dynamic val, [int fallback = 0]) => _parseInt(val, fallback);

  static double _parseDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? fallback;
  }

  static double parseDouble(dynamic val, [double fallback = 0.0]) => _parseDouble(val, fallback);
}

class VehicleStatusStats {
  final int totalVehicles;
  final int onRoadVehicles;
  final int offRoadVehicles;
  final int backupVehicles;

  const VehicleStatusStats({
    required this.totalVehicles,
    required this.onRoadVehicles,
    required this.offRoadVehicles,
    required this.backupVehicles,
  });

  factory VehicleStatusStats.empty() {
    return const VehicleStatusStats(
      totalVehicles: 0,
      onRoadVehicles: 0,
      offRoadVehicles: 0,
      backupVehicles: 0,
    );
  }

  factory VehicleStatusStats.fromJson(Map<String, dynamic> json) {
    // 1. Check custom_metrics.row1 per Mobile API Integration Specification
    final customMetrics = json['custom_metrics'] is Map<String, dynamic>
        ? json['custom_metrics'] as Map<String, dynamic>
        : null;
    final row1 = customMetrics?['row1'] is Map<String, dynamic>
        ? customMetrics!['row1'] as Map<String, dynamic>
        : null;

    if (row1 != null) {
      final total = DashboardStatsModel._parseInt(row1['total_vehicles']);
      final onRoad = DashboardStatsModel._parseInt(row1['on_road']);
      final offRoad = DashboardStatsModel._parseInt(row1['off_road']);
      final backup = DashboardStatsModel._parseInt(row1['backup_vehicles']);
      if (total > 0 || onRoad > 0 || offRoad > 0 || backup > 0) {
        return VehicleStatusStats(
          totalVehicles: total,
          onRoadVehicles: onRoad,
          offRoadVehicles: offRoad,
          backupVehicles: backup,
        );
      }
    }

    final vObj = json['vehicle_status'] is Map<String, dynamic>
        ? json['vehicle_status'] as Map<String, dynamic>
        : (json['vehicles'] is Map<String, dynamic> ? json['vehicles'] as Map<String, dynamic> : json);

    var total = DashboardStatsModel._parseInt(
      vObj['total_vehicles'] ?? vObj['total'] ?? vObj['total_registered_vehicles'] ?? json['total_vehicles'],
    );
    var onRoad = DashboardStatsModel._parseInt(
      vObj['on_road'] ?? vObj['on_road_vehicles'] ?? vObj['active'] ?? json['on_road_vehicles'],
    );
    var offRoad = DashboardStatsModel._parseInt(
      vObj['off_road'] ?? vObj['off_road_vehicles'] ?? vObj['inactive'] ?? vObj['under_repair'] ?? json['off_road_vehicles'],
    );
    var backup = DashboardStatsModel._parseInt(
      vObj['backup_vehicles'] ?? vObj['backup'] ?? vObj['spare'] ?? json['backup_vehicles'],
    );

    // If total is 0, check needs_attention (returned by /dashboard/admin and /dashboard/coo)
    if (total == 0 && json['needs_attention'] is List && (json['needs_attention'] as List).isNotEmpty) {
      for (final item in json['needs_attention'] as List) {
        if (item is Map<String, dynamic>) {
          final vCount = DashboardStatsModel._parseInt(item['vehicles'] ?? item['total_vehicles']);
          if (vCount > 0) total += vCount;
          final off = DashboardStatsModel._parseInt(item['offroad_open'] ?? item['off_road']);
          if (off > 0) offRoad += off;
        }
      }
      if (onRoad == 0 && total > offRoad) {
        onRoad = total - offRoad;
      }
    }

    // Check active_vehicles_list from maha_prasthanam wrapper
    if (total == 0 && customMetrics?['maha_prasthanam'] is Map<String, dynamic>) {
      final mp = customMetrics!['maha_prasthanam'] as Map<String, dynamic>;
      final activeList = mp['active_vehicles_list'];
      if (activeList is List && activeList.isNotEmpty) {
        total = activeList.length;
        onRoad = total;
      }
    }

    return VehicleStatusStats(
      totalVehicles: total,
      onRoadVehicles: onRoad,
      offRoadVehicles: offRoad,
      backupVehicles: backup,
    );
  }
}

class PerformanceMetrics {
  final int trips;
  final String caseRunKm;
  final String fuelRunKm;
  final String fuelLiters;
  final String avgMileage;

  const PerformanceMetrics({
    required this.trips,
    required this.caseRunKm,
    required this.fuelRunKm,
    required this.fuelLiters,
    required this.avgMileage,
  });

  factory PerformanceMetrics.empty() {
    return const PerformanceMetrics(
      trips: 0,
      caseRunKm: '0',
      fuelRunKm: '0',
      fuelLiters: '0.0',
      avgMileage: '0.00',
    );
  }

  factory PerformanceMetrics.fromDayJson(Map<String, dynamic> json, String key) {
    // 1. Check custom_metrics.row2 per Mobile API Integration Specification
    final customMetrics = json['custom_metrics'] is Map<String, dynamic>
        ? json['custom_metrics'] as Map<String, dynamic>
        : null;
    final row2 = customMetrics?['row2'] is Map<String, dynamic>
        ? customMetrics!['row2'] as Map<String, dynamic>
        : null;

    if (row2 != null) {
      final trips = DashboardStatsModel._parseInt(row2['yesterday_trips'] ?? row2['trips']);
      final caseKm = DashboardStatsModel._parseDouble(row2['yesterday_case_km'] ?? row2['case_run_km']);
      final fuelRunKm = DashboardStatsModel._parseDouble(row2['yesterday_fuel_run_km'] ?? row2['fuel_run_km']);
      final fuel = DashboardStatsModel._parseDouble(row2['yesterday_fuel'] ?? row2['fuel_liters']);
      final avgMileage = DashboardStatsModel._parseDouble(row2['yesterday_avg_mileage'] ?? row2['avg_mileage']);
      return PerformanceMetrics(
        trips: trips,
        caseRunKm: DashboardStatsModel._formatKm(caseKm),
        fuelRunKm: DashboardStatsModel._formatKm(fuelRunKm),
        fuelLiters: fuel.toStringAsFixed(1),
        avgMileage: '${avgMileage.toStringAsFixed(1)} KMPL',
      );
    }

    final obj = json[key] is Map<String, dynamic>
        ? json[key] as Map<String, dynamic>
        : (json['previous_day_performance'] is Map<String, dynamic>
            ? json['previous_day_performance'] as Map<String, dynamic>
            : (json['yesterday'] is Map<String, dynamic> ? json['yesterday'] as Map<String, dynamic> : null));

    if (obj != null) {
      final trips = DashboardStatsModel._parseInt(obj['trips'] ?? obj['total_trips']);
      final rawCaseKm = DashboardStatsModel._parseDouble(obj['case_run_km'] ?? obj['distance_covered_km']);
      final rawFuelKm = DashboardStatsModel._parseDouble(obj['fuel_run_km']);
      final rawFuelLiters = DashboardStatsModel._parseDouble(obj['fuel_liters'] ?? obj['fuel_consumption_liters']);
      final rawMileage = DashboardStatsModel._parseDouble(obj['avg_mileage'] ?? obj['average_fuel_mileage']);

      return PerformanceMetrics(
        trips: trips,
        caseRunKm: DashboardStatsModel._formatKm(rawCaseKm),
        fuelRunKm: DashboardStatsModel._formatKm(rawFuelKm),
        fuelLiters: rawFuelLiters.toStringAsFixed(1),
        avgMileage: '${rawMileage.toStringAsFixed(1)} KMPL',
      );
    }

    return PerformanceMetrics.empty();
  }

  factory PerformanceMetrics.fromMonthJson(Map<String, dynamic> json) {
    // 1. Check custom_metrics.row3 per Mobile API Integration Specification
    final customMetrics = json['custom_metrics'] is Map<String, dynamic>
        ? json['custom_metrics'] as Map<String, dynamic>
        : null;
    final row3 = customMetrics?['row3'] is Map<String, dynamic>
        ? customMetrics!['row3'] as Map<String, dynamic>
        : null;

    if (row3 != null) {
      final trips = DashboardStatsModel._parseInt(row3['month_trips'] ?? row3['trips']);
      final caseKm = DashboardStatsModel._parseDouble(row3['month_case_km'] ?? row3['case_run_km'] ?? row3['month_km']);
      final fuelRunKm = DashboardStatsModel._parseDouble(row3['month_fuel_run_km'] ?? row3['total_fuel_run_km'] ?? row3['fuel_run_km']);
      final fuel = DashboardStatsModel._parseDouble(row3['month_fuel'] ?? row3['fuel_consumption_liters'] ?? row3['fuel_liters']);
      final avgMileage = DashboardStatsModel._parseDouble(row3['month_avg_mileage'] ?? row3['avg_mileage_kmpl'] ?? row3['avg_mileage']);
      return PerformanceMetrics(
        trips: trips,
        caseRunKm: DashboardStatsModel._formatKm(caseKm),
        fuelRunKm: DashboardStatsModel._formatKm(fuelRunKm),
        fuelLiters: fuel.toStringAsFixed(1),
        avgMileage: '${avgMileage.toStringAsFixed(1)} KMPL',
      );
    }

    final obj = json['monthly'] is Map<String, dynamic>
        ? json['monthly'] as Map<String, dynamic>
        : (json['monthly_performance'] is Map<String, dynamic>
            ? json['monthly_performance'] as Map<String, dynamic>
            : (json['month'] is Map<String, dynamic> ? json['month'] as Map<String, dynamic> : null));

    if (obj != null) {
      final trips = DashboardStatsModel._parseInt(obj['trips'] ?? obj['total_trips']);
      final rawCaseKm = DashboardStatsModel._parseDouble(obj['case_run_km'] ?? obj['distance_covered_km']);
      final rawFuelKm = DashboardStatsModel._parseDouble(obj['fuel_run_km'] ?? obj['total_fuel_run_km']);
      final rawFuelLiters = DashboardStatsModel._parseDouble(obj['fuel_liters'] ?? obj['fuel_consumption_liters']);
      final rawMileage = DashboardStatsModel._parseDouble(obj['avg_mileage'] ?? obj['avg_mileage_kmpl'] ?? obj['average_fuel_mileage']);

      return PerformanceMetrics(
        trips: trips,
        caseRunKm: DashboardStatsModel._formatKm(rawCaseKm),
        fuelRunKm: DashboardStatsModel._formatKm(rawFuelKm),
        fuelLiters: rawFuelLiters.toStringAsFixed(1),
        avgMileage: '${rawMileage.toStringAsFixed(1)} KMPL',
      );
    }

    return PerformanceMetrics.empty();
  }

  PerformanceMetrics copyWith({
    int? trips,
    String? caseRunKm,
    String? fuelRunKm,
    String? fuelLiters,
    String? avgMileage,
  }) {
    return PerformanceMetrics(
      trips: trips ?? this.trips,
      caseRunKm: caseRunKm ?? this.caseRunKm,
      fuelRunKm: fuelRunKm ?? this.fuelRunKm,
      fuelLiters: fuelLiters ?? this.fuelLiters,
      avgMileage: avgMileage ?? this.avgMileage,
    );
  }
}

class ZmPerformanceItem {
  final String name;
  final String zone;
  final String trips;
  final String caseRunKm;
  final String fuelRunKm;
  final String fuelLiters;

  const ZmPerformanceItem({
    required this.name,
    required this.zone,
    required this.trips,
    required this.caseRunKm,
    required this.fuelRunKm,
    required this.fuelLiters,
  });

  factory ZmPerformanceItem.fromJson(Map<String, dynamic> json) {
    return ZmPerformanceItem(
      name: (json['name'] ?? json['zm_name'] ?? json['manager_name'] ?? 'Officer').toString(),
      zone: (json['zone'] ?? json['zone_name'] ?? json['region'] ?? 'Zone').toString(),
      trips: (json['trips'] ?? json['total_trips'] ?? '0').toString(),
      caseRunKm: (json['case_run_km'] ?? json['case_km'] ?? json['distance_km'] ?? '0').toString(),
      fuelRunKm: (json['fuel_run_km'] ?? json['fuel_km'] ?? '0').toString(),
      fuelLiters: (json['fuel_liters'] ?? json['fuel_consumption'] ?? json['litres'] ?? '0.0').toString(),
    );
  }
}

class OpSummaryMetrics {
  final int todayTrips;
  final int callCenterExecutives;
  final int ccePresent;
  final int cceAbsent;
  final int todayCovidCases;
  final int totalCovidCases;
  final int consolidateTrips;
  final int previousMonthTrips;
  final bool isFromMahaPrasthanam;

  const OpSummaryMetrics({
    required this.todayTrips,
    required this.callCenterExecutives,
    required this.ccePresent,
    required this.cceAbsent,
    required this.todayCovidCases,
    required this.totalCovidCases,
    required this.consolidateTrips,
    required this.previousMonthTrips,
    this.isFromMahaPrasthanam = false,
  });

  factory OpSummaryMetrics.empty() {
    return const OpSummaryMetrics(
      todayTrips: 0,
      callCenterExecutives: 0,
      ccePresent: 0,
      cceAbsent: 0,
      todayCovidCases: 0,
      totalCovidCases: 0,
      consolidateTrips: 0,
      previousMonthTrips: 0,
      isFromMahaPrasthanam: false,
    );
  }

  OpSummaryMetrics copyWith({
    int? todayTrips,
    int? callCenterExecutives,
    int? ccePresent,
    int? cceAbsent,
    int? todayCovidCases,
    int? totalCovidCases,
    int? consolidateTrips,
    int? previousMonthTrips,
    bool? isFromMahaPrasthanam,
  }) {
    return OpSummaryMetrics(
      todayTrips: todayTrips ?? this.todayTrips,
      callCenterExecutives: callCenterExecutives ?? this.callCenterExecutives,
      ccePresent: ccePresent ?? this.ccePresent,
      cceAbsent: cceAbsent ?? this.cceAbsent,
      todayCovidCases: todayCovidCases ?? this.todayCovidCases,
      totalCovidCases: totalCovidCases ?? this.totalCovidCases,
      consolidateTrips: consolidateTrips ?? this.consolidateTrips,
      previousMonthTrips: previousMonthTrips ?? this.previousMonthTrips,
      isFromMahaPrasthanam: isFromMahaPrasthanam ?? this.isFromMahaPrasthanam,
    );
  }

  factory OpSummaryMetrics.fromJson(Map<String, dynamic> json) {
    // 1. Check custom_metrics.maha_prasthanam per specification
    final customMetrics = json['custom_metrics'] is Map<String, dynamic>
        ? json['custom_metrics'] as Map<String, dynamic>
        : null;
    final mp = customMetrics?['maha_prasthanam'] is Map<String, dynamic>
        ? customMetrics!['maha_prasthanam'] as Map<String, dynamic>
        : null;

    if (mp != null) {
      final totalCce = DashboardStatsModel._parseInt(mp['total_cce'] ?? mp['cce_count']);
      final ccePres = DashboardStatsModel._parseInt(mp['cce_present'] ?? totalCce);
      final cceAbs = DashboardStatsModel._parseInt(mp['cce_absent']);
      return OpSummaryMetrics(
        todayTrips: DashboardStatsModel._parseInt(mp['today_trips']),
        callCenterExecutives: totalCce,
        ccePresent: ccePres,
        cceAbsent: cceAbs,
        todayCovidCases: DashboardStatsModel._parseInt(mp['today_covid']),
        totalCovidCases: DashboardStatsModel._parseInt(mp['total_covid']),
        consolidateTrips: DashboardStatsModel._parseInt(mp['consolidated_trips'] ?? mp['consolidate_trips']),
        previousMonthTrips: DashboardStatsModel._parseInt(mp['last_month_trips'] ?? mp['previous_month_trips']),
        isFromMahaPrasthanam: true,
      );
    }

    final op = json['operational_summary'] is Map<String, dynamic>
        ? json['operational_summary'] as Map<String, dynamic>
        : (json['mahaprastanam_operational_summary'] is Map<String, dynamic>
            ? json['mahaprastanam_operational_summary'] as Map<String, dynamic>
            : json);

    var cce = DashboardStatsModel._parseInt(
      op['call_center_executives'] ?? op['cce_count'] ?? json['call_center_executives'],
    );
    if (cce == 0 && json['needs_attention'] is List && (json['needs_attention'] as List).isNotEmpty) {
      final first = (json['needs_attention'] as List).first;
      if (first is Map<String, dynamic>) {
        cce = DashboardStatsModel._parseInt(first['staff_count'] ?? first['user_count'] ?? first['users']);
      }
    }

    return OpSummaryMetrics(
      todayTrips: DashboardStatsModel._parseInt(op['today_trips'] ?? json['today_trips']),
      callCenterExecutives: cce,
      ccePresent: DashboardStatsModel._parseInt(op['cce_present'] ?? json['cce_present'] ?? cce),
      cceAbsent: DashboardStatsModel._parseInt(op['cce_absent'] ?? json['cce_absent']),
      todayCovidCases: DashboardStatsModel._parseInt(
        op['today_covid_cases'] ?? op['covid_today'] ?? json['today_covid_cases'],
      ),
      totalCovidCases: DashboardStatsModel._parseInt(
        op['total_covid_cases'] ?? op['covid_total'] ?? json['total_covid_cases'],
      ),
      consolidateTrips: DashboardStatsModel._parseInt(
        op['consolidate_trips'] ?? op['consolidated_trips'] ?? json['consolidate_trips'],
      ),
      previousMonthTrips: DashboardStatsModel._parseInt(
        op['previous_month_trips'] ?? op['prev_month_trips'] ?? json['previous_month_trips'],
      ),
      isFromMahaPrasthanam: false,
    );
  }
}

class CallCenterItem {
  final String name;
  final int inbound;
  final int outbound;
  final String duration;

  const CallCenterItem({
    required this.name,
    required this.inbound,
    required this.outbound,
    required this.duration,
  });

  factory CallCenterItem.fromJson(Map<String, dynamic> json) {
    return CallCenterItem(
      name: (json['user_name'] ?? json['name'] ?? json['cce_name'] ?? json['user'] ?? 'Executive').toString(),
      inbound: DashboardStatsModel._parseInt(json['inbound'] ?? json['incoming_calls'] ?? json['forms'] ?? json['calls']),
      outbound: DashboardStatsModel._parseInt(json['outbound'] ?? json['outgoing_calls']),
      duration: (json['duration'] ?? json['total_duration'] ?? (json['avg_seconds'] != null ? '${json['avg_seconds']}s' : '00:00:00')).toString(),
    );
  }
}

class TripLocationItem {
  final String location;
  final String count;

  const TripLocationItem({
    required this.location,
    required this.count,
  });

  int get tripCount {
    final match = RegExp(r'\d+').firstMatch(count);
    return match != null ? int.tryParse(match.group(0)!) ?? 0 : 0;
  }

  bool get hasTrips => tripCount > 0;

  factory TripLocationItem.fromJson(Map<String, dynamic> json) {
    final rawCount = json['count'] ?? json['trip_count'] ?? json['trips'] ?? '0';
    final countStr = rawCount.toString().endsWith('Trips') ? rawCount.toString() : '$rawCount Trips';
    return TripLocationItem(
      location: (json['location'] ?? json['hospital_name'] ?? json['hospital'] ?? json['name'] ?? 'Hospital').toString(),
      count: countStr,
    );
  }
}
