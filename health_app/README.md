# Health Monitor - AI-Driven Health Tracking App

A comprehensive Flutter mobile application for AI-powered health monitoring with disease prediction, diet recommendations, and fitness tracking.

## Features

- 🔐 **Secure Authentication** - User registration and login with JWT
- 📊 **Health Dashboard** - Overview of health metrics and risks
- 🩺 **Health Metrics Tracking** - Blood pressure, blood sugar, cholesterol, etc.
- 🤖 **AI Disease Prediction** - ML-powered risk assessment
- 🥗 **Diet & Nutrition** - Meal planning and food tracking
- 🧘 **Yoga & Fitness** - Workout tracking and progress analytics
- 📈 **Analytics & Trends** - Health data visualization
- 🔔 **Notifications** - Reminders and alerts

## Getting Started

### Prerequisites

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode
- Backend API running on `http://localhost:5000`

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd health_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure API URL**
```bash
# For local development
flutter run --dart-define=API_BASE_URL=http://localhost:5000

# Or set environment variable
export API_BASE_URL=http://localhost:5000
```

4. **Run the app**
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── api_constants.dart
│   ├── themes/
│   │   ├── app_theme.dart
│   │   └── colors.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   └── api_exception.dart
│   └── utils/
│       └── validators.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── user_model.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       └── screens/
│   │           ├── splash_screen.dart
│   │           ├── login_screen.dart
│   │           └── register_screen.dart
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── dashboard_provider.dart
│   │   │   └── screens/
│   │   │       └── home_dashboard.dart
│   ├── health_metrics/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── metrics_provider.dart
│   │   │   └── screens/
│   │   │       └── metrics_input_screen.dart
│   └── predictions/
│       ├── presentation/
│       │   ├── providers/
│       │   │   └── prediction_provider.dart
│       │   └── screens/
│       │       └── prediction_results_screen.dart
└── services/
    └── navigation_service.dart
```

## Architecture

### Clean Architecture

The app follows Clean Architecture principles with clear separation of concerns:

- **Presentation Layer**: UI components and state management
- **Domain Layer**: Business logic and entities
- **Data Layer**: API clients, models, and repositories

### State Management

Using Provider for state management:
- AuthProvider - Authentication state
- DashboardProvider - Dashboard data
- MetricsProvider - Health metrics
- PredictionProvider - AI predictions

### API Communication

- Dio for HTTP requests
- Flutter Secure Storage for token management
- Automatic request/response interceptors
- Error handling with custom exceptions

## Available Screens

1. **Splash Screen** - App initialization and auth check
2. **Login/Register** - User authentication
3. **Home Dashboard** - Health overview and quick actions
4. **Health Metrics Input** - Add/update health data
5. **Prediction Results** - AI disease risk analysis
6. **Diet Recommendations** - Personalized meal plans
7. **Yoga Tracking** - Workout sessions and progress

## Themes

The app supports both light and dark themes with a health-focused color palette:

- Primary: Green (#4CAF50)
- Secondary: Blue (#2196F3)
- Accent: Orange (#FF9800)
- Risk Levels: Green, Orange, Red

## Development

### Adding New Features

1. Create feature folder in `lib/features/`
2. Add data models, providers, and screens
3. Update routes in `main.dart`
4. Add providers to `MultiProvider`

### API Integration

1. Add endpoint to `api_constants.dart`
2. Create method in appropriate provider
3. Handle loading and error states
4. Update UI to display data

### Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## Build & Release

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Configuration

### Environment Variables

Set API base URL using Dart defines:

```bash
flutter run --dart-define=API_BASE_URL=http://your-api-url.com
```

### API Client Configuration

Edit `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:5000',
);
```

## Dependencies

Key dependencies:
- `provider` - State management
- `dio` - HTTP client
- `flutter_secure_storage` - Secure storage
- `fl_chart` - Charts and graphs
- `shared_preferences` - Local storage

See `pubspec.yaml` for complete list.

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit your changes
4. Push to branch
5. Create Pull Request

## License

MIT License - see LICENSE file for details

## Support

For issues and questions, please open an issue on GitHub.