/**
 * HealthAI Authentication System
 * Handles user authentication, session management, and page protection
 */

// Auth Configuration
const AUTH_CONFIG = {
  sessionKey: 'healthAIUser',
  usersKey: 'healthAIUsers',
  loginPage: 'login.html',
  dashboardPage: 'index.html',
  sessionTimeout: 24 * 60 * 60 * 1000 // 24 hours
};

/**
 * Check if user is authenticated
 */
function isAuthenticated() {
  try {
    const userSession = localStorage.getItem(AUTH_CONFIG.sessionKey);
    if (!userSession) return false;

    const user = JSON.parse(userSession);

    // Check if session is expired
    if (user.loginTime) {
      const loginTime = new Date(user.loginTime);
      const now = new Date();
      const elapsed = now - loginTime;

      if (elapsed > AUTH_CONFIG.sessionTimeout) {
        logout();
        return false;
      }
    }

    return user.isAuthenticated === true;
  } catch (error) {
    console.error('Auth check error:', error);
    return false;
  }
}

/**
 * Get current user data
 */
function getCurrentUser() {
  try {
    const userSession = localStorage.getItem(AUTH_CONFIG.sessionKey);
    return userSession ? JSON.parse(userSession) : null;
  } catch (error) {
    console.error('Get user error:', error);
    return null;
  }
}

/**
 * Protect page - redirect to login if not authenticated
 */
function protectPage() {
  if (!isAuthenticated()) {
    // Store current page for redirect after login
    sessionStorage.setItem('redirectAfterLogin', window.location.pathname);
    window.location.href = AUTH_CONFIG.loginPage;
    return false;
  }
  return true;
}

/**
 * Login user
 */
function login(email, password, rememberMe = false) {
  return new Promise((resolve, reject) => {
    try {
      // Get users from localStorage
      const users = JSON.parse(localStorage.getItem(AUTH_CONFIG.usersKey) || '[]');

      // Find user
      const user = users.find(u => u.email.toLowerCase() === email.toLowerCase());

      if (!user) {
        reject(new Error('No account found with this email'));
        return;
      }

      // Check password
      if (user.password !== password) {
        reject(new Error('Incorrect password'));
        return;
      }

      // Create session
      const userSession = {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        isAuthenticated: true,
        loginTime: new Date().toISOString(),
        rememberMe: rememberMe
      };

      // Store session
      localStorage.setItem(AUTH_CONFIG.sessionKey, JSON.stringify(userSession));

      // Update last login
      user.lastLogin = new Date().toISOString();
      localStorage.setItem(AUTH_CONFIG.usersKey, JSON.stringify(users));

      resolve(userSession);
    } catch (error) {
      reject(error);
    }
  });
}

/**
 * Logout user
 */
function logout() {
  // Clear session
  localStorage.removeItem(AUTH_CONFIG.sessionKey);

  // Clear any additional session data
  sessionStorage.clear();

  // Redirect to login
  window.location.href = AUTH_CONFIG.loginPage;
}

/**
 * Update user profile
 */
function updateUserProfile(profileData) {
  return new Promise((resolve, reject) => {
    try {
      const currentUser = getCurrentUser();
      if (!currentUser) {
        reject(new Error('No authenticated user found'));
        return;
      }

      // Get all users
      const users = JSON.parse(localStorage.getItem(AUTH_CONFIG.usersKey) || '[]');
      const userIndex = users.findIndex(u => u.id === currentUser.id);

      if (userIndex === -1) {
        reject(new Error('User not found'));
        return;
      }

      // Update user profile
      users[userIndex].profile = {
        ...users[userIndex].profile,
        ...profileData
      };

      // Save updated users
      localStorage.setItem(AUTH_CONFIG.usersKey, JSON.stringify(users));

      // Update current session
      const updatedUser = {
        ...currentUser,
        profile: users[userIndex].profile
      };
      localStorage.setItem(AUTH_CONFIG.sessionKey, JSON.stringify(updatedUser));

      resolve(updatedUser);
    } catch (error) {
      reject(error);
    }
  });
}

/**
 * Display user info in UI
 */
function displayUserInfo() {
  const user = getCurrentUser();
  if (!user) return;

  // Update user name displays
  const userNameElements = document.querySelectorAll('.user-name');
  userNameElements.forEach(element => {
    element.textContent = `${user.firstName} ${user.lastName}`;
  });

  // Update user email displays
  const userEmailElements = document.querySelectorAll('.user-email');
  userEmailElements.forEach(element => {
    element.textContent = user.email;
  });

  // Update user initials
  const userInitialsElements = document.querySelectorAll('.user-initials');
  userInitialsElements.forEach(element => {
    const initials = `${user.firstName[0]}${user.lastName[0]}`.toUpperCase();
    element.textContent = initials;
  });
}

/**
 * Add logout functionality to buttons
 */
function setupLogoutButtons() {
  const logoutButtons = document.querySelectorAll('[data-action="logout"]');
  logoutButtons.forEach(button => {
    button.addEventListener('click', (e) => {
      e.preventDefault();
      if (confirm('Are you sure you want to logout?')) {
        logout();
      }
    });
  });
}

/**
 * Initialize authentication on page load
 */
function initAuth() {
  // Check authentication
  if (!isAuthenticated()) {
    // Redirect to login if not on login/signup pages
    const currentPath = window.location.pathname;
    const isAuthPage = currentPath.includes('login.html') || currentPath.includes('signup.html');

    if (!isAuthPage) {
      sessionStorage.setItem('redirectAfterLogin', currentPath);
      window.location.href = AUTH_CONFIG.loginPage;
    }
    return;
  }

  // Display user info
  displayUserInfo();

  // Setup logout buttons
  setupLogoutButtons();

  // Redirect to dashboard if on login/signup pages
  const currentPath = window.location.pathname;
  const isAuthPage = currentPath.includes('login.html') || currentPath.includes('signup.html');

  if (isAuthPage) {
    window.location.href = AUTH_CONFIG.dashboardPage;
  }
}

/**
 * Create demo account for testing
 */
function createDemoAccount() {
  const demoUsers = [
    {
      id: 'demo_user_001',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      password: 'password123',
      gender: 'male',
      dateOfBirth: '1990-01-15',
      createdAt: new Date().toISOString(),
      lastLogin: null,
      profile: {
        height: 175,
        weight: 72.5,
        activityLevel: 'moderate',
        healthGoals: 'lose-weight'
      }
    }
  ];

  // Check if demo users already exist
  const existingUsers = JSON.parse(localStorage.getItem(AUTH_CONFIG.usersKey) || '[]');
  const demoUserExists = existingUsers.some(u => u.email === 'john.doe@example.com');

  if (!demoUserExists) {
    const updatedUsers = [...existingUsers, ...demoUsers];
    localStorage.setItem(AUTH_CONFIG.usersKey, JSON.stringify(updatedUsers));
    console.log('Demo account created: john.doe@example.com / password123');
  }
}

// Auto-initialize on script load
if (typeof document !== 'undefined') {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAuth);
  } else {
    initAuth();
  }
}

// Export functions for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    isAuthenticated,
    getCurrentUser,
    protectPage,
    login,
    logout,
    updateUserProfile,
    displayUserInfo,
    setupLogoutButtons,
    initAuth,
    createDemoAccount
  };
}