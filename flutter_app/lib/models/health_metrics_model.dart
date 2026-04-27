/// Health Metrics Model
class HealthMetrics {
  final String? id;
  final String userId;
  final BloodPressure? bloodPressure;
  final int? bloodSugar;
  final Cholesterol? cholesterol;
  final String? notes;
  final DateTime? createdAt;

  HealthMetrics({
    this.id,
    required this.userId,
    this.bloodPressure,
    this.bloodSugar,
    this.cholesterol,
    this.notes,
    this.createdAt,
  });

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      id: json['_id'] ?? json['id'],
      userId: json['userId'] ?? '',
      bloodPressure: json['bloodPressure'] != null
          ? BloodPressure.fromJson(json['bloodPressure'])
          : null,
      bloodSugar: json['bloodSugar'],
      cholesterol: json['cholesterol'] != null
          ? Cholesterol.fromJson(json['cholesterol'])
          : null,
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      if (bloodPressure != null) 'bloodPressure': bloodPressure!.toJson(),
      if (bloodSugar != null) 'bloodSugar': bloodSugar,
      if (cholesterol != null) 'cholesterol': cholesterol!.toJson(),
      if (notes != null) 'notes': notes,
    };
  }
}

class BloodPressure {
  final int systolic;
  final int diastolic;
  final String? pulse;

  BloodPressure({
    required this.systolic,
    required this.diastolic,
    this.pulse,
  });

  factory BloodPressure.fromJson(Map<String, dynamic> json) {
    return BloodPressure(
      systolic: json['systolic'] ?? json['systolic'] ?? 0,
      diastolic: json['diastolic'] ?? json['diastolic'] ?? 0,
      pulse: json['pulse'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      if (pulse != null) 'pulse': pulse,
    };
  }

  @override
  String toString() => '$systolic/$diastolic mmHg';
}

class Cholesterol {
  final int total;
  final int ldl; // Low-density lipoprotein
  final int hdl; // High-density lipoprotein
  final int triglycerides;

  Cholesterol({
    required this.total,
    required this.ldl,
    required this.hdl,
    required this.triglycerides,
  });

  factory Cholesterol.fromJson(Map<String, dynamic> json) {
    return Cholesterol(
      total: json['total'] ?? 0,
      ldl: json['ldl'] ?? 0,
      hdl: json['hdl'] ?? 0,
      triglycerides: json['triglycerides'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'ldl': ldl,
      'hdl': hdl,
      'triglycerides': triglycerides,
    };
  }

  @override
  String toString() => 'Total: $total, LDL: $ldl, HDL: $hdl';
}
