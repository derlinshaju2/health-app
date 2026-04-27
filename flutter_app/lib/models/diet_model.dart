/// Diet Recommendation Model
class DietRecommendation {
  final String dietType;
  final int dailyCalorieTarget;
  final int waterIntakeGlasses;
  final MealPlan mealPlan;
  final FoodGuidelines foodGuidelines;
  final List<String> tips;
  final String explanation;

  DietRecommendation({
    required this.dietType,
    required this.dailyCalorieTarget,
    required this.waterIntakeGlasses,
    required this.mealPlan,
    required this.foodGuidelines,
    required this.tips,
    required this.explanation,
  });

  factory DietRecommendation.fromJson(Map<String, dynamic> json) {
    return DietRecommendation(
      dietType: json['dietType'] ?? 'maintenance',
      dailyCalorieTarget: json['dailyCalorieTarget'] ?? 2000,
      waterIntakeGlasses: json['waterIntakeGlasses'] ?? 8,
      mealPlan: MealPlan.fromJson(json['mealPlan'] ?? {}),
      foodGuidelines: FoodGuidelines.fromJson(json['foodGuidelines'] ?? {}),
      tips: List<String>.from(json['tips'] ?? []),
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dietType': dietType,
      'dailyCalorieTarget': dailyCalorieTarget,
      'waterIntakeGlasses': waterIntakeGlasses,
      'mealPlan': mealPlan.toJson(),
      'foodGuidelines': foodGuidelines.toJson(),
      'tips': tips,
      'explanation': explanation,
    };
  }
}

class MealPlan {
  final Meal breakfast;
  final Meal lunch;
  final Meal dinner;
  final Meal snacks;

  MealPlan({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      breakfast: Meal.fromJson(json['breakfast'] ?? {}),
      lunch: Meal.fromJson(json['lunch'] ?? {}),
      dinner: Meal.fromJson(json['dinner'] ?? {}),
      snacks: Meal.fromJson(json['snacks'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast.toJson(),
      'lunch': lunch.toJson(),
      'dinner': dinner.toJson(),
      'snacks': snacks.toJson(),
    };
  }
}

class Meal {
  final String name;
  final String description;
  final int calories;
  final List<String> items;

  Meal({
    required this.name,
    required this.description,
    required this.calories,
    required this.items,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      calories: json['calories'] ?? 0,
      items: List<String>.from(json['items'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'calories': calories,
      'items': items,
    };
  }
}

class FoodGuidelines {
  final List<String> toEat;
  final List<String> toLimit;
  final List<String> toAvoid;

  FoodGuidelines({
    required this.toEat,
    required this.toLimit,
    required this.toAvoid,
  });

  factory FoodGuidelines.fromJson(Map<String, dynamic> json) {
    return FoodGuidelines(
      toEat: List<String>.from(json['toEat'] ?? []),
      toLimit: List<String>.from(json['toLimit'] ?? []),
      toAvoid: List<String>.from(json['toAvoid'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'toEat': toEat,
      'toLimit': toLimit,
      'toAvoid': toAvoid,
    };
  }
}
