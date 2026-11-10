import 'dart:convert';
import 'trip_body_model.dart';

class BeneficiaryTripModel {
  final int? id;
  final String localId; // Client-generated unique ID for offline SQLite drafts
  final String tripDate;
  final int regionId;
  final int startDistrictId;
  final int destDistrictId;
  final String hospitalName;
  final int vehicleId;
  final String vehicleNumber;
  final String driverName;
  final String attendantName;
  final String attendantPhone;
  final int odoStart;
  final int? odoReach;
  final int? odoEnd;
  final String mandalName;
  final String village;
  final String destination;
  final String? specialCase;
  final String? recommendedBy;
  final String? tripRequestTime;
  final String? tripStartTime;
  final String? tripReachTime;
  final String? tripEndTime;
  final String? remarks;
  final String status; // 'DRAFT', 'SUBMITTED'
  final List<TripBodyModel> bodies;
  final String? odoStartImagePath;
  final String? odoEndImagePath;
  final String createdAt;
  final bool isSynced;

  const BeneficiaryTripModel({
    this.id,
    required this.localId,
    required this.tripDate,
    this.regionId = 1,
    required this.startDistrictId,
    required this.destDistrictId,
    required this.hospitalName,
    required this.vehicleId,
    required this.vehicleNumber,
    required this.driverName,
    required this.attendantName,
    required this.attendantPhone,
    required this.odoStart,
    this.odoReach,
    this.odoEnd,
    required this.mandalName,
    required this.village,
    required this.destination,
    this.specialCase,
    this.recommendedBy,
    this.tripRequestTime,
    this.tripStartTime,
    this.tripReachTime,
    this.tripEndTime,
    this.remarks,
    this.status = 'DRAFT',
    required this.bodies,
    this.odoStartImagePath,
    this.odoEndImagePath,
    required this.createdAt,
    this.isSynced = false,
  });

  int get totalKilometers {
    if (odoEnd != null && odoEnd! >= odoStart) {
      return odoEnd! - odoStart;
    }
    return 0;
  }

  factory BeneficiaryTripModel.fromJson(Map<String, dynamic> json) {
    var parsedBodies = <TripBodyModel>[];
    if (json['bodies'] is List) {
      parsedBodies = (json['bodies'] as List)
          .map((b) => TripBodyModel.fromJson(b as Map<String, dynamic>))
          .toList();
    } else if (json['bodies_json'] is String) {
      try {
        final decoded = jsonDecode(json['bodies_json'] as String) as List;
        parsedBodies = decoded
            .map((b) => TripBodyModel.fromJson(b as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    return BeneficiaryTripModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      localId: json['local_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      tripDate: json['trip_date']?.toString() ?? DateTime.now().toIso8601String().substring(0, 10),
      regionId: json['region_id'] is int ? json['region_id'] as int : int.tryParse(json['region_id']?.toString() ?? '1') ?? 1,
      startDistrictId: json['start_district_id'] is int ? json['start_district_id'] as int : int.tryParse(json['start_district_id']?.toString() ?? '1') ?? 1,
      destDistrictId: json['dest_district_id'] is int ? json['dest_district_id'] as int : int.tryParse(json['dest_district_id']?.toString() ?? '1') ?? 1,
      hospitalName: json['hospital_name']?.toString() ?? '',
      vehicleId: json['vehicle_id'] is int ? json['vehicle_id'] as int : int.tryParse(json['vehicle_id']?.toString() ?? '42') ?? 42,
      vehicleNumber: json['vehicle_number']?.toString() ?? 'AP-16-MP-1042',
      driverName: json['driver_name']?.toString() ?? '',
      attendantName: json['attendant_name']?.toString() ?? '',
      attendantPhone: json['attendant_phone']?.toString() ?? '',
      odoStart: json['odo_start'] is int ? json['odo_start'] as int : int.tryParse(json['odo_start']?.toString() ?? '0') ?? 0,
      odoReach: json['odo_reach'] is int ? json['odo_reach'] as int : int.tryParse(json['odo_reach']?.toString() ?? ''),
      odoEnd: json['odo_end'] is int ? json['odo_end'] as int : int.tryParse(json['odo_end']?.toString() ?? ''),
      mandalName: json['mandal_name']?.toString() ?? '',
      village: json['village']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      specialCase: json['special_case']?.toString(),
      recommendedBy: json['recommended_by']?.toString(),
      tripRequestTime: json['trip_request_time']?.toString(),
      tripStartTime: json['trip_start_time']?.toString(),
      tripReachTime: json['trip_reach_time']?.toString(),
      tripEndTime: json['trip_end_time']?.toString(),
      remarks: json['remarks']?.toString(),
      status: json['status']?.toString() ?? 'DRAFT',
      bodies: parsedBodies,
      odoStartImagePath: json['odo_start_image_path']?.toString(),
      odoEndImagePath: json['odo_end_image_path']?.toString(),
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      isSynced: json['is_synced'] == 1 || json['is_synced'] == true || json['is_synced'] == 'true',
    );
  }

  Map<String, dynamic> toApiJson() {
    return {
      if (id != null) 'id': id,
      'trip_date': tripDate,
      'region_id': regionId,
      'start_district_id': startDistrictId,
      'dest_district_id': destDistrictId,
      'hospital_name': hospitalName,
      'vehicle_id': vehicleId,
      'vehicle_number': vehicleNumber,
      'driver_name': driverName,
      'attendant_name': attendantName,
      'attendant_phone': attendantPhone,
      'odo_start': odoStart,
      if (odoReach != null) 'odo_reach': odoReach,
      if (odoEnd != null) 'odo_end': odoEnd,
      'mandal_name': mandalName,
      'village': village,
      'destination': destination,
      'drop_location': destination,
      if (specialCase != null) 'special_case': specialCase,
      if (recommendedBy != null) 'recommended_by': recommendedBy,
      if (tripRequestTime != null) 'trip_request_time': tripRequestTime,
      if (tripStartTime != null) 'trip_start_time': tripStartTime,
      if (tripReachTime != null) 'trip_reach_time': tripReachTime,
      if (tripEndTime != null) 'trip_end_time': tripEndTime,
      if (remarks != null) 'remarks': remarks,
      'status': status,
      'call_data': {
        'call_type': 'Inbound From Driver',
        'designation': 'Driver',
        'close_type': 'Valid Call',
        'call_time': createdAt,
        'user_name': driverName,
      },
      'bodies': bodies.map((b) => b.toJson()).toList(),
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'local_id': localId,
      'server_id': id,
      'trip_date': tripDate,
      'region_id': regionId,
      'start_district_id': startDistrictId,
      'dest_district_id': destDistrictId,
      'hospital_name': hospitalName,
      'vehicle_id': vehicleId,
      'vehicle_number': vehicleNumber,
      'driver_name': driverName,
      'attendant_name': attendantName,
      'attendant_phone': attendantPhone,
      'odo_start': odoStart,
      'odo_reach': odoReach,
      'odo_end': odoEnd,
      'mandal_name': mandalName,
      'village': village,
      'destination': destination,
      'special_case': specialCase,
      'recommended_by': recommendedBy,
      'trip_request_time': tripRequestTime,
      'trip_start_time': tripStartTime,
      'trip_reach_time': tripReachTime,
      'trip_end_time': tripEndTime,
      'remarks': remarks,
      'status': status,
      'bodies_json': jsonEncode(bodies.map((b) => b.toJson()).toList()),
      'odo_start_image_path': odoStartImagePath,
      'odo_end_image_path': odoEndImagePath,
      'created_at': createdAt,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  BeneficiaryTripModel copyWith({
    int? id,
    String? localId,
    String? tripDate,
    int? regionId,
    int? startDistrictId,
    int? destDistrictId,
    String? hospitalName,
    int? vehicleId,
    String? vehicleNumber,
    String? driverName,
    String? attendantName,
    String? attendantPhone,
    int? odoStart,
    int? odoReach,
    int? odoEnd,
    String? mandalName,
    String? village,
    String? destination,
    String? specialCase,
    String? recommendedBy,
    String? tripRequestTime,
    String? tripStartTime,
    String? tripReachTime,
    String? tripEndTime,
    String? remarks,
    String? status,
    List<TripBodyModel>? bodies,
    String? odoStartImagePath,
    String? odoEndImagePath,
    String? createdAt,
    bool? isSynced,
  }) {
    return BeneficiaryTripModel(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      tripDate: tripDate ?? this.tripDate,
      regionId: regionId ?? this.regionId,
      startDistrictId: startDistrictId ?? this.startDistrictId,
      destDistrictId: destDistrictId ?? this.destDistrictId,
      hospitalName: hospitalName ?? this.hospitalName,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      driverName: driverName ?? this.driverName,
      attendantName: attendantName ?? this.attendantName,
      attendantPhone: attendantPhone ?? this.attendantPhone,
      odoStart: odoStart ?? this.odoStart,
      odoReach: odoReach ?? this.odoReach,
      odoEnd: odoEnd ?? this.odoEnd,
      mandalName: mandalName ?? this.mandalName,
      village: village ?? this.village,
      destination: destination ?? this.destination,
      specialCase: specialCase ?? this.specialCase,
      recommendedBy: recommendedBy ?? this.recommendedBy,
      tripRequestTime: tripRequestTime ?? this.tripRequestTime,
      tripStartTime: tripStartTime ?? this.tripStartTime,
      tripReachTime: tripReachTime ?? this.tripReachTime,
      tripEndTime: tripEndTime ?? this.tripEndTime,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      bodies: bodies ?? this.bodies,
      odoStartImagePath: odoStartImagePath ?? this.odoStartImagePath,
      odoEndImagePath: odoEndImagePath ?? this.odoEndImagePath,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
