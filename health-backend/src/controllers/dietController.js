const DietPlan = require('../models/DietPlan');
const FoodLog = require('../models/FoodLog');
const User = require('../models/User');
const { calculateDailyCalories } = require('../utils/calorieCalculator');

/**
 * Generate diet recommendations based on user profile
 * @route GET /api/diet/recommendations
 */
const getRecommendations = async (req, res) => {
  try {
    const user = await User.findById(req.userId);

    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    // Calculate daily calorie needs
    const dailyCalories = user.calculateDailyCalories();

    // Calculate macros
    const macros = calculateMacros(dailyCalories, 'balanced');

    // Get BMI category for recommendations
    const bmiCategory = user.getBMICategory();

    // Generate meal suggestions
    const mealSuggestions = generateMealSuggestions(dailyCalories, bmiCategory);

    // Get recommendations based on health conditions
    const recommendations = getDietRecommendations(user.profile);

    res.status(200).json({
      status: 'success',
      data: {
        dailyCalorieTarget: dailyCalories,
        macros,
        mealSuggestions,
        recommendations,
        bmiCategory,
        waterIntake: calculateWaterIntake(user.profile.weight, user.profile.activityLevel)
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Create food log entry
 * @route POST /api/diet/food-log
 */
const createFoodLog = async (req, res) => {
  try {
    const { date, meals, waterIntake, notes } = req.body;

    const foodLog = await FoodLog.create({
      userId: req.userId,
      date: date || new Date(),
      meals,
      waterIntake,
      notes
    });

    res.status(201).json({
      status: 'success',
      message: 'Food log created successfully',
      data: { foodLog }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get food log for specific date
 * @route GET /api/diet/food-log/:date
 */
const getFoodLog = async (req, res) => {
  try {
    const { date } = req.params;
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);

    const foodLog = await FoodLog.findOne({
      userId: req.userId,
      date: {
        $gte: startOfDay,
        $lte: endOfDay
      }
    });

    if (!foodLog) {
      return res.status(404).json({
        status: 'error',
        message: 'No food log found for this date'
      });
    }

    res.status(200).json({
      status: 'success',
      data: { foodLog }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Update water intake
 * @route PUT /api/diet/water-intake
 */
const updateWaterIntake = async (req, res) => {
  try {
    const { glasses, date } = req.body;
    const targetDate = date || new Date();

    const startOfDay = new Date(targetDate);
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date(targetDate);
    endOfDay.setHours(23, 59, 59, 999);

    // Find or create food log for the date
    let foodLog = await FoodLog.findOne({
      userId: req.userId,
      date: {
        $gte: startOfDay,
        $lte: endOfDay
      }
    });

    if (!foodLog) {
      foodLog = await FoodLog.create({
        userId: req.userId,
        date: targetDate,
        waterIntake: Math.max(0, glasses),
        meals: []
      });
    } else {
      foodLog.waterIntake = Math.max(0, (foodLog.waterIntake || 0) + glasses);
      await foodLog.save();
    }

    res.status(200).json({
      status: 'success',
      message: 'Water intake updated successfully',
      data: {
        waterIntake: foodLog.waterIntake,
        target: 8 // Default target
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get meal plan for specific date
 * @route GET /api/diet/meal-plan/:date
 */
const getMealPlan = async (req, res) => {
  try {
    const { date } = req.params;
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);

    let dietPlan = await DietPlan.findOne({
      userId: req.userId,
      date: {
        $gte: startOfDay,
        $lte: endOfDay
      }
    });

    // If no meal plan exists, generate one
    if (!dietPlan) {
      const user = await User.findById(req.userId);
      const dailyCalories = user.calculateDailyCalories();

      dietPlan = await DietPlan.create({
        userId: req.userId,
        date: startOfDay,
        dailyCalorieTarget: dailyCalories,
        meals: generateBasicMealPlan(dailyCalories),
        waterIntake: {
          target: 8,
          current: 0
        }
      });
    }

    res.status(200).json({
      status: 'success',
      data: { dietPlan }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get food log history
 * @route GET /api/diet/food-log/history/:period
 */
const getFoodLogHistory = async (req, res) => {
  try {
    const { period } = req.params; // week, month, quarter, year
    const now = new Date();
    let startDate;

    switch (period) {
      case 'week':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case 'month':
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        break;
      case 'quarter':
        startDate = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
        break;
      case 'year':
        startDate = new Date(now.getTime() - 365 * 24 * 60 * 60 * 1000);
        break;
      default:
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
    }

    const foodLogs = await FoodLog.find({
      userId: req.userId,
      date: {
        $gte: startDate,
        $lte: now
      }
    }).sort({ date: -1 });

    // Calculate statistics
    const stats = calculateFoodLogStats(foodLogs);

    res.status(200).json({
      status: 'success',
      data: {
        foodLogs,
        stats,
        period,
        startDate,
        endDate: now
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

// Helper function to generate meal suggestions
const generateMealSuggestions = (dailyCalories, bmiCategory) => {
  const meals = {
    breakfast: {
      calories: Math.round(dailyCalories * 0.25),
      suggestions: [
        'Oatmeal with fruits and nuts',
        'Greek yogurt with berries',
        'Whole grain toast with avocado',
        'Smoothie with protein powder'
      ]
    },
    lunch: {
      calories: Math.round(dailyCalories * 0.35),
      suggestions: [
        'Grilled chicken salad',
        'Quinoa bowl with vegetables',
        'Whole grain sandwich with lean protein',
        'Brown rice with grilled fish'
      ]
    },
    dinner: {
      calories: Math.round(dailyCalories * 0.30),
      suggestions: [
        'Grilled salmon with steamed vegetables',
        'Lean protein with roasted vegetables',
        'Vegetable stir-fry with tofu',
        'Baked chicken with sweet potato'
      ]
    },
    snacks: {
      calories: Math.round(dailyCalories * 0.10),
      suggestions: [
        'Fresh fruits',
        'Nuts and seeds',
        'Vegetable sticks with hummus',
        'Greek yogurt'
      ]
    }
  };

  return meals;
};

// Helper function to get diet recommendations based on health conditions
const getDietRecommendations = (profile) => {
  const recommendations = [];

  // BMI-based recommendations
  const bmi = profile.bmi || 0;
  if (bmi > 0) {
    if (bmi < 18.5) {
      recommendations.push('Increase calorie intake with nutrient-dense foods');
      recommendations.push('Include protein-rich foods in your diet');
    } else if (bmi >= 25 && bmi < 30) {
      recommendations.push('Create a moderate calorie deficit');
      recommendations.push('Focus on whole foods and reduce processed foods');
    } else if (bmi >= 30) {
      recommendations.push('Consult a healthcare provider for weight management');
      recommendations.push('Aim for 5-10% weight loss for health benefits');
    }
  }

  // Existing conditions recommendations
  if (profile.existingConditions && profile.existingConditions.length > 0) {
    if (profile.existingConditions.includes('diabetes')) {
      recommendations.push('Monitor carbohydrate intake');
      recommendations.push('Choose low glycemic index foods');
    }
    if (profile.existingConditions.includes('hypertension')) {
      recommendations.push('Reduce sodium intake');
      recommendations.push('Increase potassium-rich foods');
    }
    if (profile.existingConditions.includes('heart_disease')) {
      recommendations.push('Follow a heart-healthy diet');
      recommendations.push('Limit saturated fats and cholesterol');
    }
  }

  return recommendations;
};

// Helper function to calculate macros
const calculateMacros = (totalCalories, dietType) => {
  const ratios = {
    'balanced': { protein: 0.30, carbs: 0.40, fats: 0.30 },
    'low_carb': { protein: 0.35, carbs: 0.25, fats: 0.40 },
    'high_protein': { protein: 0.40, carbs: 0.35, fats: 0.25 }
  };

  const ratio = ratios[dietType] || ratios['balanced'];

  return {
    protein: Math.round((totalCalories * ratio.protein) / 4),
    carbs: Math.round((totalCalories * ratio.carbs) / 4),
    fats: Math.round((totalCalories * ratio.fats) / 9)
  };
};

// Helper function to calculate water intake
const calculateWaterIntake = (weight, activityLevel) => {
  if (!weight) return 8;

  const activityMultipliers = {
    'sedentary': 1,
    'light': 1.1,
    'moderate': 1.2,
    'active': 1.3,
    'very_active': 1.4
  };

  const multiplier = activityMultipliers[activityLevel] || 1;
  const baseGlasses = Math.round(weight / 10);

  return Math.max(8, Math.round(baseGlasses * multiplier));
};

// Helper function to generate basic meal plan
const generateBasicMealPlan = (dailyCalories) => {
  return [
    {
      type: 'breakfast',
      foods: [
        {
          name: 'Oatmeal with fruits',
          calories: Math.round(dailyCalories * 0.15),
          protein: Math.round((dailyCalories * 0.15 * 0.15) / 4),
          carbs: Math.round((dailyCalories * 0.15 * 0.60) / 4),
          fats: Math.round((dailyCalories * 0.15 * 0.25) / 9)
        }
      ]
    },
    {
      type: 'lunch',
      foods: [
        {
          name: 'Grilled chicken salad',
          calories: Math.round(dailyCalories * 0.30),
          protein: Math.round((dailyCalories * 0.30 * 0.30) / 4),
          carbs: Math.round((dailyCalories * 0.30 * 0.40) / 4),
          fats: Math.round((dailyCalories * 0.30 * 0.30) / 9)
        }
      ]
    },
    {
      type: 'dinner',
      foods: [
        {
          name: 'Grilled salmon with vegetables',
          calories: Math.round(dailyCalories * 0.35),
          protein: Math.round((dailyCalories * 0.35 * 0.30) / 4),
          carbs: Math.round((dailyCalories * 0.35 * 0.35) / 4),
          fats: Math.round((dailyCalories * 0.35 * 0.35) / 9)
        }
      ]
    }
  ];
};

// Helper function to calculate food log statistics
const calculateFoodLogStats = (foodLogs) => {
  if (!foodLogs || foodLogs.length === 0) {
    return {
      averageCalories: 0,
      totalEntries: 0,
      averageWaterIntake: 0
    };
  }

  const totalCalories = foodLogs.reduce((sum, log) => sum + (log.totalCalories || 0), 0);
  const totalWater = foodLogs.reduce((sum, log) => sum + (log.waterIntake || 0), 0);

  return {
    averageCalories: Math.round(totalCalories / foodLogs.length),
    totalEntries: foodLogs.length,
    averageWaterIntake: Math.round(totalWater / foodLogs.length)
  };
};

module.exports = {
  getRecommendations,
  createFoodLog,
  getFoodLog,
  updateWaterIntake,
  getMealPlan,
  getFoodLogHistory
};