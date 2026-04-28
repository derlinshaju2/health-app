const mongoose = require('mongoose');

const yogaSessionSchema = new mongoose.Schema({
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
  routineType: {
    type: String,
    required: true,
    enum: ['flexibility', 'stress_relief', 'weight_loss', 'diabetes_management', 'general', 'custom']
  },
  routineName: {
    type: String,
    required: true,
    trim: true
  },
  duration: {
    type: Number, // in minutes
    required: true,
    min: [1, 'Duration must be at least 1 minute'],
    max: [180, 'Duration must be less than 180 minutes']
  },
  poses: [{
    name: {
      type: String,
      required: true,
      trim: true
    },
    duration: {
      type: Number, // seconds
      required: true,
      min: [10, 'Pose duration must be at least 10 seconds'],
      max: [300, 'Pose duration must be less than 300 seconds']
    },
    repetitions: {
      type: Number,
      default: 1,
      min: [1, 'Repetitions must be at least 1']
    },
    completed: {
      type: Boolean,
      default: false
    }
  }],
  difficulty: {
    type: String,
    enum: ['beginner', 'intermediate', 'advanced'],
    default: 'beginner'
  },
  caloriesBurned: {
    type: Number,
    default: 0,
    min: [0, 'Calories burned must be non-negative']
  },
  completed: {
    type: Boolean,
    default: false
  },
  completionPercentage: {
    type: Number,
    default: 0,
    min: [0, 'Completion percentage must be at least 0'],
    max: [100, 'Completion percentage must be at most 100']
  },
  notes: {
    type: String,
    trim: true,
    maxlength: [500, 'Notes must be less than 500 characters']
  },
  mood: {
    type: String,
    enum: ['energetic', 'relaxed', 'tired', 'stressed', 'neutral'],
    default: 'neutral'
  },
  userRating: {
    type: Number,
    min: [1, 'Rating must be at least 1'],
    max: [5, 'Rating must be at most 5']
  }
}, {
  timestamps: true
});

// Compound index for efficient queries
yogaSessionSchema.index({ userId: 1, date: -1 });
yogaSessionSchema.index({ userId: 1, completed: 1 });

// Pre-save middleware to calculate completion percentage
yogaSessionSchema.pre('save', function(next) {
  if (this.poses.length > 0) {
    const completedPoses = this.poses.filter(pose => pose.completed).length;
    this.completionPercentage = Math.round((completedPoses / this.poses.length) * 100);
    this.completed = this.completionPercentage === 100;
  }

  // Estimate calories burned (rough estimate: 3-4 calories per minute for yoga)
  if (!this.caloriesBurned && this.duration) {
    this.caloriesBurned = Math.round(this.duration * 3.5);
  }

  next();
});

// Static method to get user's yoga statistics
yogaSessionSchema.statics.getUserStats = function(userId, startDate, endDate) {
  const matchCondition = {
    userId,
    completed: true
  };

  if (startDate && endDate) {
    matchCondition.date = {
      $gte: new Date(startDate),
      $lte: new Date(endDate)
    };
  }

  return this.aggregate([
    { $match: matchCondition },
    {
      $group: {
        _id: null,
        totalSessions: { $sum: 1 },
        totalDuration: { $sum: '$duration' },
        totalCaloriesBurned: { $sum: '$caloriesBurned' },
        avgDuration: { $avg: '$duration' },
        avgCaloriesBurned: { $avg: '$caloriesBurned' }
      }
    }
  ]).then(result => result[0] || {
    totalSessions: 0,
    totalDuration: 0,
    totalCaloriesBurned: 0,
    avgDuration: 0,
    avgCaloriesBurned: 0
  });
};

// Static method to get current streak
yogaSessionSchema.statics.getCurrentStreak = function(userId) {
  const today = new Date();
  today.setHours(23, 59, 59, 999);

  return this.find({
    userId,
    completed: true,
    date: { $lte: today }
  }).sort({ date: -1 }).then(sessions => {
    if (sessions.length === 0) return 0;

    let streak = 0;
    let currentDate = today;

    for (const session of sessions) {
      const sessionDate = new Date(session.date);
      sessionDate.setHours(0, 0, 0, 0);
      const checkDate = new Date(currentDate);
      checkDate.setHours(0, 0, 0, 0);

      const diffTime = Math.abs(checkDate - sessionDate);
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

      if (diffDays <= 1) {
        streak++;
        currentDate = new Date(sessionDate);
        currentDate.setDate(currentDate.getDate() - 1);
      } else {
        break;
      }
    }

    return streak;
  });
};

// Static method to get most practiced routine
yogaSessionSchema.statics.getMostPracticedRoutine = function(userId) {
  return this.aggregate([
    { $match: { userId, completed: true } },
    {
      $group: {
        _id: '$routineType',
        count: { $sum: 1 },
        totalDuration: { $sum: '$duration' }
      }
    },
    { $sort: { count: -1 } },
    { $limit: 1 }
  ]).then(result => result[0] || null);
};

const YogaSession = mongoose.model('YogaSession', yogaSessionSchema);

module.exports = YogaSession;