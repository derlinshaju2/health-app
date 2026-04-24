import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_theme.dart';
import 'core/widgets/main_navigation.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/health_metrics/presentation/providers/metrics_provider.dart';
import 'features/health_metrics/presentation/screens/metrics_input_screen.dart';
import 'features/health_metrics/presentation/screens/metrics_history_screen.dart';
import 'features/predictions/presentation/providers/prediction_provider.dart';
import 'features/predictions/presentation/screens/prediction_results_screen.dart';
import 'features/diet/presentation/providers/diet_provider.dart';
import 'features/diet/presentation/screens/diet_recommendations_screen.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/yoga/presentation/providers/yoga_provider.dart';
import 'features/yoga/presentation/screens/yoga_session_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HealthApp());
}

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => MetricsProvider()),
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
        ChangeNotifierProvider(create: (_) => DietProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => YogaProvider()),
      ],
      child: MaterialApp(
        title: 'Health Monitor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const MainNavigation(),
          '/metrics/input': (context) => const MetricsInputScreen(),
          '/metrics/history': (context) => const MetricsHistoryScreen(),
          '/predictions': (context) => const PredictionResultsScreen(),
          '/diet': (context) => const DietRecommendationsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/yoga': (context) => const YogaSessionScreen(),
        },
      ),
    );
  }
}