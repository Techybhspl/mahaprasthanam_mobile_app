class TripBodyModel {
  final int? id;
  final String name;
  final int age;
  final String gender;
  final String caste;
  final String caseType; // 'DC' (Death Certificate) or 'MLC' (Medico-Legal Case)
  final String dcMlcNumber;
  final bool isCovid;
  final String bodyStatus; // 'PENDING', 'TRIP_STARTED', 'TRIP_ENDED'
  final String? pickupPoint;
  final String? dropPoint;

  const TripBodyModel({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.caste,
    required this.caseType,
    required this.dcMlcNumber,
    this.isCovid = false,
    this.bodyStatus = 'PENDING',
    this.pickupPoint,
    this.dropPoint,
  });

  factory TripBodyModel.fromJson(Map<String, dynamic> json) {
    return TripBodyModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      name: json['deceased_name']?.toString() ?? json['name']?.toString() ?? '',
      age: json['age'] is int ? json['age'] as int : int.tryParse(json['age']?.toString() ?? '0') ?? 0,
      gender: json['gender']?.toString() ?? 'Male',
      caste: json['caste']?.toString() ?? 'BC',
      caseType: json['case_type']?.toString() ?? 'DC',
      dcMlcNumber: json['dc_mlc_number']?.toString() ?? '',
      isCovid: json['is_covid'] == true || json['is_covid'] == 1 || json['is_covid'] == 'true',
      bodyStatus: json['body_status']?.toString() ?? 'PENDING',
      pickupPoint: json['pickup_point']?.toString(),
      dropPoint: json['drop_point']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'deceased_name': name,
      'name': name,
      'age': age,
      'gender': gender,
      'caste': caste,
      'case_type': caseType,
      'dc_mlc_number': dcMlcNumber,
      'is_covid': isCovid,
      'body_status': bodyStatus,
      if (pickupPoint != null) 'pickup_point': pickupPoint,
      if (dropPoint != null) 'drop_point': dropPoint,
    };
  }

  TripBodyModel copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    String? caste,
    String? caseType,
    String? dcMlcNumber,
    bool? isCovid,
    String? bodyStatus,
    String? pickupPoint,
    String? dropPoint,
  }) {
    return TripBodyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      caste: caste ?? this.caste,
      caseType: caseType ?? this.caseType,
      dcMlcNumber: dcMlcNumber ?? this.dcMlcNumber,
      isCovid: isCovid ?? this.isCovid,
      bodyStatus: bodyStatus ?? this.bodyStatus,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      dropPoint: dropPoint ?? this.dropPoint,
    );
  }
}
