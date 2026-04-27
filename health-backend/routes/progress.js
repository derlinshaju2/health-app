const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const Progress = require('../models/Progress');

// @route   POST /api/progress
// @desc    Log daily progress (diet, yoga, wellness)
// @access  Private
router.post('/', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { date, diet, yoga, wellness } = req.body;

    // Check if progress already exists for this date
    const existingProgress = await Progress.findOne({
      userId,
      date: new Date(date).setHours(0,0,0,0)
    });

    let progress;

    if (existingProgress) {
      // Update existing progress
      if (diet) {
        Object.assign(existingProgress.diet, diet);
      }
      if (yoga) {
        Object.assign(existingProgress.yoga, yoga);
      }
      if (wellness) {
        Object.assign(existingProgress.wellness, wellness);
      }

      progress = await existingProgress.save();
    } else {
      // Create new progress entry
      progress = new Progress({
        userId,
        date: date || new Date(),
        diet: diet || {},
        yoga: yoga || {},
        wellness: wellness || {}
      });

      progress = await progress.save();

      // Check for achievements
      await checkAchievements(userId, progress);
    }

    res.status(201).json({
      status: 'success',
      message: 'Progress logged successfully',
      data: progress
    });
  } catch (error) {
    console.error('Error logging progress:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to log progress',
      error: error.message
    });
  }
});

// @route   GET /api/progress
// @desc    Get user's progress history
// @access  Private
router.get('/', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { limit = 30, startDate, endDate } = req.query;

    // Build query
    const query = { userId };

    // Add date range filter if provided
    if (startDate || endDate) {
      query.date = {};
      if (startDate) query.date.$gte = new Date(startDate);
      if (endDate) query.date.$lte = new Date(endDate);
    }

    // Get progress with pagination
    const progress = await Progress.find(query)
      .sort({ date: -1 })
      .limit(parseInt(limit))
      .exec();

    // Calculate statistics
    const stats = calculateProgressStats(progress);

    res.status(200).json({
      status: 'success',
      message: 'Progress retrieved successfully',
      data: {
        progress,
        statistics: stats
      }
    });
  } catch (error) {
    console.error('Error fetching progress:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch progress',
      error: error.message
    });
  }
});

// @route   GET /api/progress/today
// @desc    Get today's progress
// @access  Private
router.get('/today', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const progress = await Progress.findOne({ userId, date: { $gte: today } });

    if (!progress) {
      return res.status(200).json({
        status: 'success',
        message: 'No progress logged for today',
        data: null
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Today\'s progress retrieved successfully',
      data: progress
    });
  } catch (error) {
    console.error('Error fetching today\'s progress:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch today\'s progress',
      error: error.message
    });
  }
});

// @route   GET /api/progress/statistics
// @desc    Get progress statistics and insights
// @access  Private
router.get('/statistics', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { days = 30 } = req.query;

    // Calculate date range
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    // Get progress in date range
    const progress = await Progress.find({
      userId,
      date: { $gte: startDate, $lte: endDate }
    }).sort({ date: 1 });

    if (!progress || progress.length === 0) {
      return res.status(200).json({
        status: 'success',
        message: 'No progress data available',
        data: {
          totalDays: 0,
          dietStats: {},
          yogaStats: {},
          wellnessStats: {},
          trends: []
        }
      });
    }

    // Calculate comprehensive statistics
    const statistics = {
      totalDays: progress.length,
      dateRange: { start: startDate, end: endDate },
      dietStats: calculateDietStats(progress),
      yogaStats: calculateYogaStats(progress),
      wellnessStats: calculateWellnessStats(progress),
      trends: calculateTrends(progress)
    };

    res.status(200).json({
      status: 'success',
      message: 'Progress statistics calculated successfully',
      data: statistics
    });
  } catch (error) {
    console.error('Error calculating statistics:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to calculate statistics',
      error: error.message
    });
  }
});

// @route   GET /api/progress/achievements
// @desc    Get user's achievements
// @access  Private
router.get('/achievements', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;

    // Get all progress entries with achievements
    const progress = await Progress.find({ userId }).sort({ date: -1 });

    const allAchievements = [];
    progress.forEach(p => {
      if (p.achievements && p.achievements.length > 0) {
        allAchievements.push(...p.achievements.map(a => ({
          ...a.toObject(),
          date: p.date
        })));
      }
    });

    // Sort by date and get unique achievements
    const uniqueAchievements = allAchievements.sort((a, b) => b.date - a.date);

    res.status(200).json({
      status: 'success',
      message: 'Achievements retrieved successfully',
      data: {
        total: uniqueAchievements.length,
        achievements: uniqueAchievements
      }
    });
  } catch (error) {
    console.error('Error fetching achievements:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch achievements',
      error: error.message
    });
  }
});

// Helper functions

// Calculate overall progress statistics
const calculateProgressStats = (progressData) => {
  if (!progressData || progressData.length === 0) {
    return { totalDays: 0, activeDays: 0, streak: 0 };
  }

  const totalDays = progressData.length;
  const activeDays = progressData.filter(p =>
    p.yoga.durationMinutes > 0 || p.diet.caloriesConsumed > 0
  ).length;

  // Calculate current streak
  let streak = 0;
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  for (let i = 0; i < progressData.length; i++) {
    const progressDate = new Date(progressData[i].date);
    progressDate.setHours(0, 0, 0, 0);

    const diffTime = Math.abs(today - progressDate);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    if (diffDays === i && (progressData[i].yoga.durationMinutes > 0 || progressData[i].diet.caloriesConsumed > 0)) {
      streak++;
    } else {
      break;
    }
  }

  return {
    totalDays,
    activeDays,
    streak,
    consistency: Math.round((activeDays / totalDays) * 100)
  };
};

// Calculate diet-specific statistics
const calculateDietStats = (progressData) => {
  const dietEntries = progressData.filter(p => p.diet && p.diet.caloriesConsumed > 0);

  if (dietEntries.length === 0) {
    return { entries: 0, averageCalories: 0, targetAchieved: 0, averageWater: 0 };
  }

  const totalCalories = dietEntries.reduce((sum, p) => sum + p.diet.caloriesConsumed, 0);
  const totalWater = dietEntries.reduce((sum, p) => sum + (p.diet.waterIntake || 0), 0);
  const targetAchieved = dietEntries.filter(p => p.diet.dietPlanFollowed).length;

  return {
    entries: dietEntries.length,
    averageCalories: Math.round(totalCalories / dietEntries.length),
    targetAchieved: Math.round((targetAchieved / dietEntries.length) * 100),
    averageWater: Math.round((totalWater / dietEntries.length) * 10) / 10,
    totalDaysOnPlan: targetAchieved
  };
};

// Calculate yoga-specific statistics
const calculateYogaStats = (progressData) => {
  const yogaEntries = progressData.filter(p => p.yoga && p.yoga.durationMinutes > 0);

  if (yogaEntries.length === 0) {
    return { entries: 0, totalMinutes: 0, averageMinutes: 0, targetAchieved: 0 };
  }

  const totalMinutes = yogaEntries.reduce((sum, p) => sum + p.yoga.durationMinutes, 0);
  const targetAchieved = yogaEntries.filter(p => p.yoga.durationMinutes >= (p.yoga.targetMinutes || 30)).length;

  return {
    entries: yogaEntries.length,
    totalMinutes: totalMinutes,
    averageMinutes: Math.round(totalMinutes / yogaEntries.length),
    targetAchieved: Math.round((targetAchieved / yogaEntries.length) * 100),
    mostCommonDifficulty: getMostCommonDifficulty(yogaEntries)
  };
};

// Calculate wellness statistics
const calculateWellnessStats = (progressData) => {
  const wellnessEntries = progressData.filter(p => p.wellness);

  if (wellnessEntries.length === 0) {
    return { entries: 0, averageEnergy: 0, averageMood: 'N/A', averageSleep: 0 };
  }

  const totalEnergy = wellnessEntries.reduce((sum, p) => sum + (p.wellness.energyLevel || 5), 0);
  const totalSleep = wellnessEntries.reduce((sum, p) => sum + (p.wellness.sleepQuality || 5), 0);
  const totalStress = wellnessEntries.reduce((sum, p) => sum + (p.wellness.stressLevel || 5), 0);

  const moodCounts = {};
  wellnessEntries.forEach(p => {
    const mood = p.wellness.mood || 'neutral';
    moodCounts[mood] = (moodCounts[mood] || 0) + 1;
  });

  const mostCommonMood = Object.keys(moodCounts).reduce((a, b) =>
    moodCounts[a] > moodCounts[b] ? a : b
  );

  return {
    entries: wellnessEntries.length,
    averageEnergy: Math.round(totalEnergy / wellnessEntries.length),
    averageSleep: Math.round(totalSleep / wellnessEntries.length),
    averageStress: Math.round(totalStress / wellnessEntries.length),
    mostCommonMood,
    moodDistribution: moodCounts
  };
};

// Calculate trends
const calculateTrends = (progressData) => {
  if (progressData.length < 2) {
    return [];
  }

  const trends = [];
  const recent = progressData.slice(0, 7); // Last 7 days

  // Weight trend (if available)
  const weights = recent.filter(p => p.diet && p.diet.caloriesConsumed > 0);
  if (weights.length >= 2) {
    const avgStart = weights.slice(0, Math.floor(weights.length / 2))
      .reduce((sum, p) => sum + p.diet.caloriesConsumed, 0) / Math.floor(weights.length / 2);
    const avgEnd = weights.slice(Math.floor(weights.length / 2))
      .reduce((sum, p) => sum + p.diet.caloriesConsumed, 0) / Math.ceil(weights.length / 2);

    trends.push({
      type: 'calorie_intake',
      trend: avgStart > avgEnd ? 'decreasing' : 'increasing',
      description: avgStart > avgEnd ? 'Calorie intake decreasing' : 'Calorie intake increasing'
    });
  }

  // Yoga duration trend
  const yogaDays = recent.filter(p => p.yoga && p.yoga.durationMinutes > 0);
  if (yogaDays.length >= 2) {
    const avgStart = yogaDays.slice(0, Math.floor(yogaDays.length / 2))
      .reduce((sum, p) => sum + p.yoga.durationMinutes, 0) / Math.floor(yogaDays.length / 2);
    const avgEnd = yogaDays.slice(Math.floor(yogaDays.length / 2))
      .reduce((sum, p) => sum + p.yoga.durationMinutes, 0) / Math.ceil(yogaDays.length / 2);

    trends.push({
      type: 'yoga_duration',
      trend: avgStart < avgEnd ? 'increasing' : 'decreasing',
      description: avgStart < avgEnd ? 'Yoga practice increasing' : 'Yoga practice decreasing'
    });
  }

  // Energy level trend
  const energyEntries = recent.filter(p => p.wellness && p.wellness.energyLevel);
  if (energyEntries.length >= 2) {
    const avgStart = energyEntries.slice(0, Math.floor(energyEntries.length / 2))
      .reduce((sum, p) => sum + p.wellness.energyLevel, 0) / Math.floor(energyEntries.length / 2);
    const avgEnd = energyEntries.slice(Math.floor(energyEntries.length / 2))
      .reduce((sum, p) => sum + p.wellness.energyLevel, 0) / Math.ceil(energyEntries.length / 2);

    trends.push({
      type: 'energy_level',
      trend: avgStart < avgEnd ? 'improving' : 'declining',
      description: avgStart < avgEnd ? 'Energy levels improving' : 'Energy levels declining'
    });
  }

  return trends;
};

// Get most common yoga difficulty
const getMostCommonDifficulty = (yogaEntries) => {
  const counts = { beginner: 0, intermediate: 0, advanced: 0 };
  yogaEntries.forEach(p => {
    const difficulty = p.yoga.difficulty || 'beginner';
    counts[difficulty]++;
  });

  return Object.keys(counts).reduce((a, b) => counts[a] > counts[b] ? a : b);
};

// Check and award achievements
const checkAchievements = async (userId, progress) => {
  const achievements = [];

  // Diet achievements
  if (progress.diet && progress.diet.dietPlanFollowed) {
    achievements.push({
      type: 'diet',
      title: 'Diet Discipline',
      description: 'Followed your diet plan for the day',
      date: new Date()
    });
  }

  // Yoga achievements
  if (progress.yoga && progress.yoga.durationMinutes >= 30) {
    achievements.push({
      type: 'yoga',
      title: 'Dedicated Yogi',
      description: 'Completed 30+ minutes of yoga',
      date: new Date()
    });
  }

  if (progress.yoga && progress.yoga.posesCompleted >= 10) {
    achievements.push({
      type: 'yoga',
      title: 'Pose Master',
      description: 'Completed 10+ yoga poses',
      date: new Date()
    });
  }

  // Wellness achievements
  if (progress.wellness && progress.wellness.energyLevel >= 8) {
    achievements.push({
      type: 'wellness',
      title: 'High Energy',
      description: 'Reported high energy levels',
      date: new Date()
    });
  }

  if (progress.wellness && progress.wellness.mood === 'excellent') {
    achievements.push({
      type: 'wellness',
      title: 'Great Mood',
      description: 'Feeling excellent today',
      date: new Date()
    });
  }

  // Add achievements to progress if any
  if (achievements.length > 0) {
    progress.achievements.push(...achievements);
    await progress.save();
  }

  return achievements;
};

module.exports = router;