// Comprehensive Navigation Fix for BMI Calculator
// Add this script to your BMI calculator page to fix the navigation highlighting

(function() {
  'use strict';

  // Wait for DOM to be fully loaded
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', fixNavigation);
  } else {
    fixNavigation();
  }

  function fixNavigation() {
    // Remove active class from ALL navigation links first
    const allNavLinks = document.querySelectorAll('.nav-link');
    allNavLinks.forEach(link => {
      link.classList.remove('active');
    });

    // Add active class ONLY to BMI calculator link
    const bmiLink = document.querySelector('a[href="bmi-calculator.html"]');
    if (bmiLink) {
      bmiLink.classList.add('active');
      console.log('✅ Navigation fixed: BMI calculator is now the only active link');
    }

    // Double-check disease prediction doesn't have active class
    const diseaseLink = document.querySelector('a[href="disease-prediction.html"]');
    if (diseaseLink && diseaseLink.classList.contains('active')) {
      diseaseLink.classList.remove('active');
      console.log('✅ Removed active class from disease prediction link');
    }
  }
})();