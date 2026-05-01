/**
 * Challenge System
 * Provides users with specific challenges and rewards
 */
class ChallengeSystem {
  constructor() {
    this.activeChallenges = JSON.parse(localStorage.getItem('activeChallenges')) || [];
    this.completedChallenges = JSON.parse(localStorage.getItem('completedChallenges')) || [];
    this.availableChallenges = this.getDefaultChallenges();
    this.userPoints = parseInt(localStorage.getItem('userPoints')) || 0;
    this.userBadges = JSON.parse(localStorage.getItem('userBadges')) || [];
    this.init();
  }

  init() {
    // Check if any active challenges have expired
    this.checkExpiredChallenges();

    // Update challenge progress based on today's data
    this.updateAllChallengeProgress();
  }

  getDefaultChallenges() {
    return [
      {
        id: 'hydration-7day',
        title: '7-Day Hydration Challenge',
        description: 'Drink 8 glasses of water for 7 consecutive days',
        duration: 7,
        target: 8,
        unit: 'glasses',
        type: 'daily',
        reward: { points: 100, badge: 'Hydration Hero' },
        progress: 0,
        startDate: null,
        endDate: null
      },
      {
        id: 'steps-10k',
        title: '10K Steps Challenge',
        description: 'Reach 10,000 steps in a single day',
        duration: 1,
        target: 10000,
        unit: 'steps',
        type: 'daily',
        reward: { points: 50, badge: 'Step Master' },
        progress: 0,
        startDate: null,
        endDate: null
      },
      {
        id: 'workout-streak-7',
        title: '7-Day Workout Streak',
        description: 'Workout every day for 7 consecutive days',
        duration: 7,
        target: 1,
        unit: 'workouts',
        type: 'streak',
        reward: { points: 200, badge: 'Workout Warrior' },
        progress: 0,
        startDate: null,
        endDate: null
      },
      {
        id: 'protein-goal',
        title: 'Protein Champion',
        description: 'Hit your daily protein target for 5 days',
        duration: 5,
        target: 1,
        unit: 'days',
        type: 'daily',
        reward: { points: 75, badge: 'Protein Pro' },
        progress: 0,
        startDate: null,
        endDate: null
      },
      {
        id: 'calorie-tracking',
        title: 'Tracking Master',
        description: 'Log all your meals for 7 consecutive days',
        duration: 7,
        target: 3,
        unit: 'meals',
        type: 'daily',
        reward: { points: 150, badge: 'Tracking Titan' },
        progress: 0,
        startDate: null,
        endDate: null
      },
      {
        id: 'early-bird',
        title: 'Early Bird Special',
        description: 'Complete a workout before 8 AM for 5 days',
        duration: 5,
        target: 1,
        unit: 'workouts',
        type: 'special',
        reward: { points: 100, badge: 'Morning Champion' },
        progress: 0,
        startDate: null,
        endDate: null
      }
    ];
  }

  startChallenge(challengeId) {
    const challenge = this.availableChallenges.find(c => c.id === challengeId);

    if (!challenge) {
      console.error('Challenge not found:', challengeId);
      return;
    }

    // Check if already active
    if (this.activeChallenges.find(c => c.id === challengeId)) {
      this.showNotification('Challenge Already Active', 'You\'re already working on this challenge!');
      return;
    }

    // Check if already completed
    if (this.completedChallenges.find(c => c.id === challengeId)) {
      this.showNotification('Challenge Completed', 'You\'ve already completed this challenge!');
      return;
    }

    // Create active challenge
    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(endDate.getDate() + challenge.duration);

    const activeChallenge = {
      ...challenge,
      startDate: startDate.toISOString(),
      endDate: endDate.toISOString(),
      progress: 0,
      dailyProgress: [],
      currentDay: 1
    };

    this.activeChallenges.push(activeChallenge);
    this.save();
    this.showNotification('Challenge Started! 💪', `Good luck with: ${challenge.title}`);
  }

  updateAllChallengeProgress() {
    const todayData = JSON.parse(localStorage.getItem('todayData')) || {};
    const userProfile = JSON.parse(localStorage.getItem('userProfile')) || {};

    this.activeChallenges.forEach(challenge => {
      let currentProgress = 0;
      const today = new Date().toISOString().split('T')[0];

      switch(challenge.unit) {
        case 'glasses':
          currentProgress = todayData.water || 0;
          break;
        case 'steps':
          currentProgress = todayData.steps || 0;
          break;
        case 'workouts':
          if (challenge.type === 'special' && challenge.id === 'early-bird') {
            // Check if workout was done before 8 AM
            const earlyWorkouts = (todayData.workouts || []).filter(w => {
              const workoutTime = new Date(w.timestamp);
              return workoutTime.getHours() < 8;
            });
            currentProgress = earlyWorkouts.length > 0 ? 1 : 0;
          } else {
            currentProgress = (todayData.workouts || []).length > 0 ? 1 : 0;
          }
          break;
        case 'days':
          // Check if protein target met
          if (todayData.protein >= (userProfile.dailyProtein || 50)) {
            currentProgress = 1;
          }
          break;
        case 'meals':
          currentProgress = (todayData.meals || []).length;
          break;
      }

      // Update challenge progress
      this.updateChallengeProgress(challenge.id, currentProgress);
    });
  }

  updateChallengeProgress(challengeId, currentValue) {
    const challengeIndex = this.activeChallenges.findIndex(c => c.id === challengeId);

    if (challengeIndex === -1) return;

    const challenge = this.activeChallenges[challengeIndex];

    // Update daily progress
    const today = new Date().toISOString().split('T')[0];
    const todayProgress = challenge.dailyProgress.find(p => p.date === today);

    if (todayProgress) {
      todayProgress.value = currentValue;
    } else {
      challenge.dailyProgress.push({
        date: today,
        value: currentValue
      });
    }

    // Calculate overall progress based on challenge type
    if (challenge.type === 'streak' || challenge.type === 'daily') {
      // Count days where target was met
      const successfulDays = challenge.dailyProgress.filter(p => p.value >= challenge.target).length;
      challenge.progress = successfulDays;
      challenge.currentDay = challenge.dailyProgress.length;
    } else {
      // Single-day challenge
      challenge.progress = currentValue;
    }

    // Check if challenge is complete
    if (challenge.progress >= challenge.target) {
      this.completeChallenge(challengeId);
    } else {
      this.save();
    }
  }

  completeChallenge(challengeId) {
    const challengeIndex = this.activeChallenges.findIndex(c => c.id === challengeId);

    if (challengeIndex === -1) return;

    const challenge = this.activeChallenges[challengeIndex];

    // Move to completed
    this.completedChallenges.push({
      ...challenge,
      completedAt: new Date().toISOString()
    });

    // Remove from active
    this.activeChallenges.splice(challengeIndex, 1);

    // Award rewards
    this.awardReward(challenge.reward);

    // Save
    this.save();

    // Show completion modal
    this.showChallengeComplete(challenge);
  }

  awardReward(reward) {
    // Award points
    this.userPoints += reward.points;
    localStorage.setItem('userPoints', this.userPoints.toString());

    // Award badge
    if (reward.badge && !this.userBadges.includes(reward.badge)) {
      this.userBadges.push(reward.badge);
      localStorage.setItem('userBadges', JSON.stringify(this.userBadges));
    }
  }

  showChallengeComplete(challenge) {
    const modal = document.createElement('div');
    modal.className = 'challenge-complete-modal';
    modal.innerHTML = `
      <div class="modal-content">
        <div class="confetti">🎉</div>
        <h2>Challenge Complete!</h2>
        <h3>${challenge.title}</h3>
        <div class="reward-display">
          <div class="reward-points">+${challenge.reward.points} points</div>
          ${challenge.reward.badge ? `<div class="reward-badge">🏆 ${challenge.reward.badge}</div>` : ''}
        </div>
        <div class="challenge-stats">
          <div class="stat">
            <span class="stat-label">Duration</span>
            <span class="stat-value">${challenge.duration} days</span>
          </div>
          <div class="stat">
            <span class="stat-label">Completed</span>
            <span class="stat-value">${new Date(challenge.completedAt).toLocaleDateString()}</span>
          </div>
        </div>
        <button class="btn-primary" onclick="this.closest('.challenge-complete-modal').remove()">
          Awesome!
        </button>
      </div>
    `;

    document.body.appendChild(modal);

    // Auto-remove after 6 seconds
    setTimeout(() => {
      if (modal.parentNode) {
        modal.remove();
      }
    }, 6000);
  }

  checkExpiredChallenges() {
    const now = new Date();

    this.activeChallenges = this.activeChallenges.filter(challenge => {
      const endDate = new Date(challenge.endDate);
      return endDate > now;
    });

    this.save();
  }

  getAvailableChallenges() {
    // Return challenges that are not active or completed
    return this.availableChallenges.filter(challenge => {
      const isActive = this.activeChallenges.find(c => c.id === challenge.id);
      const isCompleted = this.completedChallenges.find(c => c.id === challenge.id);
      return !isActive && !isCompleted;
    });
  }

  renderActiveChallenges() {
    if (this.activeChallenges.length === 0) {
      return `
        <div class="no-challenges">
          <div class="no-challenges-icon">🎯</div>
          <h3>No Active Challenges</h3>
          <p>Start a challenge to earn rewards and badges!</p>
          <button class="btn-primary" onclick="showChallengeBrowser()">Browse Challenges</button>
        </div>
      `;
    }

    return `
      <div class="active-challenges-grid">
        ${this.activeChallenges.map(challenge => this.renderChallengeCard(challenge)).join('')}
      </div>
    `;
  }

  renderChallengeCard(challenge) {
    const progressPercentage = Math.min(100, Math.round((challenge.progress / challenge.target) * 100));
    const daysLeft = Math.ceil((new Date(challenge.endDate) - new Date()) / (1000 * 60 * 60 * 24));

    return `
      <div class="challenge-card" data-challenge-id="${challenge.id}">
        <div class="challenge-header">
          <div class="challenge-icon">${this.getChallengeIcon(challenge.type)}</div>
          <div class="challenge-info">
            <h4>${challenge.title}</h4>
            <p class="challenge-description">${challenge.description}</p>
          </div>
        </div>
        <div class="challenge-progress">
          <div class="progress-bar">
            <div class="progress-fill" style="width: ${progressPercentage}%"></div>
          </div>
          <div class="progress-label">
            ${challenge.progress} / ${challenge.target} ${challenge.unit}
          </div>
        </div>
        <div class="challenge-footer">
          <div class="challenge-reward">
            <span class="reward-icon">🏆</span>
            <span class="reward-text">${challenge.reward.points} pts</span>
          </div>
          <div class="challenge-days-left">
            ${daysLeft} days left
          </div>
        </div>
      </div>
    `;
  }

  getChallengeIcon(type) {
    const icons = {
      'daily': '📅',
      'streak': '🔥',
      'special': '⭐'
    };
    return icons[type] || '🎯';
  }

  save() {
    localStorage.setItem('activeChallenges', JSON.stringify(this.activeChallenges));
    localStorage.setItem('completedChallenges', JSON.stringify(this.completedChallenges));
    localStorage.setItem('userPoints', this.userPoints.toString());
    localStorage.setItem('userBadges', JSON.stringify(this.userBadges));
  }

  showNotification(title, message) {
    const toast = document.createElement('div');
    toast.className = 'notification-toast challenge-toast';
    toast.innerHTML = `
      <div class="toast-content">
        <div class="toast-icon">🎯</div>
        <div class="toast-message">
          <h4>${title}</h4>
          <p>${message}</p>
        </div>
        <button class="toast-close" onclick="this.closest('.notification-toast').remove()">✕</button>
      </div>
    `;

    document.body.appendChild(toast);

    setTimeout(() => {
      if (toast.parentNode) {
        toast.remove();
      }
    }, 4000);
  }
}

// Global challenge system instance
let challengeSystem;

// Initialize challenge system
document.addEventListener('DOMContentLoaded', () => {
  challengeSystem = new ChallengeSystem();
});

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
  module.exports = ChallengeSystem;
}
