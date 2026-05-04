// IMMEDIATE ERROR BLOCKING - Load this FIRST on all pages

(function() {
  'use strict';

  console.log('🛡️ External Error Protection Loading...');

  // Block errors from content-all.js and external sources
  const blockedSources = [
    'content-all.js',
    'chrome-extension://',
    'moz-extension://',
    'safari-extension://',
    'web-extension://',
    'extension://',
    'data:application/javascript',
    'blob:javascript'
  ];

  // Enhanced error handler with capture phase
  window.addEventListener('error', function(event) {
    const errorSource = event.filename || event.sourceURL || event.message || '';

    // Check if error is from blocked source
    const shouldBlock = blockedSources.some(source =>
      errorSource.includes(source) ||
      (event.error && event.error.stack && event.error.stack.includes(source))
    );

    if (shouldBlock) {
      console.warn('🛡️ BLOCKED external error from:', errorSource);
      event.preventDefault();
      event.stopPropagation();
      return false;
    }
  }, true); // Use capture phase

  // Block unhandled promise rejections
  window.addEventListener('unhandledrejection', function(event) {
    const errorMessage = event.reason?.message || '';
    const errorStack = event.reason?.stack || '';
    const errorString = errorMessage + ' ' + errorStack;

    const shouldBlock = blockedSources.some(source =>
      errorString.includes(source)
    );

    if (shouldBlock) {
      console.warn('🛡️ BLOCKED promise rejection from:', errorMessage);
      event.preventDefault();
      return false;
    }

    // Also handle generic fetch errors
    if (errorMessage.includes('Failed to fetch') || errorMessage.includes('NetworkError')) {
      console.warn('⚠️ Network request failed (this is normal):', errorMessage);
      event.preventDefault();
      return false;
    }
  });

  // Override fetch to catch external requests
  const originalFetch = window.fetch;
  window.fetch = function(...args) {
    const url = args[0]?.toString() || '';

    const shouldBlock = blockedSources.some(domain => url.includes(domain));

    if (shouldBlock) {
      console.warn('🛡️ BLOCKED fetch request to:', url);
      return Promise.reject(new Error('External request blocked'));
    }

    return originalFetch.apply(this, args).catch(error => {
      if (error.message.includes('Failed to fetch') || error.message.includes('NetworkError')) {
        console.warn('⚠️ Fetch failed (network issue):', url);
      }
      throw error;
    });
  };

  console.log('✅ External Error Protection ACTIVE');
  console.log('📋 Blocking:', blockedSources.join(', '));
})();