# Flutter Health App - API Integration Layer

Complete Flutter API integration layer for the Health Monitoring Application.

## 📋 Overview

This Flutter module provides a centralized, robust API service for integrating with the health app backend. It includes authentication, health metrics tracking, disease prediction, diet recommendations, yoga routines, and progress tracking.

## 🚀 Setup Instructions

### 1. Install Dependencies

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.4.0
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
```

Run:
```bash
flutter pub get
```

### 2. Configure Environment

Create a `.env` file in your project root:

```bash
# API Configuration
API_BASE_URL=https://your-awesome-project.vercel.app
ENV=production
```

For local development:
```bash
API_BASE_URL=http://localhost:5000
ENV=development
```

### 3. Initialize API Service

In your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Service
  final apiService = ApiService();
  await apiService.initialize();

  runApp(MyApp(apiService: apiService));
}
```

## 📁 Project Structure

```
lib/
├── config/
│   └── api_config.dart          # API endpoints and configuration
├── models/
│   ├── api_response.dart        # Generic API response wrapper
│   ├── user_model.dart          # User data model
│   ├── health_metrics_model.dart    # Health metrics model
│   ├── disease_prediction_model.dart # Disease prediction model
│   ├── diet_model.dart          # Diet recommendation model
│   ├── yoga_model.dart          # Yoga recommendation model
│   └── progress_model.dart      # Progress tracking model
├── services/
│   └── api_service.dart         # Centralized API service
└── screens/
    ├── login_screen.dart        # Login example
    ├── health_metrics_screen.dart       # Health metrics example
    ├── disease_prediction_screen.dart   # Disease prediction example
    ├── diet_recommendation_screen.dart  # Diet recommendation example
    └── yoga_recommendation_screen.dart  # Yoga recommendation example
```

## 🔧 API Service Features

### Authentication
- ✅ JWT token management with secure storage
- ✅ Auto token refresh on 401 errors
- ✅ Persistent login sessions
- ✅ Secure logout

### Error Handling
- ✅ Timeout handling (connection, receive, send)
- ✅ Network error detection
- ✅ HTTP error status code handling
- ✅ User-friendly error messages

### Logging
- ✅ Request/response logging for debugging
- ✅ Error logging
- ✅ Performance tracking

## 📡 API Usage Examples

### Authentication

```dart
final apiService = ApiService();

// Login
final response = await apiService.login(
  email: 'user@example.com',
  password: 'password123',
);

if (response.isSuccess) {
  // Navigate to home
  Navigator.pushReplacementNamed(context, '/home');
}

// Register
final response = await apiService.register(
  email: 'user@example.com',
  password: 'password123',
  name: 'John Doe',
);

// Logout
await apiService.logout();

// Check authentication status
bool isAuthenticated = apiService.isAuthenticated;
```

### Health Metrics

```dart
// Add health metrics
final response = await apiService.addHealthMetrics(
  bloodPressure: {
    'systolic': 120,
    'diastolic': 80,
  },
  bloodSugar: 100,
  cholesterol: {
    'total': 200,
    'ldl': 100,
    'hdl': 50,
  },
  notes: 'Feeling good today',
);

// Get latest metrics
final response = await apiService.getLatestHealthMetrics();

// Get metrics history
final response = await apiService.getHealthMetricsHistory(
  limit: 30,
  startDate: '2026-01-01',
  endDate: '2026-01-31',
);

// Get analytics
final response = await apiService.getHealthMetricsAnalytics(days: 30);
```

### Disease Prediction

```dart
final response = await apiService.getDiseasePrediction(
  bloodPressure: {
    'systolic': 140,
    'diastolic': 90,
  },
  bloodSugar: 120,
  bmi: 28.5,
  cholesterol: {
    'total': 240,
    'ldl': 160,
    'hdl': 40,
  },
);

if (response.isSuccess) {
  final prediction = DiseasePrediction.fromJson(response.data['prediction']);
  print('Risk Level: ${prediction.riskLevel}');
  print('Risk Factors: ${prediction.riskFactors}');
}
```

### Diet Recommendations

```dart
final response = await apiService.getDietRecommendations(
  bmi: 22.5,
  age: 30,
  gender: 'male',
  goal: 'maintenance',
);

if (response.isSuccess) {
  final diet = DietRecommendation.fromJson(response.data['recommendation']);
  print('Daily Calories: ${diet.dailyCalorieTarget}');
  print('Diet Type: ${diet.dietType}');
}

// Get meal plan
final response = await apiService.getMealPlan(
  bmi: 22.5,
  gender: 'male',
  goal: 'weight_loss',
);
```

### Yoga Recommendations

```dart
final response = await apiService.getYogaRecommendations(
  fitnessLevel: 'beginner',
  age: 30,
  goal: 'general',
);

if (response.isSuccess) {
  final yoga = YogaRecommendation.fromJson(response.data['recommendation']);
  print('Duration: ${yoga.routine.totalDurationMinutes} minutes');
  print('Poses: ${yoga.routine.mainPoses.length}');
}

// Get routine
final response = await apiService.getYogaRoutine(
  fitnessLevel: 'intermediate',
  goal: 'flexibility',
);
```

### Progress Tracking

```dart
// Log progress
final response = await apiService.logProgress(
  diet: {
    'caloriesConsumed': 1800,
    'caloriesTarget': 2000,
    'waterIntake': 8,
    'waterTarget': 8,
    'mealsLogged': 3,
    'dietPlanFollowed': true,
  },
  yoga: {
    'durationMinutes': 30,
    'targetMinutes': 30,
    'posesCompleted': 8,
    'difficulty': 'beginner',
  },
  wellness: {
    'energyLevel': 8,
    'mood': 'good',
    'sleepQuality': 7,
    'stressLevel': 4,
  },
);

// Get progress history
final response = await apiService.getProgressHistory(
  limit: 30,
  startDate: '2026-01-01',
  endDate: '2026-01-31',
);

// Get today's progress
final response = await apiService.getTodayProgress();

// Get statistics
final response = await apiService.getProgressStatistics(days: 30);

// Get achievements
final response = await apiService.getAchievements();
```

## 🔒 Security Features

- **JWT Authentication**: Token stored securely using flutter_secure_storage
- **Auto Token Management**: Tokens automatically loaded and refreshed
- **Secure Storage**: Sensitive data encrypted at rest
- **HTTPS Only**: All API calls use secure HTTPS connections
- **Timeout Protection**: Requests timeout after configured duration

## 🛠️ Configuration

### Timeouts

Edit `lib/config/api_config.dart`:

```dart
static const Duration connectTimeout = Duration(seconds: 10);
static const Duration receiveTimeout = Duration(seconds: 15);
static const Duration sendTimeout = Duration(seconds: 15);
```

### Retry Logic

```dart
static const int maxRetries = 3;
static const Duration retryDelay = Duration(seconds: 2);
```

## 📱 Example Screens

All example screens demonstrate:
- Form validation
- Loading states
- Error handling
- Data display
- User interactions

### Login Screen
- Email/password authentication
- Error messages
- Navigation on success

### Health Metrics Screen
- Add new metrics
- View latest metrics
- Browse history
- Real-time updates

### Disease Prediction Screen
- Input health metrics
- Get risk assessment
- Color-coded risk levels
- Recommendations display

### Diet Recommendation Screen
- Profile inputs
- Meal plan generation
- Food guidelines
- Daily tips

### Yoga Recommendation Screen
- Fitness profile
- Routine generation
- Exercise details
- Weekly schedule

## 🧪 Testing

```dart
// Test authentication
test('Login success', () async {
  final response = await apiService.login(
    email: 'test@example.com',
    password: 'password123',
  );
  expect(response.isSuccess, true);
});

// Test health metrics
test('Add health metrics', () async {
  final response = await apiService.addHealthMetrics(
    bloodPressure: {'systolic': 120, 'diastolic': 80},
  );
  expect(response.isSuccess, true);
});
```

## 🐛 Troubleshooting

### Connection Issues
- Check `API_BASE_URL` in `.env` file
- Verify backend is running
- Check internet connection
- Review timeout settings

### Authentication Errors
- Clear stored data: `await apiService.clearToken()`
- Verify credentials
- Check JWT token expiry
- Review backend logs

### Build Issues
- Run `flutter clean`
- Run `flutter pub get`
- Check Flutter version compatibility
- Update dependencies

## 📄 License

This code is part of the Health Monitoring Application project.

## 🤝 Contributing

When making changes:
1. Follow existing code style
2. Add error handling
3. Update documentation
4. Test thoroughly
5. Update models if API changes

## 📞 Support

For issues or questions:
- Check backend API documentation
- Review example screens
- Verify API configuration
- Check error logs

---

**Built with ❤️ for comprehensive health monitoring**
