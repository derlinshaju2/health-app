import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/login_screen.dart';
import 'screens/health_metrics_screen.dart';
import 'screens/disease_prediction_screen.dart';
import 'screens/diet_recommendation_screen.dart';
import 'screens/yoga_recommendation_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Service
  final apiService = ApiService();
  await apiService.initialize();

  runApp(MyApp(apiService: apiService));
}

/// Main App Widget
class MyApp extends StatelessWidget {
  final ApiService apiService;

  const MyApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Monitoring App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/metrics': (context) => const HealthMetricsScreen(),
        '/prediction': (context) => const DiseasePredictionScreen(),
        '/diet': (context) => const DietRecommendationScreen(),
        '/yoga': (context) => const YogaRecommendationScreen(),
      },
    );
  }
}

/// Home Screen with Bottom Navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HealthMetricsScreen(),
    DiseasePredictionScreen(),
    DietRecommendationScreen(),
    YogaRecommendationScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.favorite),
      label: 'Metrics',
    ),
    NavigationDestination(
      icon: Icon(Icons.health_and_safety),
      label: 'Predict',
    ),
    NavigationDestination(
      icon: Icon(Icons.restaurant),
      label: 'Diet',
    ),
    NavigationDestination(
      icon: Icon(Icons.self_improvement),
      label: 'Yoga',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Logout and navigate to login
              final apiService = ApiService();
              await apiService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _destinations,
      ),
    );
  }
}
