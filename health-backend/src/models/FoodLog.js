const mongoose = require('mongoose');

const foodLogSchema = new mongoose.Schema({
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
  meals: [{
    type: {
      type: String,
      required: true,
      enum: ['breakfast', 'lunch', 'dinner', 'snack']
    },
    time: {
      type: Date,
      default: Date.now
    },
    foods: [{
      name: {
        type: String,
        required: true,
        trim: true
      },
      calories: {
        type: Number,
        default: 0,
        min: [0, 'Calories must be non-negative']
      },
      protein: {
        type: Number,
        default: 0
      },
      carbs: {
        type: Number,
        default: 0
      },
      fats: {
        type: Number,
        default: 0
      }
    }],
    notes: {
      type: String,
      trim: true
    }
  }],
  totalCalories: {
    type: Number,
    default: 0
  },
  waterIntake: {
    type: Number,
    default: 0,
    min: [0, 'Water intake must be non-negative']
  },
  notes: {
    type: String,
    trim: true,
    maxlength: [500, 'Notes must be less than 500 characters']
  }
}, {
  timestamps: true
});

// Compound index for efficient queries
foodLogSchema.index({ userId: 1, date: -1 });

// Pre-save middleware to calculate total calories
foodLogSchema.pre('save', function(next) {
  let totalCalories = 0;

  this.meals.forEach(meal => {
    meal.foods.forEach(food => {
      totalCalories += food.calories || 0;
    });
  });

  this.totalCalories = totalCalories;
  next();
});

// Static method to get or create food log for a date
foodLogSchema.statics.getOrCreateByUserIdAndDate = function(userId, date) {
  const startOfDay = new Date(date);
  startOfDay.setHours(0, 0, 0, 0);

  const endOfDay = new Date(date);
  endOfDay.setHours(23, 59, 59, 999);

  return this.findOne({
    userId,
    date: {
      $gte: startOfDay,
      $lte: endOfDay
    }
  }).then(log => {
    if (!log) {
      return this.create({ userId, date: new Date() });
    }
    return log;
  });
};

const FoodLog = mongoose.model('FoodLog', foodLogSchema);

module.exports = FoodLog;