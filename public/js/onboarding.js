/**
 * Onboarding Manager
 * Handles the 5-step progressive onboarding flow for new users
 */
class OnboardingManager {
  constructor() {
    this.currentStep = 1;
    this.userData = {
      age: null,
      gender: null,
      height: null,
      heightUnit: 'cm',
      weight: null,
      weightUnit: 'kg',
      goal: null,
      activityLevel: null
    };
    this.totalSteps = 5;

    this.init();
  }

  init() {
    // Check if user has already completed onboarding
    const userProfile = localStorage.getItem('userProfile');
    if (userProfile) {
      const profile = JSON.parse(userProfile);
      if (profile.onboardingComplete) {
        // Redirect to dashboard if already completed
        window.location.href = 'dashboard.html';
        return;
      }
    }

    // Load saved state if returning
    this.loadState();
    this.renderCurrentStep();
    this.attachEventListeners();
  }

  attachEventListeners() {
    // Gender selection
    document.querySelectorAll('.gender-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('.gender-btn').forEach(b => b.classList.remove('selected'));
        btn.classList.add('selected');
        this.userData.gender = btn.dataset.value;
        document.querySelector('input[name="gender"]').value = btn.dataset.value;
      });
    });

    // Goal selection
    document.querySelectorAll('.goal-card').forEach(card => {
      card.addEventListener('click', () => {
        document.querySelectorAll('.goal-card').forEach(c => c.classList.remove('selected'));
        card.classList.add('selected');
        this.userData.goal = card.dataset.goal;
        document.querySelector('input[name="goal"]').value = card.dataset.goal;
      });
    });

    // Lifestyle/Activity level selection
    document.querySelectorAll('.lifestyle-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('.lifestyle-btn').forEach(b => b.classList.remove('selected'));
        btn.classList.add('selected');
        this.userData.activityLevel = btn.dataset.level;
        document.querySelector('input[name="activityLevel"]').value = btn.dataset.level;
      });
    });
  }

  nextStep() {
    if (this.validateCurrentStep()) {
      this.saveCurrentStepData();

      // If moving to step 5, calculate and show results
      if (this.currentStep === 4) {
        this.calculateResults();
      }

      this.currentStep++;
      this.saveState();
      this.renderCurrentStep();
    }
  }

  prevStep() {
    if (this.currentStep > 1) {
      this.currentStep--;
      this.saveState();
      this.renderCurrentStep();
    }
  }

  validateCurrentStep() {
    const currentScreen = document.querySelector(`.onboarding-screen[data-step="${this.currentStep}"]`);
    let isValid = true;

    // Clear previous errors
    currentScreen.querySelectorAll('.form-group').forEach(group => {
      group.classList.remove('error');
    });

    // Validate based on current step
    switch(this.currentStep) {
      case 2: // Basic info
        const age = currentScreen.querySelector('input[name="age"]');
        const gender = currentScreen.querySelector('input[name="gender"]');

        if (!age.value || age.value < 10 || age.value > 100) {
          age.closest('.form-group').classList.add('error');
          isValid = false;
        }

        if (!gender.value) {
          gender.closest('.form-group').classList.add('error');
          isValid = false;
        }

        break;

      case 3: // Body metrics
        const height = currentScreen.querySelector('input[name="height"]');
        const weight = currentScreen.querySelector('input[name="weight"]');

        if (!height.value || height.value <= 0) {
          height.closest('.form-group').classList.add('error');
          isValid = false;
        }

        if (!weight.value || weight.value <= 0) {
          weight.closest('.form-group').classList.add('error');
          isValid = false;
        }

        break;

      case 4: // Goals
        const goal = currentScreen.querySelector('input[name="goal"]');
        if (!goal.value) {
          goal.closest('.goal-cards').classList.add('error');
          isValid = false;
        }
        break;

      case 5: // Lifestyle
        const activityLevel = currentScreen.querySelector('input[name="activityLevel"]');
        if (!activityLevel.value) {
          activityLevel.closest('.lifestyle-question').classList.add('error');
          isValid = false;
        }
        break;
    }

    return isValid;
  }

  saveCurrentStepData() {
    const currentScreen = document.querySelector(`.onboarding-screen[data-step="${this.currentStep}"]`);

    // Save form data based on current step
    if (this.currentStep === 2) {
      this.userData.age = parseInt(currentScreen.querySelector('input[name="age"]').value);
      this.userData.gender = currentScreen.querySelector('input[name="gender"]').value;
    } else if (this.currentStep === 3) {
      this.userData.height = parseFloat(currentScreen.querySelector('input[name="height"]').value);
      this.userData.heightUnit = currentScreen.querySelector('select[name="height_unit"]').value;
      this.userData.weight = parseFloat(currentScreen.querySelector('input[name="weight"]').value);
      this.userData.weightUnit = currentScreen.querySelector('select[name="weight_unit"]').value;
    }
  }

  calculateResults() {
    // Convert to metric if needed
    let weight = this.userData.weight;
    let height = this.userData.height;

    if (this.userData.weightUnit === 'lbs') {
      weight = weight * 0.453592; // lbs to kg
    }

    if (this.userData.heightUnit === 'ft') {
      height = height * 30.48; // ft to cm
      height = height / 100; // cm to meters
    } else if (this.userData.heightUnit === 'cm') {
      height = height / 100; // cm to meters
    }

    // Calculate BMI
    const bmi = weight / (height * height);
    this.userData.bmi = parseFloat(bmi.toFixed(1));
    this.userData.bmiCategory = this.getBMICategory(bmi);

    // Calculate daily calories
    let baseCalories = 2000;

    // Adjust based on goal
    if (this.userData.goal === 'lose-weight') {
      baseCalories -= 500;
    } else if (this.userData.goal === 'gain-weight') {
      baseCalories += 500;
    }

    // Adjust based on activity level
    const activityMultiplier = {
      'sedentary': 1.0,
      'light': 1.2,
      'moderate': 1.4,
      'active': 1.6
    };

    if (this.userData.activityLevel && activityMultiplier[this.userData.activityLevel]) {
      baseCalories *= activityMultiplier[this.userData.activityLevel];
    }

    this.userData.dailyCalories = Math.round(baseCalories);

    // Calculate protein target (1.6g per kg for active, 1.2g for sedentary)
    const proteinPerKg = this.userData.activityLevel === 'active' ? 1.6 : 1.2;
    this.userData.dailyProtein = Math.round(weight * proteinPerKg);

    // Display results
    this.displayResults();
  }

  getBMICategory(bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal Weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  displayResults() {
    const bmiResultCard = document.querySelector('.bmi-result');
    const caloriesResultCard = document.querySelector('.calories-result');

    if (bmiResultCard) {
      const valueEl = bmiResultCard.querySelector('.result-value');
      const categoryEl = bmiResultCard.querySelector('.result-category');

      valueEl.textContent = this.userData.bmi;
      categoryEl.textContent = this.userData.bmiCategory;

      // Update category styling
      categoryEl.className = 'result-category';
      if (this.userData.bmi < 18.5 || this.userData.bmi >= 25) {
        categoryEl.classList.add('overweight');
      } else {
        categoryEl.classList.add('normal');
      }
    }

    if (caloriesResultCard) {
      const valueEl = caloriesResultCard.querySelector('.result-value');
      valueEl.textContent = this.userData.dailyCalories.toLocaleString();
    }
  }

  renderCurrentStep() {
    // Hide all screens
    document.querySelectorAll('.onboarding-screen').forEach(screen => {
      screen.classList.remove('active');
    });

    // Show current screen
    const currentScreen = document.querySelector(`.onboarding-screen[data-step="${this.currentStep}"]`);
    if (currentScreen) {
      currentScreen.classList.add('active');

      // Update progress bar
      const progressBar = currentScreen.querySelector('.progress-fill');
      if (progressBar) {
        const progress = ((this.currentStep - 1) / (this.totalSteps - 1)) * 100;
        progressBar.style.width = `${progress}%`;
      }

      // Update progress text
      const progressText = currentScreen.querySelector('.progress-text');
      if (progressText) {
        progressText.textContent = `Step ${Math.min(this.currentStep - 1, 4)}/4`;
      }
    }
  }

  completeOnboarding() {
    // Validate final step
    if (!this.validateCurrentStep()) {
      return;
    }

    // Save activity level
    const currentScreen = document.querySelector(`.onboarding-screen[data-step="5"]`);
    this.userData.activityLevel = currentScreen.querySelector('input[name="activityLevel"]').value;

    // Create complete user profile
    const userProfile = {
      ...this.userData,
      completedAt: new Date().toISOString(),
      onboardingComplete: true,
      createdAt: new Date().toISOString()
    };

    // Save to localStorage
    localStorage.setItem('userProfile', JSON.stringify(userProfile));

    // Initialize additional user data
    this.initializeUserData();

    // Redirect to dashboard with onboarding complete flag
    window.location.href = 'dashboard.html?onboarding=complete';
  }

  initializeUserData() {
    // Initialize daily tracking data with realistic starting values
    const today = new Date().toISOString().split('T')[0];
    const todayData = {
      date: today,
      calories: Math.round(this.userData.dailyCalories * 0.3), // Start with 30% of daily goal
      protein: Math.round(this.userData.dailyProtein * 0.25), // Start with 25% of protein goal
      water: 2, // Start with 2 glasses
      steps: 2500, // Start with some steps
      workouts: [],
      meals: []
    };

    localStorage.setItem('todayData', JSON.stringify(todayData));
    localStorage.setItem('userHistory', JSON.stringify([]));

    // Initialize engagement with welcoming starting values
    localStorage.setItem('userPoints', '100'); // Welcome bonus points
    localStorage.setItem('userBadges', JSON.stringify(['🎉 Welcome Aboard'])); // Start with welcome badge
    localStorage.setItem('currentStreak', '1'); // Start with day 1 streak
    localStorage.setItem('longestStreak', '1');
    localStorage.setItem('activeChallenges', JSON.stringify([
      {
        id: 'first-day',
        title: 'Complete Your First Day',
        type: 'daily',
        progress: 30,
        target: 100,
        unit: '%',
        icon: '🌟',
        description: 'Log your first meal and workout'
      }
    ]));
    localStorage.setItem('completedChallenges', JSON.stringify([]));
    localStorage.setItem('recentMeals', JSON.stringify([]));

    // Set default notification preferences
    const notificationPrefs = {
      progressAlerts: true,
      goalReminders: true,
      missedDayWarning: true,
      challengeUpdates: true,
      quietHours: { start: 22, end: 8 }
    };
    localStorage.setItem('notificationPreferences', JSON.stringify(notificationPrefs));
  }

  saveState() {
    const state = {
      currentStep: this.currentStep,
      userData: this.userData
    };
    sessionStorage.setItem('onboardingState', JSON.stringify(state));
  }

  loadState() {
    const savedState = sessionStorage.getItem('onboardingState');
    if (savedState) {
      const state = JSON.parse(savedState);
      this.currentStep = state.currentStep;
      this.userData = { ...this.userData, ...state.userData };
    }
  }
}

// Initialize onboarding when DOM is ready
let onboarding;
document.addEventListener('DOMContentLoaded', () => {
  onboarding = new OnboardingManager();
});
