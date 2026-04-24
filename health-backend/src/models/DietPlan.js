const mongoose = require('mongoose');

const foodItemSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  calories: {
    type: Number,
    required: true,
    min: [0, 'Calories must be non-negative']
  },
  protein: {
    type: Number,
    default: 0,
    min: [0, 'Protein must be non-negative']
  },
  carbs: {
    type: Number,
    default: 0,
    min: [0, 'Carbs must be non-negative']
  },
  fats: {
    type: Number,
    default: 0,
    min: [0, 'Fats must be non-negative']
  },
  fiber: {
    type: Number,
    default: 0,
    min: [0, 'Fiber must be non-negative']
  },
  servingSize: {
    type: String,
    trim: true
  }
});

const mealSchema = new mongoose.Schema({
  type: {
    type: String,
    required: true,
    enum: ['breakfast', 'lunch', 'dinner', 'snack']
  },
  foods: [foodItemSchema],
  totalCalories: {
    type: Number,
    default: 0
  },
  notes: {
    type: String,
    trim: true
  }
});

const dietPlanSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required'],
    index: true
  },
  date: {
    type: Date,
    required: [true, 'Date is required'],
    default: Date.now,
    index: true
  },
  dailyCalorieTarget: {
    type: Number,
    required: true,
    min: [1000, 'Daily calorie target must be at least 1000'],
    max: [5000, 'Daily calorie target must be less than 5000']
  },
  meals: [mealSchema],
  waterIntake: {
    target: {
      type: Number,
      default: 8, // glasses
      min: [1, 'Water target must be at least 1 glass']
    },
    current: {
      type: Number,
      default: 0,
      min: [0, 'Current water intake must be non-negative']
    }
  },
  totalMacros: {
    calories: { type: Number, default: 0 },
    protein: { type: Number, default: 0 },
    carbs: { type: Number, default: 0 },
    fats: { type: Number, default: 0 },
    fiber: { type: Number, default: 0 }
  },
  recommendations: {
    type: String,
    trim: true
  },
  isCompleted: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// Compound index for efficient queries
dietPlanSchema.index({ userId: 1, date: -1 });

// Pre-save middleware to calculate totals
dietPlanSchema.pre('save', function(next) {
  // Calculate total macros from all meals
  let totalCalories = 0;
  let totalProtein = 0;
  let totalCarbs = 0;
  let totalFats = 0;
  let totalFiber = 0;

  this.meals.forEach(meal => {
    let mealCalories = 0;
    meal.foods.forEach(food => {
      mealCalories += food.calories;
      totalProtein += food.protein || 0;
      totalCarbs += food.carbs || 0;
      totalFats += food.fats || 0;
      totalFiber += food.fiber || 0;
    });
    meal.totalCalories = mealCalories;
    totalCalories += mealCalories;
  });

  this.totalMacros = {
    calories: totalCalories,
    protein: Math.round(totalProtein),
    carbs: Math.round(totalCarbs),
    fats: Math.round(totalFats),
    fiber: Math.round(totalFiber)
  };

  next();
});

// Method to add food to a meal
dietPlanSchema.methods.addFoodToMeal = function(mealType, foodItem) {
  const meal = this.meals.find(m => m.type === mealType);
  if (meal) {
    meal.foods.push(foodItem);
    return this.save();
  } else {
    const error = new Error('Meal type not found');
    return Promise.reject(error);
  }
};

// Method to update water intake
dietPlanSchema.methods.updateWaterIntake = function(glasses) {
  this.waterIntake.current = Math.max(0, Math.min(this.waterIntake.target, this.waterIntake.current + glasses));
  return this.save();
};

// Method to get calorie progress
dietPlanSchema.methods.getCalorieProgress = function() {
  const remaining = this.dailyCalorieTarget - this.totalMacros.calories;
  const percentage = Math.round((this.totalMacros.calories / this.dailyCalorieTarget) * 100);

  return {
    consumed: this.totalMacros.calories,
    target: this.dailyCalorieTarget,
    remaining: Math.max(0, remaining),
    percentage: Math.min(100, percentage),
    isOverTarget: this.totalMacros.calories > this.dailyCalorieTarget
  };
};

const DietPlan = mongoose.model('DietPlan', dietPlanSchema);

module.exports = DietPlan;