/// Progress Model
class Progress {
  final String? id;
  final String userId;
  final DateTime date;
  final DietProgress? diet;
  final YogaProgress? yoga;
  final WellnessProgress? wellness;
  final List<Achievement> achievements;

  Progress({
    this.id,
    required this.userId,
    required this.date,
    this.diet,
    this.yoga,
    this.wellness,
    required this.achievements,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['_id'] ?? json['id'],
      userId: json['userId'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      diet: json['diet'] != null
          ? DietProgress.fromJson(json['diet'])
          : null,
      yoga: json['yoga'] != null
          ? YogaProgress.fromJson(json['yoga'])
          : null,
      wellness: json['wellness'] != null
          ? WellnessProgress.fromJson(json['wellness'])
          : null,
      achievements: (json['achievements'] as List? ?? [])
          .map((e) => Achievement.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      if (diet != null) 'diet': diet!.toJson(),
      if (yoga != null) 'yoga': yoga!.toJson(),
      if (wellness != null) 'wellness': wellness!.toJson(),
      'achievements': achievements.map((e) => e.toJson()).toList(),
    };
  }
}

class DietProgress {
  final int caloriesConsumed;
  final int caloriesTarget;
  final int waterIntake;
  final int waterTarget;
  final int mealsLogged;
  final bool dietPlanFollowed;
  final String? notes;

  DietProgress({
    required this.caloriesConsumed,
    required this.caloriesTarget,
    required this.waterIntake,
    required this.waterTarget,
    required this.mealsLogged,
    required this.dietPlanFollowed,
    this.notes,
  });

  factory DietProgress.fromJson(Map<String, dynamic> json) {
    return DietProgress(
      caloriesConsumed: json['caloriesConsumed'] ?? 0,
      caloriesTarget: json['caloriesTarget'] ?? 2000,
      waterIntake: json['waterIntake'] ?? 0,
      waterTarget: json['waterTarget'] ?? 8,
      mealsLogged: json['mealsLogged'] ?? 0,
      dietPlanFollowed: json['dietPlanFollowed'] ?? false,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caloriesConsumed': caloriesConsumed,
      'caloriesTarget': caloriesTarget,
      'waterIntake': waterIntake,
      'waterTarget': waterTarget,
      'mealsLogged': mealsLogged,
      'dietPlanFollowed': dietPlanFollowed,
      if (notes != null) 'notes': notes,
    };
  }

  double get calorieAchievement => caloriesTarget > 0
      ? (caloriesConsumed / caloriesTarget * 100).clamp(0, 150)
      : 0;
}

class YogaProgress {
  final int durationMinutes;
  final int targetMinutes;
  final int posesCompleted;
  final String difficulty;
  final String yogaType;
  final List<String> exercisesCompleted;
  final String? notes;

  YogaProgress({
    required this.durationMinutes,
    required this.targetMinutes,
    required this.posesCompleted,
    required this.difficulty,
    required this.yogaType,
    required this.exercisesCompleted,
    this.notes,
  });

  factory YogaProgress.fromJson(Map<String, dynamic> json) {
    return YogaProgress(
      durationMinutes: json['durationMinutes'] ?? 0,
      targetMinutes: json['targetMinutes'] ?? 30,
      posesCompleted: json['posesCompleted'] ?? 0,
      difficulty: json['difficulty'] ?? 'beginner',
      yogaType: json['yogaType'] ?? 'hatha',
      exercisesCompleted: List<String>.from(json['exercisesCompleted'] ?? []),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'durationMinutes': durationMinutes,
      'targetMinutes': targetMinutes,
      'posesCompleted': posesCompleted,
      'difficulty': difficulty,
      'yogaType': yogaType,
      'exercisesCompleted': exercisesCompleted,
      if (notes != null) 'notes': notes,
    };
  }

  double get durationAchievement => targetMinutes > 0
      ? (durationMinutes / targetMinutes * 100).clamp(0, 150)
      : 0;
}

class WellnessProgress {
  final int energyLevel; // 1-10
  final String mood; // excellent, good, neutral, bad, terrible
  final int sleepQuality; // 1-10
  final int stressLevel; // 1-10

  WellnessProgress({
    required this.energyLevel,
    required this.mood,
    required this.sleepQuality,
    required this.stressLevel,
  });

  factory WellnessProgress.fromJson(Map<String, dynamic> json) {
    return WellnessProgress(
      energyLevel: json['energyLevel'] ?? 5,
      mood: json['mood'] ?? 'neutral',
      sleepQuality: json['sleepQuality'] ?? 5,
      stressLevel: json['stressLevel'] ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'energyLevel': energyLevel,
      'mood': mood,
      'sleepQuality': sleepQuality,
      'stressLevel': stressLevel,
    };
  }
}

class Achievement {
  final String type; // diet, yoga, wellness, streak
  final String title;
  final String description;
  final DateTime date;

  Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.date,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      type: json['type'] ?? 'general',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}
