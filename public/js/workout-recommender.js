/**
 * Workout Recommender
 * Suggests personalized workouts based on user behavior and history
 */
class WorkoutRecommender {
  constructor() {
    this.userProfile = JSON.parse(localStorage.getItem('userProfile')) || {};
    this.workoutHistory = JSON.parse(localStorage.getItem('workoutHistory')) || [];
    this.todayData = this.getTodayData();
  }

  getTodayData() {
    const today = new Date().toISOString().split('T')[0];
    let todayData = JSON.parse(localStorage.getItem('todayData'));

    if (!todayData || todayData.date !== today) {
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

  getLastWorkout() {
    if (this.workoutHistory.length === 0) return null;

    const sortedWorkouts = this.workoutHistory
      .filter(entry => entry.workouts && entry.workouts.length > 0)
      .sort((a, b) => new Date(b.date) - new Date(a.date));

    return sortedWorkouts.length > 0 ? sortedWorkouts[0] : null;
  }

  daysSinceLastWorkout() {
    const lastWorkout = this.getLastWorkout();
    if (!lastWorkout) return 999;

    const lastWorkoutDate = new Date(lastWorkout.date);
    const daysDiff = Math.floor((new Date() - lastWorkoutDate) / (1000 * 60 * 60 * 24));

    return daysDiff;
  }

  getRecommendedWorkout() {
    const daysSince = this.daysSinceLastWorkout();
    const lastWorkout = this.getLastWorkout();
    const hour = new Date().getHours();

    // Get last workout type if available
    const lastType = lastWorkout && lastWorkout.workouts && lastWorkout.workouts.length > 0
      ? lastWorkout.workouts[0].type
      : null;

    let recommendation = {};

    if (daysSince >= 7) {
      // Been a week or more - suggest gentle yoga
      recommendation = {
        type: 'yoga',
        title: 'Gentle Yoga Session',
        description: `It's been ${daysSince}} days since your last workout. Let's ease back in with a relaxing yoga session.`,
        duration: 15,
        difficulty: 'beginner',
        icon: '🧘',
        exercises: [
          { name: 'Neck Stretches', duration: '2 min', reps: '1 set' },
          { name: 'Cat-Cow Pose', duration: '3 min', reps: '2 sets' },
          { name: 'Child\'s Pose', duration: '2 min', reps: '1 set' },
          { name: 'Gentle Twists', duration: '3 min', reps: '1 set each side' },
          { name: 'Deep Breathing', duration: '5 min', reps: '1 set' }
        ],
        benefits: ['Reduces stress', 'Improves flexibility', 'Gentle on joints'],
        calorieBurn: 80
      };
    } else if (daysSince >= 3) {
      // Been 3-6 days - suggest light cardio
      recommendation = {
        type: 'cardio',
        title: 'Light Cardio Session',
        description: `You haven't worked out in ${daysSince} days. Let's get moving with some light cardio!`,
        duration: 20,
        difficulty: 'beginner',
        icon: '🚶',
        exercises: [
          { name: 'Brisk Walking', duration: '10 min', reps: 'continuous' },
          { name: 'Marching in Place', duration: '3 min', reps: 'continuous' },
          { name: 'Step Touches', duration: '4 min', reps: 'continuous' },
          { name: 'Arm Circles', duration: '3 min', reps: 'continuous' }
        ],
        benefits: ['Boosts mood', 'Improves cardiovascular health', 'Low impact'],
        calorieBurn: 120
      };
    } else if (daysSince === 1) {
      // Worked out yesterday - suggest different muscle group
      if (lastType === 'cardio' || lastType === 'walk') {
        recommendation = {
          type: 'strength',
          title: 'Upper Body Strength',
          description: 'Great job on the cardio yesterday! Let's build some upper body strength today.',
          duration: 25,
          difficulty: 'intermediate',
          icon: '💪',
          exercises: [
            { name: 'Push-ups', duration: '5 min', reps: '3 sets of 10' },
            { name: 'Dumbbell Rows', duration: '5 min', reps: '3 sets of 12' },
            { name: 'Shoulder Press', duration: '5 min', reps: '3 sets of 10' },
            { name: 'Bicep Curls', duration: '5 min', reps: '3 sets of 12' },
            { name: 'Tricep Dips', duration: '5 min', reps: '3 sets of 15' }
          ],
          benefits: ['Builds muscle', 'Strengthens upper body', 'Improves posture'],
          calorieBurn: 180
        };
      } else if (lastType === 'strength' || lastType === 'yoga') {
        recommendation = {
          type: 'cardio',
          title: 'Cardio Blast',
          description: 'Nice strength work yesterday! Let's get your heart rate up today.',
          duration: 30,
          difficulty: 'intermediate',
          icon: '🏃',
          exercises: [
            { name: 'High Knees', duration: '5 min', reps: '30 sec intervals' },
            { name: 'Jumping Jacks', duration: '5 min', reps: '3 sets of 30' },
            { name: 'Burpees', duration: '5 min', reps: '3 sets of 10' },
            { name: 'Mountain Climbers', duration: '5 min', reps: '3 sets of 20' },
            { name: 'Box Jumps', duration: '5 min', reps: '3 sets of 15' },
            { name: 'Cool Down Walk', duration: '5 min', reps: 'continuous' }
          ],
          benefits: ['Improves endurance', 'Burns calories', 'Boosts metabolism'],
          calorieBurn: 250
        };
      } else {
        recommendation = {
          type: 'mixed',
          title: 'Full Body Workout',
          description: 'Great day for a balanced workout mixing cardio and strength!',
          duration: 30,
          difficulty: 'intermediate',
          icon: '🏋️',
          exercises: [
            { name: 'Jumping Jacks Warmup', duration: '3 min', reps: 'continuous' },
            { name: 'Squats', duration: '5 min', reps: '3 sets of 15' },
            { name: 'Push-ups', duration: '5 min', reps: '3 sets of 10' },
            { name: 'Lunges', duration: '5 min', reps: '3 sets of 12 each leg' },
            { name: 'Plank Hold', duration: '3 min', reps: '3 sets of 30 sec' },
            { name: 'High Knees', duration: '5 min', reps: '30 sec intervals' },
            { name: 'Cool Down Stretch', duration: '4 min', reps: 'continuous' }
          ],
          benefits: ['Full body workout', 'Balanced fitness', 'Time-efficient'],
          calorieBurn: 200
        };
      }
    } else {
      // No workout yesterday OR workout today - suggest moderate workout
      if (hour >= 5 && hour < 12) {
        // Morning - energizing workout
        recommendation = {
          type: 'cardio',
          title: 'Morning Energy Boost',
          description: 'Start your day with this energizing morning workout!',
          duration: 20,
          difficulty: 'beginner',
          icon: '☀️',
          exercises: [
            { name: 'Morning Stretches', duration: '5 min', reps: 'continuous' },
            { name: 'Jumping Jacks', duration: '5 min', reps: '3 sets of 20' },
            { name: 'High Knees', duration: '5 min', reps: '30 sec intervals' },
            { name: 'Arm Circles', duration: '5 min', reps: 'continuous' }
          ],
          benefits: ['Boosts energy', 'Improves focus', 'Gets blood flowing'],
          calorieBurn: 120
        };
      } else if (hour >= 12 && hour < 17) {
        // Afternoon - stress relief
        recommendation = {
          type: 'yoga',
          title: 'Afternoon Stress Relief',
          description: 'Take a break from work and refresh your mind and body.',
          duration: 15,
          difficulty: 'beginner',
          icon: '🧘',
          exercises: [
            { name: 'Deep Breathing', duration: '3 min', reps: 'continuous' },
            { name: 'Neck Rolls', duration: '2 min', reps: 'continuous' },
            { name: 'Shoulder Shrugs', duration: '2 min', reps: '2 sets of 15' },
            { name: 'Seated Twists', duration: '3 min', reps: '1 set each side' },
            { name: 'Forward Fold', duration: '5 min', reps: '2 sets' }
          ],
          benefits: ['Reduces stress', 'Improves posture', 'Refreshes mind'],
          calorieBurn: 60
        };
      } else {
        // Evening - relaxing workout
        recommendation = {
          type: 'yoga',
          title: 'Evening Wind Down',
          description: 'Unwind from your day with this relaxing evening session.',
          duration: 20,
          difficulty: 'beginner',
          icon: '🌙',
          exercises: [
            { name: 'Gentle Stretches', duration: '5 min', reps: 'continuous' },
            { name: 'Child\'s Pose', duration: '3 min', reps: 'hold for 1 min' },
            { name: 'Legs Up Wall', duration: '5 min', reps: 'relax and breathe' },
            { name: 'Gentle Twists', duration: '4 min', reps: 'continuous' },
            { name: 'Corpse Pose', duration: '3 min', reps: 'deep relaxation' }
          ],
          benefits: ['Promotes sleep', 'Reduces tension', 'Calms nervous system'],
          calorieBurn: 70
        };
      }
    }

    return recommendation;
  }

  getAlternativeWorkouts() {
    const recommended = this.getRecommendedWorkout();
    const alternatives = [];

    // Add different workout types as alternatives
    if (recommended.type !== 'cardio') {
      alternatives.push({
        type: 'cardio',
        title: 'Cardio Alternative',
        description: 'Prefer something more intense? Try this cardio workout.',
        duration: 25,
        difficulty: 'intermediate',
        icon: '🏃',
        exercisesCount: 6
      });
    }

    if (recommended.type !== 'strength') {
      alternatives.push({
        type: 'strength',
        title: 'Strength Alternative',
        description: 'Want to build muscle? Try this strength workout.',
        duration: 30,
        difficulty: 'intermediate',
        icon: '💪',
        exercisesCount: 8
      });
    }

    if (recommended.type !== 'yoga') {
      alternatives.push({
        type: 'yoga',
        title: 'Yoga Alternative',
        description: 'Need something more relaxing? Try this yoga session.',
        duration: 20,
        difficulty: 'beginner',
        icon: '🧘',
        exercisesCount: 5
      });
    }

    return alternatives;
  }

  renderRecommendedWorkout() {
    const workout = this.getRecommendedWorkout();
    const todayWorkouts = this.todayData.workouts || [];
    const alreadyCompleted = todayWorkouts.length > 0;

    return `
      <div class="recommended-workout-card ${alreadyCompleted ? 'completed' : ''}">
        ${alreadyCompleted ? '<div class="completed-badge">✅ Completed Today</div>' : ''}
        <div class="recommendation-badge">Recommended for Today</div>
        <div class="workout-icon">${workout.icon}</div>
        <h3>${workout.title}</h3>
        <p class="workout-description">${workout.description}</p>

        <div class="workout-meta">
          <div class="meta-item">
            <span class="meta-icon">⏱️</span>
            <span class="meta-text">${workout.duration} min</span>
          </div>
          <div class="meta-item">
            <span class="meta-icon">📊</span>
            <span class="meta-text">${workout.difficulty}</span>
          </div>
          <div class="meta-item">
            <span class="meta-icon">🔥</span>
            <span class="meta-text">~${workout.calorieBurn} cal</span>
          </div>
        </div>

        <div class="workout-benefits">
          ${workout.benefits.map(benefit => `<span class="benefit-tag">${benefit}</span>`).join('')}
        </div>

        <div class="workout-exercises">
          <h4>Exercises (${workout.exercises.length})</h4>
          <div class="exercises-list">
            ${workout.exercises.map((exercise, index) => `
              <div class="exercise-item">
                <span class="exercise-number">${index + 1}</span>
                <div class="exercise-info">
                  <span class="exercise-name">${exercise.name}</span>
                  <span class="exercise-details">${exercise.duration} • ${exercise.reps}</span>
                </div>
              </div>
            `).join('')}
          </div>
        </div>

        <div class="workout-actions">
          <button class="btn-primary btn-large" onclick="startRecommendedWorkout('${workout.type}')" ${alreadyCompleted ? 'disabled' : ''}>
            ${alreadyCompleted ? '✅ Done for Today!' : 'Start Workout'}
          </button>
          <button class="btn-secondary" onclick="showAlternativeWorkouts()">
            See Other Options
          </button>
        </div>
      </div>
    `;
  }

  completeWorkout(type, duration) {
    const workout = {
      type: type,
      duration: duration,
      timestamp: new Date().toISOString(),
      calories: this.estimateCalories(type, duration)
    };

    this.todayData.workouts.push(workout);
    localStorage.setItem('todayData', JSON.stringify(this.todayData));

    // Add to workout history
    const today = new Date().toISOString().split('T')[0];
    let historyEntry = this.workoutHistory.find(entry => entry.date === today);

    if (historyEntry) {
      if (!historyEntry.workouts) historyEntry.workouts = [];
      historyEntry.workouts.push(workout);
    } else {
      this.workoutHistory.push({
        date: today,
        workouts: [workout]
      });
    }

    localStorage.setItem('workoutHistory', JSON.stringify(this.workoutHistory));

    // Update streak
    if (typeof streakTracker !== 'undefined') {
      streakTracker.checkAndUpdateStreak();
    }

    // Update challenges
    if (typeof challengeSystem !== 'undefined') {
      challengeSystem.updateChallengeProgress('workout', 1);
    }
  }

  estimateCalories(type, duration) {
    const caloriesPerMinute = {
      'yoga': 5,
      'cardio': 10,
      'strength': 7,
      'mixed': 8
    };

    return (caloriesPerMinute[type] || 7) * duration;
  }
}

// Global workout recommender instance
let workoutRecommender;

// Initialize workout recommender
document.addEventListener('DOMContentLoaded', () => {
  workoutRecommender = new WorkoutRecommender();
});

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
  module.exports = WorkoutRecommender;
}
