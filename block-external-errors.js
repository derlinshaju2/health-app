// Block external script errors and content-all.js issues

// Global error handler to block external script errors
window.addEventListener('error', function(event) {
  const errorSource = event.filename || event.sourceURL || '';

  // Block errors from known external sources
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

  const shouldBlock = blockedSources.some(source => errorSource.includes(source));

  if (shouldBlock) {
    console.warn('🛡️ Blocked external error from:', errorSource);
    event.preventDefault();
    event.stopPropagation();
    return false;
  }
}, true); // Use capture phase

// Enhanced promise rejection handler
window.addEventListener('unhandledrejection', function(event) {
  const error = event.reason;
  const errorMessage = error?.message || error?.toString() || '';
  const errorSource = error?.stack || '';

  // Block fetch errors from external sources
  const blockedPatterns = [
    'content-all.js',
    'chrome-extension://',
    'moz-extension://',
    'safari-extension://',
    'extension://'
  ];

  const shouldBlock = blockedPatterns.some(pattern =>
    errorMessage.includes(pattern) || errorSource.includes(pattern)
  );

  if (shouldBlock) {
    console.warn('🛡️ Blocked external promise rejection from:', errorMessage);
    event.preventDefault();
    return false;
  }

  // Handle general fetch errors more gracefully
  if (errorMessage.includes('Failed to fetch') || errorMessage.includes('NetworkError')) {
    console.warn('⚠️ Network request failed (this is often normal):', errorMessage);
    event.preventDefault(); // Prevent the error from showing in console
    return false;
  }
});

// Override fetch to catch and block external requests
const originalFetch = window.fetch;
window.fetch = function(...args) {
  const url = args[0]?.toString() || '';

  // Check if request is going to external/blocked sources
  const blockedDomains = [
    'content-all.js',
    'chrome-extension://',
    'moz-extension://',
    'safari-extension://'
  ];

  const shouldBlock = blockedDomains.some(domain => url.includes(domain));

  if (shouldBlock) {
    console.warn('🛡️ Blocked external fetch request to:', url);
    return Promise.reject(new Error('External request blocked'));
  }

  // Call original fetch
  return originalFetch.apply(this, args)
    .catch(error => {
      // Log but don't crash on fetch errors
      if (error.message.includes('Failed to fetch') || error.message.includes('NetworkError')) {
        console.warn('⚠️ Fetch failed (network issue):', url);
        return Promise.reject(error); // Still reject, but we've logged it
      }
      throw error;
    });
};

// Detect and warn about browser extensions that might interfere
function detectInterferingExtensions() {
  const warnings = [];

  // Check for common extension indicators
  if (document.documentElement.getAttribute('data-extension-version')) {
    warnings.push('Extension-modified DOM detected');
  }

  if (window.chrome && window.chrome.runtime && window.chrome.runtime.id) {
    warnings.push('Chrome extension detected');
  }

  // Check for ad blockers
  const adTest = document.createElement('div');
  adTest.className = 'adsbox ad-banner ad-placement';
  adTest.style.display = 'none';
  document.body.appendChild(adTest);

  setTimeout(() => {
    if (adTest.offsetHeight === 0 || getComputedStyle(adTest).display === 'none') {
      warnings.push('Ad blocker detected - might interfere with scripts');
    }
    document.body.removeChild(adTest);
  }, 100);

  if (warnings.length > 0) {
    console.warn('⚠️ Potential extension interference detected:', warnings);
    console.info('💡 Try disabling extensions or using Incognito/Private mode');
  }
}

// Run detection when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', detectInterferingExtensions);
} else {
  detectInterferingExtensions();
}

// Console message to help users understand the blocking
console.log('🛡️ External Error Protection Active');
console.log('ℹ️ Errors from external scripts/extensions are being blocked');
console.log('💡 If you still see errors, try: Incognito mode, disable extensions, or different browser');