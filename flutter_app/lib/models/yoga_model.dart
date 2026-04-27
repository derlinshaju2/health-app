/// Yoga Recommendation Model
class YogaRecommendation {
  final String fitnessLevel;
  final String goal;
  final YogaRoutine routine;
  final List<String> weeklySchedule;
  final List<String> precautions;
  final List<String> tips;
  final String explanation;

  YogaRecommendation({
    required this.fitnessLevel,
    required this.goal,
    required this.routine,
    required this.weeklySchedule,
    required this.precautions,
    required this.tips,
    required this.explanation,
  });

  factory YogaRecommendation.fromJson(Map<String, dynamic> json) {
    return YogaRecommendation(
      fitnessLevel: json['fitnessLevel'] ?? 'beginner',
      goal: json['goal'] ?? 'general',
      routine: YogaRoutine.fromJson(json['routine'] ?? {}),
      weeklySchedule: List<String>.from(json['weeklySchedule'] ?? []),
      precautions: List<String>.from(json['precautions'] ?? []),
      tips: List<String>.from(json['tips'] ?? []),
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fitnessLevel': fitnessLevel,
      'goal': goal,
      'routine': routine.toJson(),
      'weeklySchedule': weeklySchedule,
      'precautions': precautions,
      'tips': tips,
      'explanation': explanation,
    };
  }
}

class YogaRoutine {
  final List<YogaPose> warmup;
  final List<YogaPose> mainPoses;
  final List<BreathingExercise> breathing;
  final List<YogaPose> cooldown;
  final int totalDurationMinutes;

  YogaRoutine({
    required this.warmup,
    required this.mainPoses,
    required this.breathing,
    required this.cooldown,
    required this.totalDurationMinutes,
  });

  factory YogaRoutine.fromJson(Map<String, dynamic> json) {
    return YogaRoutine(
      warmup: (json['warmup'] as List? ?? [])
          .map((e) => YogaPose.fromJson(e))
          .toList(),
      mainPoses: (json['mainPoses'] as List? ?? [])
          .map((e) => YogaPose.fromJson(e))
          .toList(),
      breathing: (json['breathing'] as List? ?? [])
          .map((e) => BreathingExercise.fromJson(e))
          .toList(),
      cooldown: (json['cooldown'] as List? ?? [])
          .map((e) => YogaPose.fromJson(e))
          .toList(),
      totalDurationMinutes: json['totalDurationMinutes'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warmup': warmup.map((e) => e.toJson()).toList(),
      'mainPoses': mainPoses.map((e) => e.toJson()).toList(),
      'breathing': breathing.map((e) => e.toJson()).toList(),
      'cooldown': cooldown.map((e) => e.toJson()).toList(),
      'totalDurationMinutes': totalDurationMinutes,
    };
  }
}

class YogaPose {
  final String name;
  final String description;
  final int durationSeconds;
  final String difficulty;
  final List<String> benefits;

  YogaPose({
    required this.name,
    required this.description,
    required this.durationSeconds,
    required this.difficulty,
    required this.benefits,
  });

  factory YogaPose.fromJson(Map<String, dynamic> json) {
    return YogaPose(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      durationSeconds: json['durationSeconds'] ?? 30,
      difficulty: json['difficulty'] ?? 'beginner',
      benefits: List<String>.from(json['benefits'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'durationSeconds': durationSeconds,
      'difficulty': difficulty,
      'benefits': benefits,
    };
  }

  String get duration => durationSeconds >= 60
      ? '${durationSeconds ~/ 60} min ${durationSeconds % 60} sec'
      : '$durationSeconds sec';
}

class BreathingExercise {
  final String name;
  final String description;
  final int durationSeconds;
  final String technique;

  BreathingExercise({
    required this.name,
    required this.description,
    required this.durationSeconds,
    required this.technique,
  });

  factory BreathingExercise.fromJson(Map<String, dynamic> json) {
    return BreathingExercise(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      durationSeconds: json['durationSeconds'] ?? 60,
      technique: json['technique'] ?? 'deep breathing',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'durationSeconds': durationSeconds,
      'technique': technique,
    };
  }
}
