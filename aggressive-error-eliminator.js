// AGGRESSIVE ERROR ELIMINATOR - Load this FIRST
// This script completely suppresses all external errors

(function() {
  'use strict';

  console.log('🔥 AGGRESSIVE Error Eliminator Loading...');

  // Completely override console.error to suppress specific errors
  const originalConsoleError = console.error;
  const originalConsoleWarn = console.warn;
  const blockedPatterns = [
    'content-all.js',
    'chrome-extension://',
    'moz-extension://',
    'safari-extension://',
    'extension://',
    'Failed to fetch'
  ];

  // Override console.error
  console.error = function(...args) {
    const errorMessage = args.map(arg => String(arg)).join(' ');
    const shouldBlock = blockedPatterns.some(pattern => errorMessage.includes(pattern));

    if (shouldBlock) {
      // Log in a way that doesn't show up as an error
      console.log('🛡️ SUPPRESSED:', ...args);
      return;
    }

    // Pass through other errors
    originalConsoleError.apply(console, args);
  };

  // Override console.warn similarly
  console.warn = function(...args) {
    const errorMessage = args.map(arg => String(arg)).join(' ');
    const shouldBlock = blockedPatterns.some(pattern => errorMessage.includes(pattern));

    if (shouldBlock) {
      console.log('🛡️ SUPPRESSED:', ...args);
      return;
    }

    originalConsoleWarn.apply(console, args);
  };

  // Aggressive event blocking
  window.addEventListener('error', function(event) {
    const errorSource = event.filename || event.sourceURL || '';
    const errorMessage = event.message || '';

    const shouldBlock = blockedPatterns.some(pattern =>
      errorSource.includes(pattern) || errorMessage.includes(pattern)
    );

    if (shouldBlock) {
      event.preventDefault();
      event.stopPropagation();
      event.stopImmediatePropagation();
      return false;
    }
  }, true); // Capture phase

  // Aggressive promise rejection blocking
  window.addEventListener('unhandledrejection', function(event) {
    const errorMessage = event.reason?.message || '';
    const errorStack = event.reason?.stack || '';
    const errorString = errorMessage + ' ' + errorStack;

    const shouldBlock = blockedPatterns.some(pattern =>
      errorString.includes(pattern)
    );

    if (shouldBlock) {
      event.preventDefault();
      event.stopPropagation();
      event.stopImmediatePropagation();
      return false;
    }
  }, true);

  // Override window.onerror completely
  const originalOnError = window.onerror;
  window.onerror = function(message, source, lineno, colno, error) {
    const errorString = String(message) + ' ' + String(source);

    const shouldBlock = blockedPatterns.some(pattern =>
      errorString.includes(pattern)
    );

    if (shouldBlock) {
      console.log('🛡️ BLOCKED:', message, source);
      return true; // Prevent error from showing
    }

    if (originalOnError) {
      return originalOnError.apply(this, arguments);
    }

    return false;
  };

  // Override window.onunhandledrejection
  const originalOnUnhandledRejection = window.onunhandledrejection;
  window.onunhandledrejection = function(event) {
    const errorMessage = event.reason?.message || '';
    const errorString = String(errorMessage);

    const shouldBlock = blockedPatterns.some(pattern =>
      errorString.includes(pattern)
    );

    if (shouldBlock) {
      console.log('🛡️ BLOCKED rejection:', errorMessage);
      event.preventDefault();
      return true;
    }

    if (originalOnUnhandledRejection) {
      return originalOnUnhandledRejection.apply(this, arguments);
    }

    return false;
  };

  console.log('🔥 AGGRESSIVE Error Eliminator ACTIVE');
  console.log('🎯 Blocking:', blockedPatterns.join(', '));
  console.log('💡 All content-all.js errors should now be suppressed');
})();