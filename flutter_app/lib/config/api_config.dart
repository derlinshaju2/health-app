// API Configuration
class ApiConfig {
  // Base URL - can be configured for different environments
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://health-app-backend-gq11.onrender.com',
  );

  static String get baseUrl => _baseUrl;

  // API Endpoints
  static const String auth = '/api/auth';
  static const String health = '/api/health';
  static const String metrics = '/api/metrics';
  static const String predictions = '/api/predictions';
  static const String diet = '/api/diet';
  static const String yoga = '/api/yoga';
  static const String progress = '/api/progress';

  // Timeout durations - optimized for Render cold starts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}