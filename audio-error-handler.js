// Audio Error Handler - Fixes "play() interrupted by pause()" errors

// Safe audio wrapper that handles AbortError
class SafeAudio {
  constructor(audioSrc) {
    this.audio = new Audio(audioSrc);
    this.setupErrorHandling();
  }

  setupErrorHandling() {
    // Handle play interruption errors
    this.audio.addEventListener('play', () => {
      console.log('Audio playing:', this.audio.src);
    });

    this.audio.addEventListener('pause', () => {
      console.log('Audio paused:', this.audio.src);
    });

    this.audio.addEventListener('error', (e) => {
      console.warn('Audio error:', e.target.error);
    });

    // Handle promise rejection for play()
    const originalPlay = this.audio.play;
    this.audio.play = function() {
      return originalPlay.apply(this, arguments).catch(error => {
        if (error.name === 'AbortError') {
          console.warn('Audio play was interrupted (this is normal):', error.message);
          return Promise.resolve(); // Don't break the app
        } else if (error.name === 'NotAllowedError') {
          console.warn('Audio autoplay was blocked by browser:', error.message);
          return Promise.resolve();
        } else {
          console.error('Audio play error:', error);
          throw error;
        }
      });
    };
  }

  play() {
    return this.audio.play();
  }

  pause() {
    this.audio.pause();
  }

  setVolume(volume) {
    this.audio.volume = Math.max(0, Math.min(1, volume));
  }

  isPlaying() {
    return !this.audio.paused;
  }

  stop() {
    this.audio.pause();
    this.audio.currentTime = 0;
  }
}

// Global audio error handler
window.addEventListener('unhandledrejection', function(event) {
  if (event.reason && event.reason.name === 'AbortError') {
    if (event.reason.message && event.reason.message.includes('play()')) {
      console.warn('Audio play interruption detected - this is normal behavior');
      event.preventDefault(); // Prevent the error from showing in console
    }
  }
});

// Fix for notification sounds
function playNotificationSound() {
  try {
    // Create a very short beep sound using Web Audio API instead of HTML5 Audio
    const audioContext = new (window.AudioContext || window.webkitAudioContext)();

    // Create oscillator for beep sound
    const oscillator = audioContext.createOscillator();
    const gainNode = audioContext.createGain();

    oscillator.connect(gainNode);
    gainNode.connect(audioContext.destination);

    oscillator.frequency.value = 800; // 800Hz tone
    oscillator.type = 'sine';

    gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
    gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.1);

    oscillator.start(audioContext.currentTime);
    oscillator.stop(audioContext.currentTime + 0.1);

    return true;
  } catch (error) {
    console.warn('Could not play notification sound:', error);
    return false;
  }
}

// Replace audio elements with safe audio
function makeAudioSafe() {
  const audioElements = document.querySelectorAll('audio');

  audioElements.forEach((audio, index) => {
    console.log(`Making audio element ${index} safe...`);

    // Wrap the play method
    const originalPlay = audio.play;
    audio.play = function() {
      return originalPlay.apply(this, arguments).catch(error => {
        if (error.name === 'AbortError') {
          console.warn(`Audio ${index} play was interrupted - this is normal`);
          return Promise.resolve();
        } else if (error.name === 'NotAllowedError') {
          console.warn(`Audio ${index} autoplay was blocked`);
          return Promise.resolve();
        }
        console.error(`Audio ${index} error:`, error);
        throw error;
      });
    };
  });
}

// Initialize audio safety when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', makeAudioSafe);
} else {
  makeAudioSafe();
}

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
  module.exports = { SafeAudio, playNotificationSound, makeAudioSafe };
}