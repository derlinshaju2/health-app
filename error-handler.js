// Global error handler for fetch errors
window.addEventListener('error', function(event) {
  console.error('Global error caught:', event.message, event.filename, event.lineno);
});

window.addEventListener('unhandledrejection', function(event) {
  console.error('Unhandled promise rejection:', event.reason);

  // Check if it's a fetch error
  if (event.reason && event.reason.message && event.reason.message.includes('Failed to fetch')) {
    console.warn('Fetch error detected. This might be due to:');
    console.warn('1. Network connectivity issues');
    console.warn('2. Browser extensions blocking requests');
    console.warn('3. CORS policy violations');
    console.warn('4. Server or API endpoints being down');

    // Optional: Show user-friendly message
    // showNotification('Some features may be unavailable due to network issues');
  }
});

// Enhanced fetch wrapper with error handling
function safeFetch(url, options = {}) {
  return fetch(url, options)
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response;
    })
    .catch(error => {
      console.error('Fetch error:', url, error);
      throw error; // Re-throw for handling by caller
    });
}

// Test if fetch API is working
function testFetchAPI() {
  return fetch('data:,test')
    .then(() => true)
    .catch(() => false);
}

// Log browser info for debugging
function logBrowserInfo() {
  console.log('Browser Info:', {
    userAgent: navigator.userAgent,
    platform: navigator.platform,
    cookieEnabled: navigator.cookieEnabled,
    onLine: navigator.onLine,
    language: navigator.language,
    doNotTrack: navigator.doNotTrack
  });
}

// Initialize on page load
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    logBrowserInfo();
    testFetchAPI().then(works => {
      console.log('Fetch API working:', works);
    });
  });
} else {
  logBrowserInfo();
  testFetchAPI().then(works => {
    console.log('Fetch API working:', works);
  });
}