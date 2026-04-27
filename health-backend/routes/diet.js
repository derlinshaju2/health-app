const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');

// Diet recommendation engine based on BMI and health goals
const getDietRecommendations = (userProfile, healthMetrics = {}) => {
    const { bmi, age, gender, goal } = userProfile;

    // Determine BMI category
    let bmiCategory, calorieTarget, dietType;

    if (bmi < 18.5) {
        bmiCategory = 'underweight';
        dietType = 'weight_gain';
        calorieTarget = 2500; // Higher for weight gain
    } else if (bmi >= 18.5 && bmi < 25) {
        bmiCategory = 'normal';
        dietType = 'maintenance';
        calorieTarget = 2000; // Standard maintenance
    } else if (bmi >= 25 && bmi < 30) {
        bmiCategory = 'overweight';
        dietType = 'weight_loss';
        calorieTarget = 1600; // Reduced for weight loss
    } else {
        bmiCategory = 'obese';
        dietType = 'weight_loss';
        calorieTarget = 1400; // Further reduced for significant weight loss
    }

    // Adjust calorie target based on age and gender
    if (age > 50) calorieTarget -= 200;
    if (gender === 'female') calorieTarget -= 200;

    // Generate meal plan
    const mealPlan = generateMealPlan(dietType, calorieTarget);

    // Generate nutritional guidelines
    const nutritionalGuidelines = getNutritionalGuidelines(bmiCategory, dietType);

    // Generate food recommendations
    const foodRecommendations = getFoodRecommendations(dietType, healthMetrics);

    // Generate water intake recommendation
    const waterIntake = calculateWaterIntake(bmi, healthMetrics.bloodSugar);

    return {
        bmiCategory,
        dietType,
        calorieTarget,
        mealPlan,
        nutritionalGuidelines,
        foodRecommendations,
        waterIntake,
        tips: getDietTips(dietType)
    };
};

// Generate meal plan based on diet type
const generateMealPlan = (dietType, calorieTarget) => {
    const meals = {
        breakfast: [],
        lunch: [],
        dinner: [],
        snacks: []
    };

    const baseMeals = {
        breakfast: [
            { name: 'Oatmeal with Berries', calories: 300, protein: 10, carbs: 50, fat: 8 },
            { name: 'Greek Yogurt Parfait', calories: 250, protein: 15, carbs: 35, fat: 5 },
            { name: 'Whole Grain Toast with Avocado', calories: 280, protein: 8, carbs: 40, fat: 12 },
            { name: 'Scrambled Eggs with Spinach', calories: 220, protein: 14, carbs: 10, fat: 15 },
            { name: 'Smoothie Bowl', calories: 320, protein: 12, carbs: 55, fat: 8 }
        ],
        lunch: [
            { name: 'Grilled Chicken Salad', calories: 350, protein: 30, carbs: 20, fat: 18 },
            { name: 'Quinoa Buddha Bowl', calories: 420, protein: 15, carbs: 55, fat: 14 },
            { name: 'Turkey Wrap with Veggies', calories: 380, protein: 25, carbs: 40, fat: 15 },
            { name: 'Salmon with Brown Rice', calories: 450, protein: 28, carbs: 45, fat: 18 },
            { name: 'Lentil Soup with Whole Grain Bread', calories: 320, protein: 12, carbs: 50, fat: 8 }
        ],
        dinner: [
            { name: 'Grilled Fish with Vegetables', calories: 380, protein: 32, carbs: 25, fat: 16 },
            { name: 'Chicken Stir-fry with Brown Rice', calories: 420, protein: 28, carbs: 48, fat: 14 },
            { name: 'Vegetable Curry with Quinoa', calories: 350, protein: 12, carbs: 55, fat: 10 },
            { name: 'Lean Beef with Sweet Potato', calories: 400, protein: 30, carbs: 35, fat: 16 },
            { name: 'Tofu Vegetable Bowl', calories: 320, protein: 18, carbs: 40, fat: 12 }
        ],
        snacks: [
            { name: 'Apple with Almond Butter', calories: 180, protein: 4, carbs: 22, fat: 10 },
            { name: 'Mixed Nuts (1 oz)', calories: 170, protein: 5, carbs: 6, fat: 15 },
            { name: 'Hummus with Carrots', calories: 150, protein: 5, carbs: 18, fat: 8 },
            { name: 'Greek Yogurt', calories: 100, protein: 15, carbs: 8, fat: 3 },
            { name: 'Protein Smoothie', calories: 200, protein: 20, carbs: 25, fat: 5 }
        ]
    };

    // Adjust portions based on calorie target
    const portionMultiplier = calorieTarget / 2000;

    // Select meals based on diet type
    if (dietType === 'weight_loss') {
        meals.breakfast = [baseMeals.breakfast[0], baseMeals.breakfast[1], baseMeals.breakfast[3]];
        meals.lunch = [baseMeals.lunch[0], baseMeals.lunch[2], baseMeals.lunch[4]];
        meals.dinner = [baseMeals.dinner[0], baseMeals.dinner[1], baseMeals.dinner[4]];
        meals.snacks = [baseMeals.snacks[2], baseMeals.snacks[3]];
    } else if (dietType === 'weight_gain') {
        meals.breakfast = [baseMeals.breakfast[2], baseMeals.breakfast[4], baseMeals.breakfast[0]];
        meals.lunch = [baseMeals.lunch[1], baseMeals.lunch[3], baseMeals.lunch[0]];
        meals.dinner = [baseMeals.dinner[1], baseMeals.dinner[3], baseMeals.dinner[0]];
        meals.snacks = [baseMeals.snacks[0], baseMeals.snacks[1], baseMeals.snacks[4]];
    } else {
        meals.breakfast = baseMeals.breakfast;
        meals.lunch = baseMeals.lunch;
        meals.dinner = baseMeals.dinner;
        meals.snacks = baseMeals.snacks;
    }

    // Adjust calories based on portion multiplier
    Object.keys(meals).forEach(mealType => {
        meals[mealType] = meals[mealType].map(meal => ({
            ...meal,
            calories: Math.round(meal.calories * portionMultiplier),
            protein: Math.round(meal.protein * portionMultiplier),
            carbs: Math.round(meal.carbs * portionMultiplier),
            fat: Math.round(meal.fat * portionMultiplier)
        }));
    });

    return meals;
};

// Get nutritional guidelines
const getNutritionalGuidelines = (bmiCategory, dietType) => {
    const guidelines = {
        macronutrients: {
            protein: '15-20% of daily calories',
            carbohydrates: '45-65% of daily calories',
            fats: '20-35% of daily calories',
            fiber: '25-35g per day'
        },
        vitamins: [
            'Vitamin D: 600-800 IU daily',
            'Vitamin B12: 2.4mcg daily',
            'Vitamin C: 75-90mg daily',
            'Calcium: 1000-1200mg daily',
            'Iron: 8-18mg daily'
        ],
        supplements: [],
        restrictions: []
    };

    if (dietType === 'weight_loss') {
        guidelines.restrictions.push('Limit processed foods', 'Reduce sodium intake', 'Avoid sugary drinks');
        guidelines.supplements.push('Consider multivitamin', 'Omega-3 supplement may help');
    } else if (dietType === 'weight_gain') {
        guidelines.macronutrients.protein = '20-25% of daily calories (higher for muscle building)';
        guidelines.supplements.push('Protein supplement may help', 'Creatine for muscle gain');
    }

    if (bmiCategory === 'obese') {
        guidelines.restrictions.push('Strict portion control', 'Limit carbohydrates', 'Increase protein intake');
    }

    return guidelines;
};

// Get food recommendations
const getFoodRecommendations = (dietType, healthMetrics) => {
    const recommendations = {
        foodsToEat: [],
        foodsToLimit: [],
        foodsToAvoid: []
    };

    const healthyFoods = [
        'Leafy green vegetables',
        'Whole grains',
        'Lean proteins',
        'Fresh fruits',
        'Nuts and seeds',
        'Fish rich in omega-3',
        'Low-fat dairy',
        'Legumes and beans',
        'Olive oil',
        'Avocados'
    ];

    const foodsToLimit = [
        'Processed meats',
        'Refined carbohydrates',
        'Added sugars',
        'Saturated fats',
        'Sodium-rich foods'
    ];

    const foodsToAvoid = [
        'Trans fats',
        'High-sugar beverages',
        'Processed snacks',
        'Fried foods',
        'Excessive alcohol'
    ];

    if (dietType === 'weight_loss') {
        recommendations.foodsToEat = [...healthyFoods, 'High-fiber foods', 'Low-calorie vegetables'];
        recommendations.foodsToLimit = [...foodsToLimit, 'High-calorie fruits', 'Dried fruits'];
        recommendations.foodsToAvoid = [...foodsToAvoid, 'White bread', 'White rice', 'Sweets'];
    } else if (dietType === 'weight_gain') {
        recommendations.foodsToEat = [...healthyFoods, 'Nutrient-dense foods', 'Healthy fats', 'Complex carbs'];
        recommendations.foodsToLimit = ['Low-calorie foods', 'Excessive fiber'];
        recommendations.foodsToAvoid = foodsToAvoid;
    } else {
        recommendations.foodsToEat = healthyFoods;
        recommendations.foodsToLimit = foodsToLimit;
        recommendations.foodsToAvoid = foodsToAvoid;
    }

    // Customize based on health metrics
    if (healthMetrics.bloodSugar && healthMetrics.bloodSugar > 100) {
        recommendations.foodsToLimit.push('High glycemic index foods');
        recommendations.foodsToAvoid.push('Sugary foods', 'White carbohydrates');
        recommendations.foodsToEat.push('Low glycemic index foods', 'High-fiber foods');
    }

    if (healthMetrics.bloodPressure) {
        const { systolic, diastolic } = healthMetrics.bloodPressure;
        if (systolic > 120 || diastolic > 80) {
            recommendations.foodsToLimit.push('High-sodium foods');
            recommendations.foodsToAvoid.push('Processed foods', 'Canned soups', 'Pickled foods');
            recommendations.foodsToEat.push('Potassium-rich foods', 'Low-sodium options');
        }
    }

    return recommendations;
};

// Calculate water intake recommendation
const calculateWaterIntake = (bmi, bloodSugar) => {
    let waterIntake = 8; // Base: 8 glasses per day

    // Adjust based on BMI
    if (bmi > 25) waterIntake += 1;
    if (bmi > 30) waterIntake += 1;

    // Adjust based on blood sugar
    if (bloodSugar && bloodSugar > 100) {
        waterIntake += 1; // More water helps with blood sugar
    }

    return waterIntake;
};

// Get diet tips
const getDietTips = (dietType) => {
    const tips = {
        weight_loss: [
            'Eat smaller portions more frequently',
            'Don\'t skip meals - especially breakfast',
            'Drink water before meals to feel fuller',
            'Focus on nutrient-dense, low-calorie foods',
            'Limit eating out to once per week',
            'Keep a food diary to track intake'
        ],
        weight_gain: [
            'Eat more frequent, larger meals',
            'Focus on calorie-dense healthy foods',
            'Include protein in every meal',
            'Don\'t skip meals',
            'Eat healthy snacks between meals',
            'Strength train to build muscle mass'
        ],
        maintenance: [
            'Maintain balanced macronutrients',
            'Practice portion control',
            'Stay hydrated throughout the day',
            'Limit processed foods',
            'Eat a variety of foods',
            'Listen to your hunger cues'
        ]
    };

    return tips[dietType] || tips.maintenance;
};

// @route   GET /api/diet
// @desc    Get personalized diet recommendations
// @access  Private
router.get('/', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;

    // Get user profile and latest health metrics
    // For now, we'll use query parameters or default values
    const bmi = parseFloat(req.query.bmi) || 22.0;
    const age = parseInt(req.query.age) || 30;
    const gender = req.query.gender || 'male';
    const goal = req.query.goal || 'maintenance';

    const userProfile = { bmi, age, gender, goal };

    // Get health metrics if available
    const healthMetrics = {};
    if (req.query.bloodSugar) healthMetrics.bloodSugar = parseFloat(req.query.bloodSugar);
    if (req.query.systolic && req.query.diastolic) {
        healthMetrics.bloodPressure = {
            systolic: parseInt(req.query.systolic),
            diastolic: parseInt(req.query.diastolic)
        };
    }

    // Generate recommendations
    const recommendations = getDietRecommendations(userProfile, healthMetrics);

    res.status(200).json({
      status: 'success',
      message: 'Diet recommendations generated successfully',
      data: {
        userProfile: {
          ...userProfile,
          bmiCategory: recommendations.bmiCategory
        },
        recommendations
      }
    });
  } catch (error) {
    console.error('Error generating diet recommendations:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to generate diet recommendations',
      error: error.message
    });
  }
});

// @route   GET /api/diet/meal-plan
// @desc    Get detailed meal plan for the day
// @access  Private
router.get('/meal-plan', authenticateToken, async (req, res) => {
  try {
    const { bmi = 22.0, gender = 'male', goal = 'maintenance' } = req.query;

    const userProfile = { bmi: parseFloat(bmi), gender, goal };
    const recommendations = getDietRecommendations(userProfile);

    res.status(200).json({
      status: 'success',
      message: 'Meal plan generated successfully',
      data: {
        mealPlan: recommendations.mealPlan,
        calorieTarget: recommendations.calorieTarget,
        nutritionalGuidelines: recommendations.nutritionalGuidelines
      }
    });
  } catch (error) {
    console.error('Error generating meal plan:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to generate meal plan',
      error: error.message
    });
  }
});

module.exports = router;