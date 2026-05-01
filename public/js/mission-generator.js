/**
 * Mission Generator
 * Analyzes user behavior and generates personalized daily missions
 */
class MissionGenerator {
  constructor() {
    this.userProfile = JSON.parse(localStorage.getItem('userProfile')) || {};
    this.todayData = this.getTodayData();
    this.userHistory = JSON.parse(localStorage.getItem('userHistory')) || [];
  }

  getTodayData() {
    const today = new Date().toISOString().split('T')[0];
    let todayData = JSON.parse(localStorage.getItem('todayData'));

    if (!todayData || todayData.date !== today) {
      // Create new day data
      todayData = {
        date: today,
        calories: 0,
        protein: 0,
        water: 0,
        steps: 0,
        workouts: [],
        meals: []
      };
      localStorage.setItem('todayData', JSON.stringify(todayData));
    }

    return todayData;
  }

  getLast7DaysData() {
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    return this.userHistory.filter(entry => {
      const entryDate = new Date(entry.date);
      return entryDate >= sevenDaysAgo;
    });
  }

  generateDailyMissions() {
    const missions = [];
    const behavior = this.analyzeUserBehavior();

    // Water mission (always high priority if low intake)
    if (behavior.waterIntake < 4) {
      missions.push({
        id: 'water-' + Date.now(),
        type: 'water',
        title: 'Hydration Mission',
        description: 'Drink 8 glasses of water today',
        target: 8,
        current: behavior.waterIntake,
        priority: 'high',
        icon: '💧',
        unit: 'glasses',
        action: 'add-water',
        progress: Math.round((behavior.waterIntake / 8) * 100)
      });
    }

    // Steps mission (medium priority)
    if (behavior.steps < 5000) {
      missions.push({
        id: 'steps-' + Date.now(),
        type: 'steps',
        title: 'Step Count Challenge',
        description: 'Reach 10,000 steps today',
        target: 10000,
        current: behavior.steps,
        priority: behavior.steps < 3000 ? 'high' : 'medium',
        icon: '👟',
        unit: 'steps',
        action: 'start-walk',
        progress: Math.round((behavior.steps / 10000) * 100)
      });
    }

    // Calories mission (high priority if behind)
    const calorieProgress = behavior.caloriesConsumed / behavior.dailyCalorieTarget;
    if (calorieProgress < 0.5 && behavior.caloriesConsumed < behavior.dailyCalorieTarget * 0.8) {
      missions.push({
        id: 'calories-' + Date.now(),
        type: 'calories',
        title: 'Fuel Your Body',
        description: `Eat ${behavior.dailyCalorieTarget} calories today`,
        target: behavior.dailyCalorieTarget,
        current: behavior.caloriesConsumed,
        priority: 'high',
        icon: '🔥',
        unit: 'kcal',
        action: 'log-meal',
        progress: Math.round(calorieProgress * 100)
      });
    }

    // Workout mission (high priority if not done)
    if (!behavior.workoutCompleted) {
      missions.push({
        id: 'workout-' + Date.now(),
        type: 'workout',
        title: 'Get Moving',
        description: 'Complete a 20-minute workout',
        target: 1,
        current: 0,
        priority: 'high',
        icon: '🏋️',
        unit: 'workout',
        action: 'start-workout',
        progress: 0
      });
    }

    // Protein mission (low priority)
    if (behavior.proteinIntake < behavior.dailyProteinTarget * 0.8) {
      missions.push({
        id: 'protein-' + Date.now(),
        type: 'protein',
        title: 'Protein Boost',
        description: `Get ${behavior.dailyProteinTarget}g of protein`,
        target: behavior.dailyProteinTarget,
        current: behavior.proteinIntake,
        priority: 'low',
        icon: '🥩',
        unit: 'g',
        action: 'log-meal',
        progress: Math.round((behavior.proteinIntake / behavior.dailyProteinTarget) * 100)
      });
    }

    // Sort by priority and return top 3
    const priorityOrder = { 'high': 0, 'medium': 1, 'low': 2 };
    missions.sort((a, b) => priorityOrder[a.priority] - priorityOrder[b.priority]);

    return missions.slice(0, 3);
  }

  analyzeUserBehavior() {
    const last7Days = this.getLast7DaysData();

    return {
      waterIntake: this.todayData.water || 0,
      steps: this.todayData.steps || 0,
      caloriesConsumed: this.todayData.calories || 0,
      proteinIntake: this.todayData.protein || 0,
      dailyCalorieTarget: this.userProfile.dailyCalories || 2000,
      dailyProteinTarget: this.userProfile.dailyProtein || 50,
      workoutCompleted: (this.todayData.workouts || []).length > 0,
      avgWaterIntake: this.calculateAverage(last7Days, 'water'),
      avgSteps: this.calculateAverage(last7Days, 'steps'),
      avgCalories: this.calculateAverage(last7Days, 'calories'),
      skippedWorkouts: this.countSkippedWorkouts(last7Days),
      highCarbDinners: this.countHighCarbDinners(last7Days),
      lastWorkoutDays: this.daysSinceLastWorkout()
    };
  }

  calculateAverage(data, field) {
    if (data.length === 0) return 0;

    const sum = data.reduce((total, entry) => total + (entry[field] || 0), 0);
    return Math.round(sum / data.length);
  }

  countSkippedWorkouts(last7Days) {
    const today = new Date();
    let skippedCount = 0;

    for (let i = 1; i <= 7; i++) {
      const checkDate = new Date(today);
      checkDate.setDate(checkDate.getDate() - i);

      // Skip weekends (Saturday = 6, Sunday = 0)
      if (checkDate.getDay() === 0 || checkDate.getDay() === 6) {
        const hasWorkout = last7Days.some(entry => {
          const entryDate = new Date(entry.date);
          return entryDate.toDateString() === checkDate.toDateString() &&
                 (entry.workouts || []).length > 0;
        });

        if (!hasWorkout) {
          skippedCount++;
        }
      }
    }

    return skippedCount;
  }

  countHighCarbDinners(last7Days) {
    return last7Days.filter(entry => {
      const dinnerMeals = (entry.meals || []).filter(meal =>
        meal.type === 'dinner' && meal.calories > 600
      );
      return dinnerMeals.length > 0;
    }).length;
  }

  daysSinceLastWorkout() {
    const workouts = this.userHistory
      .filter(entry => (entry.workouts || []).length > 0)
      .sort((a, b) => new Date(b.date) - new Date(a.date));

    if (workouts.length === 0) return 999;

    const lastWorkoutDate = new Date(workouts[0].date);
    const daysDiff = Math.floor((new Date() - lastWorkoutDate) / (1000 * 60 * 60 * 24));

    return daysDiff;
  }

  generateBehavioralInsights() {
    const behavior = this.analyzeUserBehavior();
    const insights = [];

    // Weekend workout skipper
    if (behavior.skippedWorkouts >= 2) {
      insights.push({
        type: 'pattern',
        icon: '📅',
        title: 'Weekend Warrior?',
        message: 'You tend to skip workouts on weekends. Want to schedule a reminder?',
        action: 'scheduleReminder',
        actionLabel: 'Set Reminder',
        priority: 'medium'
      });
    }

    // Late night high carb
    if (behavior.highCarbDinners >= 3) {
      insights.push({
        type: 'nutrition',
        icon: '🌙',
        title: 'Evening Nutrition',
        message: 'Your dinners are high in carbs. Try lighter meals in the evening.',
        action: 'viewSuggestions',
        actionLabel: 'See Recipes',
        priority: 'low'
      });
    }

    // Haven't worked out in a while
    if (behavior.lastWorkoutDays >= 3) {
      insights.push({
        type: 'workout',
        icon: '🏃',
        title: 'Back on Track',
        message: `You haven't worked out in ${behavior.lastWorkoutDays} days. Try a light yoga session today!`,
        action: 'startYoga',
        actionLabel: 'Start Yoga',
        priority: 'high'
      });
    }

    // Low water intake
    if (behavior.avgWaterIntake < 5) {
      insights.push({
        type: 'hydration',
        icon: '💧',
        title: 'Hydration Goal',
        message: 'Your average water intake is below 5 glasses. Aim for 8 glasses daily!',
        action: 'setReminder',
        actionLabel: 'Set Reminder',
        priority: 'medium'
      });
    }

    // Good streak going
    const currentStreak = parseInt(localStorage.getItem('currentStreak') || '0');
    if (currentStreak >= 3) {
      insights.push({
        type: 'positive',
        icon: '🔥',
        title: 'Amazing Streak!',
        message: `You're on a ${currentStreak}-day streak! Keep it up!`,
        action: null,
        actionLabel: null,
        priority: 'low'
      });
    }

    return insights.slice(0, 3); // Return top 3 insights
  }

  getMissionProgress() {
    const missions = this.generateDailyMissions();
    const totalMissions = missions.length;
    const completedMissions = missions.filter(m => m.progress >= 100).length;

    return {
      total: totalMissions,
      completed: completedMissions,
      percentage: totalMissions > 0 ? Math.round((completedMissions / totalMissions) * 100) : 0
    };
  }

  updateMissionProgress(type, value) {
    // Update today's data
    this.todayData = this.getTodayData();

    switch(type) {
      case 'water':
        this.todayData.water = value;
        break;
      case 'steps':
        this.todayData.steps = value;
        break;
      case 'calories':
        this.todayData.calories = value;
        break;
      case 'protein':
        this.todayData.protein = value;
        break;
      case 'workout':
        if (!this.todayData.workouts) this.todayData.workouts = [];
        this.todayData.workouts.push({
          type: 'workout',
          timestamp: new Date().toISOString()
        });
        break;
    }

    localStorage.setItem('todayData', JSON.stringify(this.todayData));
  }
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
  module.exports = MissionGenerator;
}
