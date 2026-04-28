class ApiConstants {
  // Base URL
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://health-app-backend-gq11.onrender.com',
  );

  // API Endpoints
  static const String apiPrefix = '/api';

  // Auth Endpoints
  static const String register = '$apiPrefix/auth/register';
  static const String login = '$apiPrefix/auth/login';
  static const String logout = '$apiPrefix/auth/logout';
  static const String getProfile = '$apiPrefix/auth/me';
  static const String updateProfile = '$apiPrefix/auth/profile';

  // Health Endpoints
  static const String healthDashboard = '$apiPrefix/health/dashboard';
  static const String healthMetrics = '$apiPrefix/health/metrics';
  static const String latestMetrics = '$apiPrefix/health/metrics/latest';
  static const String metricsByDate = '$apiPrefix/health/metrics';
  static const String metricsHistory = '$apiPrefix/health/metrics/history';

  // Prediction Endpoints
  static const String generatePredictions = '$apiPrefix/predictions/generate';
  static const String latestPrediction = '$apiPrefix/predictions/latest';
  static const String predictions = '$apiPrefix/predictions';
  static const String predictionTrends = '$apiPrefix/predictions/trends';

  // Diet Endpoints
  static const String dietRecommendations = '$apiPrefix/diet/recommendations';
  static const String foodLog = '$apiPrefix/diet/food-log';
  static const String foodLogHistory = '$apiPrefix/diet/food-log/history';
  static const String waterIntake = '$apiPrefix/diet/water-intake';
  static const String mealPlan = '$apiPrefix/diet/meal-plan';

  // Yoga Endpoints
  static const String yogaSession = '$apiPrefix/yoga/session';
  static const String yogaSessions = '$apiPrefix/yoga/sessions';
  static const String yogaPoses = '$apiPrefix/yoga/poses';
  static const String yogaRoutines = '$apiPrefix/yoga/routines';
  static const String yogaProgress = '$apiPrefix/yoga/progress';

  // Notification Endpoints
  static const String notifications = '$apiPrefix/notifications';
  static const String scheduleNotification = '$apiPrefix/notifications/schedule';

  // Timeout durations - reduced for faster failure detection
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}