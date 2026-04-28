/**
 * Calculate daily calorie needs using Harris-Benedict Equation
 * @param {object} profile - User profile data
 * @returns {number} Daily calorie needs
 */
const calculateDailyCalories = (profile) => {
  const { age, gender, height, weight, activityLevel } = profile;

  if (!age || !gender || !height || !weight) {
    return null;
  }

  // Calculate BMR (Basal Metabolic Rate) using Harris-Benedict Equation
  let bmr;

  if (gender === 'male') {
    bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
  } else {
    bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
  }

  // Activity multiplier
  const activityMultiplier = {
    'sedentary': 1.2,      // Little or no exercise
    'light': 1.375,        // Light exercise 1-3 days/week
    'moderate': 1.55,      // Moderate exercise 3-5 days/week
    'active': 1.725,       // Hard exercise 6-7 days/week
    'very_active': 1.9     // Very hard exercise, physical job
  };

  const multiplier = activityMultiplier[activityLevel] || 1.2;
  const dailyCalories = Math.round(bmr * multiplier);

  return dailyCalories;
};

/**
 * Calculate adjusted calories for weight goals
 * @param {number} maintenanceCalories - Daily maintenance calories
 * @param {string} goal - Weight goal (lose, gain, maintain)
 * @param {number} rate - Rate of change (lbs per week)
 * @returns {number} Adjusted daily calories
 */
const calculateCaloriesForGoal = (maintenanceCalories, goal = 'maintain', rate = 1) => {
  if (!maintenanceCalories) return null;

  const caloriesPerPound = 3500; // Calories to gain/lose 1 pound
  const dailyCalorieAdjustment = (caloriesPerPound * rate) / 7; // Daily adjustment

  switch (goal) {
    case 'lose':
      return Math.round(maintenanceCalories - dailyCalorieAdjustment);
    case 'gain':
      return Math.round(maintenanceCalories + dailyCalorieAdjustment);
    case 'maintain':
    default:
      return maintenanceCalories;
  }
};

/**
 * Calculate macronutrient distribution
 * @param {number} totalCalories - Total daily calories
 * @param {string} dietType - Type of diet distribution
 * @returns {object} Macronutrient breakdown in grams and calories
 */
const calculateMacros = (totalCalories, dietType = 'balanced') => {
  if (!totalCalories) return null;

  const ratios = {
    'balanced': { protein: 0.30, carbs: 0.40, fats: 0.30 },
    'low_carb': { protein: 0.35, carbs: 0.25, fats: 0.40 },
    'high_protein': { protein: 0.40, carbs: 0.35, fats: 0.25 },
    'ketogenic': { protein: 0.25, carbs: 0.05, fats: 0.70 }
  };

  const ratio = ratios[dietType] || ratios['balanced'];

  const proteinCalories = totalCalories * ratio.protein;
  const carbsCalories = totalCalories * ratio.carbs;
  const fatsCalories = totalCalories * ratio.fats;

  return {
    protein: {
      calories: Math.round(proteinCalories),
      grams: Math.round(proteinCalories / 4) // 4 calories per gram
    },
    carbs: {
      calories: Math.round(carbsCalories),
      grams: Math.round(carbsCalories / 4) // 4 calories per gram
    },
    fats: {
      calories: Math.round(fatsCalories),
      grams: Math.round(fatsCalories / 9) // 9 calories per gram
    }
  };
};

/**
 * Calculate BMI-based calorie adjustments
 * @param {number} bmi - Body Mass Index
 * @param {number} currentCalories - Current daily calorie target
 * @returns {object} Adjustment recommendations
 */
const calculateBMIAdjustments = (bmi, currentCalories) => {
  let recommendation = '';

  if (bmi < 18.5) {
    recommendation = 'increase';
  } else if (bmi >= 25 && bmi < 30) {
    recommendation = 'decrease_moderate';
  } else if (bmi >= 30) {
    recommendation = 'decrease_significant';
  } else {
    recommendation = 'maintain';
  }

  const adjustments = {
    'increase': {
      adjustment: '+500',
      newTarget: currentCalories + 500,
      recommendation: 'Increase calorie intake for healthy weight gain'
    },
    'decrease_moderate': {
      adjustment: '-300',
      newTarget: currentCalories - 300,
      recommendation: 'Moderate calorie reduction for weight loss'
    },
    'decrease_significant': {
      adjustment: '-500',
      newTarget: currentCalories - 500,
      recommendation: 'Significant calorie reduction for weight loss'
    },
    'maintain': {
      adjustment: '0',
      newTarget: currentCalories,
      recommendation: 'Maintain current calorie intake'
    }
  };

  return adjustments[recommendation];
};

/**
 * Calculate water intake recommendation
 * @param {number} weight - Weight in kilograms
 * @param {number} activityLevel - Activity level multiplier
 * @returns {number} Recommended daily water intake in glasses
 */
const calculateWaterIntake = (weight, activityLevel = 'sedentary') => {
  if (!weight) return 8; // Default recommendation

  const activityMultipliers = {
    'sedentary': 1,
    'light': 1.1,
    'moderate': 1.2,
    'active': 1.3,
    'very_active': 1.4
  };

  const multiplier = activityMultipliers[activityLevel] || 1;
  const baseGlasses = Math.round(weight / 10); // 1 glass per 10kg
  const adjustedGlasses = Math.round(baseGlasses * multiplier);

  return Math.max(8, adjustedGlasses); // Minimum 8 glasses
};

module.exports = {
  calculateDailyCalories,
  calculateCaloriesForGoal,
  calculateMacros,
  calculateBMIAdjustments,
  calculateWaterIntake
};