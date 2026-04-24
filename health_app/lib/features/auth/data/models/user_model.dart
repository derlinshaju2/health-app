class User {
  final String id;
  final String email;
  final UserProfile profile;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.profile,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      email: json['email'] ?? '',
      profile: UserProfile.fromJson(json['profile'] ?? {}),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'profile': profile.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    UserProfile? profile,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      profile: profile ?? this.profile,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserProfile {
  final String? name;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final double? bmi;
  final List<String>? medicalHistory;
  final List<String>? existingConditions;
  final String? activityLevel;

  UserProfile({
    this.name,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.bmi,
    this.medicalHistory,
    this.existingConditions,
    this.activityLevel,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      bmi: json['bmi']?.toDouble(),
      medicalHistory: json['medicalHistory'] != null
          ? List<String>.from(json['medicalHistory'])
          : null,
      existingConditions: json['existingConditions'] != null
          ? List<String>.from(json['existingConditions'])
          : null,
      activityLevel: json['activityLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (bmi != null) 'bmi': bmi,
      if (medicalHistory != null) 'medicalHistory': medicalHistory,
      if (existingConditions != null) 'existingConditions': existingConditions,
      if (activityLevel != null) 'activityLevel': activityLevel,
    };
  }

  UserProfile copyWith({
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
    double? bmi,
    List<String>? medicalHistory,
    List<String>? existingConditions,
    String? activityLevel,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      existingConditions: existingConditions ?? this.existingConditions,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  // Helper methods
  String get displayName => name ?? 'User';

  String get bmiCategory {
    if (bmi == null) return 'Unknown';
    if (bmi! < 18.5) return 'Underweight';
    if (bmi! < 25) return 'Normal';
    if (bmi! < 30) return 'Overweight';
    return 'Obese';
  }

  bool get hasCompleteProfile {
    return name != null &&
        age != null &&
        gender != null &&
        height != null &&
        weight != null &&
        bmi != null;
  }
}