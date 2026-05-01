/**
 * Streak Tracker
 * Monitors user activity and maintains engagement streaks
 */
class StreakTracker {
  constructor() {
    this.currentStreak = parseInt(localStorage.getItem('currentStreak')) || 0;
    this.longestStreak = parseInt(localStorage.getItem('longestStreak')) || 0;
    this.lastActiveDate = localStorage.getItem('lastActiveDate');
    this.streakHistory = JSON.parse(localStorage.getItem('streakHistory')) || [];
    this.init();
  }

  init() {
    // Check if streak needs to be updated
    this.checkAndUpdateStreak();
  }

  checkAndUpdateStreak() {
    const today = new Date().toDateString();
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayString = yesterday.toDateString();

    // If this is the first activity ever
    if (!this.lastActiveDate) {
      this.startNewStreak();
      return;
    }

    // If last active was today, don't increment
    if (this.lastActiveDate === today) {
      return;
    }

    // If last active was yesterday, increment streak
    if (this.lastActiveDate === yesterdayString) {
      this.incrementStreak();
    } else {
      // Streak broken - start new one
      this.breakStreak();
    }
  }

  startNewStreak() {
    this.currentStreak = 1;
    this.longestStreak = Math.max(this.longestStreak, this.currentStreak);
    this.lastActiveDate = new Date().toDateString();
    this.save();
    this.recordStreakEvent('started');
  }

  incrementStreak() {
    this.currentStreak++;
    this.longestStreak = Math.max(this.longestStreak, this.currentStreak);
    this.lastActiveDate = new Date().toDateString();
    this.save();
    this.recordStreakEvent('incremented');

    // Show milestone celebrations
    this.checkMilestones();
  }

  breakStreak() {
    // Record the broken streak
    if (this.currentStreak > 0) {
      this.recordStreakEvent('broken', this.currentStreak);
    }

    // Start new streak
    this.currentStreak = 1;
    this.lastActiveDate = new Date().toDateString();
    this.save();
    this.recordStreakEvent('restarted');

    // Show encouragement message
    this.showStreakBrokenMessage();
  }

  checkMilestones() {
    const milestones = [3, 7, 14, 30, 60, 90, 100, 365];

    if (milestones.includes(this.currentStreak)) {
      this.celebrateMilestone(this.currentStreak);
    }
  }

  celebrateMilestone(days) {
    let message = '';
    let badge = '';

    switch(days) {
      case 3:
        message = '🔥 3-day streak! You\'re building momentum!';
        badge = '3-Day Streak';
        break;
      case 7:
        message = '🏆 One-week streak! Amazing dedication!';
        badge = 'Week Warrior';
        break;
      case 14:
        message = '💪 Two-week streak! You\'re unstoppable!';
        badge = 'Two-Week Titan';
        break;
      case 30:
        message = '🌟 One-month streak! You\'re a health champion!';
        badge = 'Monthly Master';
        break;
      case 60:
        message = '🎖️ Two-month streak! Legendary commitment!';
        badge = 'Two-Month Legend';
        break;
      case 90:
        message = '👑 Three-month streak! Health royalty!';
        badge = 'Quarterly King';
        break;
      case 100:
        message = '💎 100-day streak! Diamond dedication!';
        badge = 'Diamond Devotee';
        break;
      case 365:
        message = '🏅 ONE YEAR! You\'ve achieved the impossible!';
        badge = 'Yearly Legend';
        break;
    }

    this.showStreakCelebration(message, badge);

    // Award badge
    if (badge) {
      this.awardBadge(badge);
    }
  }

  showStreakCelebration(message, badge) {
    // Create celebration modal
    const modal = document.createElement('div');
    modal.className = 'streak-celebration-modal';
    modal.innerHTML = `
      <div class="modal-content">
        <div class="confetti">🎉</div>
        <h2>Streak Milestone!</h2>
        <p class="celebration-message">${message}</p>
        ${badge ? `<div class="badge-earned">🏆 ${badge}</div>` : ''}
        <button class="btn-primary" onclick="this.closest('.streak-celebration-modal').remove()">
          Awesome! Let's Keep Going!
        </button>
      </div>
    `;

    document.body.appendChild(modal);

    // Auto-remove after 5 seconds
    setTimeout(() => {
      if (modal.parentNode) {
        modal.remove();
      }
    }, 5000);
  }

  showStreakBrokenMessage() {
    const previousStreak = this.currentStreak - 1;

    if (previousStreak >= 3) {
      this.showNotification(
        'New Day, New Start! 💪',
        `You had a ${previousStreak}-day streak! Let's start a new one!`
      );
    }
  }

  recordStreakEvent(type, value = 0) {
    const event = {
      type: type,
      value: value,
      date: new Date().toISOString()
    };

    this.streakHistory.push(event);

    // Keep only last 100 events
    if (this.streakHistory.length > 100) {
      this.streakHistory = this.streakHistory.slice(-100);
    }

    localStorage.setItem('streakHistory', JSON.stringify(this.streakHistory));
  }

  getStreakInfo() {
    const status = this.currentStreak >= 30 ? 'legendary' :
                   this.currentStreak >= 14 ? 'amazing' :
                   this.currentStreak >= 7 ? 'on-fire' :
                   this.currentStreak >= 3 ? 'building' : 'starting';

    return {
      current: this.currentStreak,
      longest: this.longestStreak,
      status: status,
      lastActiveDate: this.lastActiveDate,
      daysUntilNextMilestone: this.getDaysUntilNextMilestone()
    };
  }

  getDaysUntilNextMilestone() {
    const milestones = [3, 7, 14, 30, 60, 90, 100, 365];

    for (const milestone of milestones) {
      if (this.currentStreak < milestone) {
        return milestone - this.currentStreak;
      }
    }

    return null; // Already achieved all milestones
  }

  getNextMilestone() {
    const milestones = [3, 7, 14, 30, 60, 90, 100, 365];

    for (const milestone of milestones) {
      if (this.currentStreak < milestone) {
        return milestone;
      }
    }

    return null;
  }

  renderStreakDisplay() {
    const streak = this.getStreakInfo();
    const nextMilestone = this.getNextMilestone();

    return `
      <div class="streak-display streak-${streak.status}">
        <div class="streak-icon">🔥</div>
        <div class="streak-count">${streak.current}</div>
        <div class="streak-label">Day Streak!</div>
        ${streak.current >= 7 ? `<div class="streak-badge">🏆 On Fire!</div>` : ''}
        ${nextMilestone ? `
          <div class="streak-next-milestone">
            ${streak.daysUntilNextMilestone} days to ${nextMilestone}-day milestone!
          </div>
        ` : `
          <div class="streak-next-milestone">
            You've achieved all milestones! 🏅
          </div>
        `}
      </div>
    `;
  }

  awardBadge(badgeName) {
    const badges = JSON.parse(localStorage.getItem('userBadges')) || [];

    if (!badges.includes(badgeName)) {
      badges.push(badgeName);
      localStorage.setItem('userBadges', JSON.stringify(badges));

      // Award points
      const points = parseInt(localStorage.getItem('userPoints')) || 0;
      localStorage.setItem('userPoints', (points + 50).toString());
    }
  }

  save() {
    localStorage.setItem('currentStreak', this.currentStreak.toString());
    localStorage.setItem('longestStreak', this.longestStreak.toString());
    localStorage.setItem('lastActiveDate', this.lastActiveDate);
  }

  showNotification(title, message) {
    const toast = document.createElement('div');
    toast.className = 'notification-toast streak-toast';
    toast.innerHTML = `
      <div class="toast-content">
        <div class="toast-icon">🔥</div>
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

// Global streak tracker instance
let streakTracker;

// Initialize streak tracker
document.addEventListener('DOMContentLoaded', () => {
  streakTracker = new StreakTracker();
});

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
  module.exports = StreakTracker;
}
