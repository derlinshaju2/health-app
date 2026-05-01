/**
 * Dashboard Manager
 * Creates dynamic, personalized dashboard experience
 */
class DashboardManager {
  constructor() {
    this.missionGenerator = new MissionGenerator();
    this.userProfile = JSON.parse(localStorage.getItem('userProfile')) || {};
    this.init();
  }

  init() {
    // Check if user just completed onboarding
    const urlParams = new URLSearchParams(window.location.search);
    const justCompletedOnboarding = urlParams.get('onboarding') === 'complete';

    if (justCompletedOnboarding) {
      this.showFirstTimeDashboard();
    } else {
      this.showRegularDashboard();
    }
  }

  showFirstTimeDashboard() {
    const mainContent = document.querySelector('.main-content');
    if (!mainContent) return;

    const dashboardHTML = `
      <div class="first-time-dashboard">
        <div class="welcome-hero">
          <div class="confetti-animation">🎉</div>
          <h1>Welcome to Your Health Journey!</h1>
          <p>You're all set up! Let's start with your first steps</p>
        </div>

        <div class="today-plan-card">
          <h2>📋 Today's Plan</h2>
          <div class="action-items">
            <button class="action-btn primary" onclick="startFirstWorkout()">
              <span class="btn-icon">🏃</span>
              <span>Start Your First Workout</span>
            </button>
            <button class="action-btn" onclick="logFirstMeal()">
              <span class="btn-icon">🍽️</span>
              <span>Log Your First Meal</span>
            </button>
            <button class="action-btn" onclick="viewProfile()">
              <span class="btn-icon">👤</span>
              <span>View Your Profile</span>
            </button>
          </div>
        </div>

        <div class="guided-tooltip" data-target=".log-meal-btn">
          <span class="tooltip-icon">💡</span>
          <p>Tap here to log your meals and track nutrition</p>
          <button class="tooltip-next" onclick="dismissTooltip(this)">Got it!</button>
        </div>

        <div class="first-time-stats">
          <div class="stat-card highlight">
            <div class="stat-icon">🎯</div>
            <div class="stat-value">${this.userProfile.dailyCalories || 2000}</div>
            <div class="stat-label">Daily Calories</div>
          </div>
          <div class="stat-card highlight">
            <div class="stat-icon">⚖️</div>
            <div class="stat-value">${this.userProfile.bmi || '--'}</div>
            <div class="stat-label">Your BMI</div>
          </div>
          <div class="stat-card highlight">
            <div class="stat-icon">💪</div>
            <div class="stat-value">${this.userProfile.dailyProtein || 50}g</div>
            <div class="stat-label">Protein Goal</div>
          </div>
        </div>
      </div>
    `;

    mainContent.innerHTML = dashboardHTML;
    this.addFirstTimeStyles();
  }

  showRegularDashboard() {
    this.renderMissionHeader();
    this.renderPriorityCards();
    this.renderBehavioralInsights();
    this.updateTimeBasedUI();
  }

  renderMissionHeader() {
    const missionProgress = this.missionGenerator.getMissionProgress();
    const missionHeader = document.querySelector('.mission-header');

    if (!missionHeader) {
      // Create mission header if it doesn't exist
      const mainContent = document.querySelector('.main-content');
      const heroSection = mainContent.querySelector('.welcome-section');

      if (heroSection) {
        const missionHeaderHTML = `
          <div class="mission-header">
            <div class="mission-icon">🎯</div>
            <div class="mission-content">
              <h2>Today's Health Mission</h2>
              <p class="mission-subtitle">Complete these goals to level up!</p>
            </div>
            <div class="mission-progress">
              <div class="circular-progress">
                <svg class="progress-ring" width="80" height="80">
                  <circle class="progress-ring-bg" stroke="#e2e8f0" stroke-width="6" fill="transparent" r="34" cx="40" cy="40"/>
                  <circle class="progress-ring-fill" stroke="#6366f1" stroke-width="6" fill="transparent" r="34" cx="40" cy="40"
                    stroke-dasharray="213.6"
                    stroke-dashoffset="${213.6 - (213.6 * missionProgress.percentage / 100)}"
                    transform="rotate(-90 40 40)"/>
                </svg>
                <div class="progress-text">${missionProgress.completed}/${missionProgress.total}</div>
              </div>
            </div>
          </div>
        `;

        heroSection.insertAdjacentHTML('afterend', missionHeaderHTML);
      }
    }
  }

  renderPriorityCards() {
    const missions = this.missionGenerator.generateDailyMissions();
    const statsContainer = document.querySelector('.stats-grid');

    if (!statsContainer) return;

    // Clear existing stats
    statsContainer.innerHTML = '';

    // Render mission cards
    missions.forEach(mission => {
      const card = this.createMissionCard(mission);
      statsContainer.appendChild(card);
    });
  }

  createMissionCard(mission) {
    const card = document.createElement('div');
    card.className = `stat-card priority-${mission.priority}`;
    card.dataset.missionId = mission.id;

    const progressClass = mission.progress >= 100 ? 'success' :
                         mission.progress >= 50 ? 'warning' : '';

    card.innerHTML = `
      <div class="stat-icon">${mission.icon}</div>
      <div class="stat-content">
        <h3>${mission.title}</h3>
        <div class="stat-value">
          ${mission.current} <span class="unit">/${mission.target} ${mission.unit}</span>
        </div>
        <div class="stat-progress">
          <div class="progress-bar">
            <div class="progress-fill ${progressClass}" style="width: ${mission.progress}%"></div>
          </div>
          <span class="progress-label">${Math.round(mission.progress)}% complete</span>
        </div>
      </div>
      <button class="stat-action" onclick="handleMissionAction('${mission.action}', '${mission.id}')">
        ${this.getActionLabel(mission.action)}
      </button>
    `;

    return card;
  }

  getActionLabel(action) {
    const labels = {
      'add-water': '+ Add Glass',
      'start-walk': 'Start Walk',
      'log-meal': '+ Add Meal',
      'start-workout': 'Start Workout',
      'log-protein': '+ Add Protein'
    };
    return labels[action] || 'Update';
  }

  renderBehavioralInsights() {
    const insights = this.missionGenerator.generateBehavioralInsights();
    const mainContent = document.querySelector('.main-content');

    if (!mainContent || insights.length === 0) return;

    // Check if insights section already exists
    let insightsSection = document.querySelector('.behavioral-insights');

    if (!insightsSection) {
      insightsSection = document.createElement('div');
      insightsSection.className = 'behavioral-insights';
      mainContent.appendChild(insightsSection);
    }

    insightsSection.innerHTML = `
      <h3>💡 Personalized Insights</h3>
      <div class="insights-grid">
        ${insights.map(insight => `
          <div class="insight-card priority-${insight.priority}">
            <div class="insight-icon">${insight.icon}</div>
            <div class="insight-content">
              <h4>${insight.title}</h4>
              <p>${insight.message}</p>
              ${insight.action ? `
                <button class="insight-action" onclick="handleInsightAction('${insight.action}')">
                  ${insight.actionLabel}
                </button>
              ` : ''}
            </div>
          </div>
        `).join('')}
      </div>
    `;
  }

  updateTimeBasedUI() {
    const hour = new Date().getHours();
    let timeMessage = '';
    let timeIcon = '';

    if (hour >= 5 && hour < 12) {
      timeMessage = 'Good morning! ☀️';
      timeIcon = '🌅';
    } else if (hour >= 12 && hour < 17) {
      timeMessage = 'Good afternoon! 🌤️';
      timeIcon = '☀️';
    } else if (hour >= 17 && hour < 21) {
      timeMessage = 'Good evening! 🌆';
      timeIcon = '🌆';
    } else {
      timeMessage = 'Good night! 🌙';
      timeIcon = '🌙';
    }

    // Update welcome message
    const welcomeTitle = document.querySelector('.welcome-title h1');
    const welcomeSubtitle = document.querySelector('.welcome-title p');

    if (welcomeTitle) {
      welcomeTitle.textContent = `${timeMessage} Welcome Back!`;
    }

    if (welcomeSubtitle) {
      const userName = this.userProfile.firstName || 'there';
      welcomeSubtitle.textContent = `${userName}, here's your health summary for today`;
    }
  }

  addFirstTimeStyles() {
    // Add styles for first-time dashboard
    const style = document.createElement('style');
    style.textContent = `
      .first-time-dashboard {
        animation: fadeIn 0.5s ease;
      }

      .welcome-hero {
        background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
        border-radius: 24px;
        padding: 40px;
        color: white;
        text-align: center;
        margin-bottom: 30px;
        position: relative;
        overflow: hidden;
      }

      .confetti-animation {
        font-size: 64px;
        margin-bottom: 20px;
        animation: bounce 1s ease infinite;
      }

      @keyframes bounce {
        0%, 100% { transform: translateY(0); }
        50% { transform: translateY(-20px); }
      }

      .welcome-hero h1 {
        font-size: 32px;
        font-weight: 700;
        margin-bottom: 10px;
      }

      .welcome-hero p {
        font-size: 18px;
        opacity: 0.9;
      }

      .today-plan-card {
        background: white;
        border-radius: 20px;
        padding: 30px;
        box-shadow: 0 4px 20px var(--shadow);
        margin-bottom: 30px;
      }

      .today-plan-card h2 {
        font-size: 24px;
        font-weight: 700;
        color: var(--dark);
        margin-bottom: 20px;
      }

      .action-items {
        display: flex;
        flex-direction: column;
        gap: 15px;
      }

      .action-btn {
        display: flex;
        align-items: center;
        gap: 15px;
        padding: 20px;
        background: var(--light);
        border: 2px solid var(--border);
        border-radius: 16px;
        cursor: pointer;
        transition: all 0.3s ease;
        font-size: 16px;
        font-weight: 600;
        color: var(--dark);
        font-family: inherit;
      }

      .action-btn:hover {
        border-color: var(--primary);
        transform: translateY(-2px);
        box-shadow: 0 4px 12px var(--shadow);
      }

      .action-btn.primary {
        background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
        color: white;
        border-color: transparent;
      }

      .btn-icon {
        font-size: 24px;
      }

      .guided-tooltip {
        background: linear-gradient(135deg, rgba(99, 102, 241, 0.1) 0%, rgba(139, 92, 246, 0.1) 100%);
        border: 2px solid var(--primary);
        border-radius: 16px;
        padding: 20px;
        display: flex;
        align-items: center;
        gap: 15px;
        margin-bottom: 30px;
        animation: pulse 2s ease infinite;
      }

      @keyframes pulse {
        0%, 100% { box-shadow: 0 0 0 0 rgba(99, 102, 241, 0.4); }
        50% { box-shadow: 0 0 0 10px rgba(99, 102, 241, 0); }
      }

      .tooltip-icon {
        font-size: 32px;
      }

      .guided-tooltip p {
        flex: 1;
        font-size: 15px;
        color: var(--dark);
        font-weight: 500;
      }

      .tooltip-next {
        padding: 10px 20px;
        background: var(--primary);
        color: white;
        border: none;
        border-radius: 10px;
        cursor: pointer;
        font-weight: 600;
        font-family: inherit;
      }

      .first-time-stats {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 20px;
      }

      .first-time-stats .stat-card {
        background: white;
        border-radius: 16px;
        padding: 25px;
        text-align: center;
        box-shadow: 0 4px 20px var(--shadow);
      }

      .first-time-stats .stat-card.highlight {
        background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
        color: white;
      }

      .first-time-stats .stat-card.highlight .stat-label {
        color: rgba(255, 255, 255, 0.9);
      }

      @media (max-width: 768px) {
        .first-time-stats {
          grid-template-columns: 1fr;
        }

        .welcome-hero h1 {
          font-size: 24px;
        }

        .welcome-hero p {
          font-size: 16px;
        }
      }
    `;

    document.head.appendChild(style);
  }
}

// Global functions for button handlers
function handleMissionAction(action, missionId) {
  switch(action) {
    case 'add-water':
      addWaterGlass();
      break;
    case 'start-walk':
      window.location.href = 'yoga-tracker.html?type=walk';
      break;
    case 'log-meal':
      window.location.href = 'diet-tracking.html';
      break;
    case 'start-workout':
      window.location.href = 'yoga-tracker.html';
      break;
  }
}

function handleInsightAction(action) {
  switch(action) {
    case 'scheduleReminder':
      showNotification('Reminder Set! 🔔', 'We\'ll remind you to stay on track.');
      break;
    case 'viewSuggestions':
      window.location.href = 'diet-tracking.html?suggestions';
      break;
    case 'startYoga':
      window.location.href = 'yoga-tracker.html?type=yoga';
      break;
    case 'setReminder':
      showNotification('Reminder Set! 💧', 'We\'ll remind you to drink water.');
      break;
  }
}

function startFirstWorkout() {
  window.location.href = 'yoga-tracker.html?firstTime=true';
}

function logFirstMeal() {
  window.location.href = 'diet-tracking.html?firstTime=true';
}

function viewProfile() {
  window.location.href = 'profile.html';
}

function dismissTooltip(button) {
  const tooltip = button.closest('.guided-tooltip');
  tooltip.style.animation = 'fadeOut 0.3s ease';
  setTimeout(() => tooltip.remove(), 300);
}

// Initialize dashboard manager when DOM is ready
let dashboardManager;
document.addEventListener('DOMContentLoaded', () => {
  dashboardManager = new DashboardManager();
});

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
  module.exports = DashboardManager;
}
