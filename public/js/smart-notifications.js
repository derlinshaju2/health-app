/**
 * Smart Notification System
 * Provides contextual notifications based on user behavior and goals
 */
class SmartNotificationSystem {
  constructor() {
    this.notifications = [];
    this.preferences = JSON.parse(localStorage.getItem('notificationPreferences')) || this.getDefaultPreferences();
    this.lastNotifications = JSON.parse(localStorage.getItem('lastNotifications')) || {};
    this.init();
  }

  init() {
    // Request notification permission if not granted
    if ('Notification' in window && Notification.permission === 'default') {
      this.requestNotificationPermission();
    }

    // Check if we should show periodic notifications
    this.startPeriodicChecks();
  }

  getDefaultPreferences() {
    return {
      progressAlerts: true,
      goalReminders: true,
      missedDayWarning: true,
      challengeUpdates: true,
      quietHours: { start: 22, end: 8 }, // 10pm to 8am
      frequency: 'normal' // low, normal, high
    };
  }

  requestNotificationPermission() {
    Notification.requestPermission().then(permission => {
      if (permission === 'granted') {
        this.showInAppNotification('Notifications Enabled! 🔔', 'You\'ll receive helpful health reminders throughout the day.');
      }
    });
  }

  startPeriodicChecks() {
    // Check every 5 minutes for notifications
    setInterval(() => {
      this.checkProgressAndNotify();
    }, 5 * 60 * 1000);

    // Initial check
    setTimeout(() => {
      this.checkProgressAndNotify();
    }, 2000);
  }

  checkProgressAndNotify() {
    if (this.isQuietHours()) {
      return;
    }

    const todayData = this.getTodayData();
    const userProfile = JSON.parse(localStorage.getItem('userProfile')) || {};
    const hour = new Date().getHours();

    // 80% progress alert
    if (this.preferences.progressAlerts) {
      this.checkProgressAlerts(todayData, userProfile, hour);
    }

    // Goal reminders
    if (this.preferences.goalReminders) {
      this.checkGoalReminders(todayData, userProfile, hour);
    }

    // Missed day warning
    if (this.preferences.missedDayWarning) {
      this.checkMissedDayWarning(todayData);
    }
  }

  checkProgressAlerts(todayData, userProfile, hour) {
    const dailyCalories = userProfile.dailyCalories || 2000;
    const currentCalories = todayData.calories || 0;

    // 80% calorie progress
    if (currentCalories >= dailyCalories * 0.8 &&
        currentCalories < dailyCalories * 0.9 &&
        !this.hasNotifiedToday('calories-80')) {
      const remaining = dailyCalories - currentCalories;
      this.sendNotification({
        title: 'Almost There! 💪',
        message: `You're at 80% of your daily calorie goal. Just ${remaining} calories to go!`,
        type: 'progress',
        priority: 'low',
        action: 'log-meal'
      });
      this.markAsNotified('calories-80');
    }

    // 50% calorie progress (afternoon)
    if (hour >= 14 && hour < 17 &&
        currentCalories >= dailyCalories * 0.5 &&
        currentCalories < dailyCalories * 0.6 &&
        !this.hasNotifiedToday('calories-50')) {
      this.sendNotification({
        title: 'Halfway There! 🎯',
        message: `Great progress! You've hit 50% of your calorie goal. Keep it up!`,
        type: 'progress',
        priority: 'low',
        action: null
      });
      this.markAsNotified('calories-50');
    }

    // Water intake reminder
    const waterIntake = todayData.water || 0;
    if (hour >= 14 && waterIntake < 4 && !this.hasNotifiedToday('water-reminder')) {
      this.sendNotification({
        title: 'Hydration Reminder 💧',
        message: `You've only had ${waterIntake} glasses of water today. Stay hydrated!`,
        type: 'reminder',
        priority: 'medium',
        action: 'add-water'
      });
      this.markAsNotified('water-reminder');
    }

    // Protein reminder (evening)
    const dailyProtein = userProfile.dailyProtein || 50;
    const currentProtein = todayData.protein || 0;
    if (hour >= 19 && currentProtein < dailyProtein * 0.8 && !this.hasNotifiedToday('protein-reminder')) {
      this.sendNotification({
        title: 'Protein Boost 🥩',
        message: `You're at ${Math.round((currentProtein / dailyProtein) * 100)}% of your protein goal. Add some protein to dinner!`,
        type: 'reminder',
        priority: 'low',
        action: 'log-meal'
      });
      this.markAsNotified('protein-reminder');
    }
  }

  checkGoalReminders(todayData, userProfile, hour) {
    // Morning workout reminder
    const todayWorkouts = (todayData.workouts || []).length;
    if (hour >= 8 && hour < 10 && todayWorkouts === 0 && !this.hasNotifiedToday('morning-workout')) {
      this.sendNotification({
        title: 'Morning Workout Reminder 🏃',
        message: 'Start your day with energy! A 15-minute workout can boost your mood and productivity.',
        type: 'reminder',
        priority: 'medium',
        action: 'start-workout'
      });
      this.markAsNotified('morning-workout');
    }

    // Lunch reminder
    if (hour >= 12 && hour < 13 && !this.hasNotifiedToday('lunch-reminder')) {
      const mealsLogged = (todayData.meals || []).length;
      if (mealsLogged === 0 || (mealsLogged === 1 && (todayData.meals[0].type === 'breakfast'))) {
        this.sendNotification({
          title: 'Lunch Time! 🍽️',
          message: 'Don\'t forget to log your lunch! Keeping track helps you stay on goal.',
          type: 'reminder',
          priority: 'low',
          action: 'log-meal'
        });
        this.markAsNotified('lunch-reminder');
      }
    }

    // Evening steps reminder
    const steps = todayData.steps || 0;
    if (hour >= 18 && steps < 5000 && !this.hasNotifiedToday('evening-steps')) {
      this.sendNotification({
        title: 'Evening Walk Reminder 👟',
        message: `You're at ${steps} steps today. A short evening walk can help you reach 10,000!`,
        type: 'reminder',
        priority: 'low',
        action: 'start-walk'
      });
      this.markAsNotified('evening-steps');
    }
  }

  checkMissedDayWarning(todayData) {
    const streak = parseInt(localStorage.getItem('currentStreak')) || 0;
    const hour = new Date().getHours();

    // Check if user is at risk of losing streak
    if (streak >= 3 && hour >= 20) {
      const hasActivity = (todayData.workouts || []).length > 0 ||
                       (todayData.meals || []).length >= 2 ||
                       todayData.water >= 4;

      if (!hasActivity && !this.hasNotifiedToday('streak-warning')) {
        this.sendNotification({
          title: 'Keep Your Streak Alive! 🔥',
          message: `You're on a ${streak}-day streak! Log a meal or do a quick workout to keep it going.`,
          type: 'warning',
          priority: 'high',
          action: 'log-meal'
        });
        this.markAsNotified('streak-warning');
      }
    }
  }

  sendNotification(notification) {
    if (!this.shouldSend(notification.type, notification.priority)) {
      return;
    }

    // Browser notification
    if ('Notification' in window && Notification.permission === 'granted') {
      const browserNotification = new Notification(notification.title, {
        body: notification.message,
        icon: '/health-icon.png',
        badge: '/badge-icon.png',
        tag: notification.type,
        requireInteraction: notification.priority === 'high'
      });

      browserNotification.onclick = () => {
        window.focus();
        this.handleNotificationAction(notification.action);
        browserNotification.close();
      };
    }

    // In-app notification
    this.showInAppNotification(notification.title, notification.message, notification.action);

    // Track notification
    this.trackNotification(notification);
  }

  showInAppNotification(title, message, action = null) {
    const toast = document.createElement('div');
    toast.className = 'notification-toast smart-notification';
    toast.innerHTML = `
      <div class="toast-content">
        <div class="toast-icon">${this.getIconForType(action || 'info')}</div>
        <div class="toast-message">
          <h4>${title}</h4>
          <p>${message}</p>
          ${action ? `<button class="toast-action" onclick="handleNotificationAction('${action}')">Take Action</button>` : ''}
        </div>
        <button class="toast-close" onclick="this.closest('.notification-toast').remove()">✕</button>
      </div>
    `;

    document.body.appendChild(toast);

    // Auto-remove after 5 seconds
    setTimeout(() => {
      if (toast.parentNode) {
        toast.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => toast.remove(), 300);
      }
    }, 5000);
  }

  getIconForType(action) {
    const icons = {
      'log-meal': '🍽️',
      'add-water': '💧',
      'start-workout': '🏋️',
      'start-walk': '🚶',
      'progress': '📊',
      'reminder': '🔔',
      'warning': '⚠️',
      'info': 'ℹ️'
    };
    return icons[action] || '🔔';
  }

  shouldSend(type, priority) {
    // Check quiet hours
    if (this.isQuietHours() && priority !== 'high') {
      return false;
    }

    // Check preferences
    switch(type) {
      case 'progress':
        return this.preferences.progressAlerts;
      case 'reminder':
        return this.preferences.goalReminders;
      case 'warning':
        return this.preferences.missedDayWarning;
      default:
        return true;
    }
  }

  isQuietHours() {
    const hour = new Date().getHours();
    const { start, end } = this.preferences.quietHours;

    if (start > end) {
      // Quiet hours cross midnight (e.g., 22:00 to 08:00)
      return hour >= start || hour < end;
    } else {
      // Normal quiet hours (e.g., 01:00 to 06:00)
      return hour >= start && hour < end;
    }
  }

  hasNotifiedToday(notificationId) {
    const today = new Date().toISOString().split('T')[0];
    return this.lastNotifications[today] && this.lastNotifications[today].includes(notificationId);
  }

  markAsNotified(notificationId) {
    const today = new Date().toISOString().split('T')[0];

    if (!this.lastNotifications[today]) {
      this.lastNotifications[today] = [];
    }

    this.lastNotifications[today].push(notificationId);
    localStorage.setItem('lastNotifications', JSON.stringify(this.lastNotifications));
  }

  trackNotification(notification) {
    this.notifications.push({
      ...notification,
      timestamp: new Date().toISOString()
    });

    // Keep only last 100 notifications
    if (this.notifications.length > 100) {
      this.notifications = this.notifications.slice(-100);
    }
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
}

// Global notification system instance
let smartNotificationSystem;

// Initialize notification system
document.addEventListener('DOMContentLoaded', () => {
  smartNotificationSystem = new SmartNotificationSystem();
});

// Global action handler
function handleNotificationAction(action) {
  switch(action) {
    case 'log-meal':
      window.location.href = 'diet-tracking.html';
      break;
    case 'add-water':
      if (typeof addWaterGlass === 'function') {
        addWaterGlass();
      }
      break;
    case 'start-workout':
      window.location.href = 'yoga-tracker.html';
      break;
    case 'start-walk':
      window.location.href = 'yoga-tracker.html?type=walk';
      break;
  }
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
  module.exports = SmartNotificationSystem;
}
