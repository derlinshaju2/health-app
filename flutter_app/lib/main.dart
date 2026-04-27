import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/health_metrics_screen.dart';
import 'screens/disease_prediction_screen.dart';
import 'screens/diet_recommendation_screen.dart';
import 'screens/yoga_recommendation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Main App Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

/// Home Screen with Bottom Navigation - Optimized for fast loading
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Widget? _currentScreen;

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
  void initState() {
    super.initState();
    // Only load the first screen initially
    _currentScreen = const HealthMetricsScreen();
  }

  void _loadScreen(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
      // Lazy load screens only when needed
      switch (index) {
        case 0:
          _currentScreen = const HealthMetricsScreen();
          break;
        case 1:
          _currentScreen = const DiseasePredictionScreen();
          break;
        case 2:
          _currentScreen = const DietRecommendationScreen();
          break;
        case 3:
          _currentScreen = const YogaRecommendationScreen();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Fast logout - clear and navigate
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: _currentScreen ?? const HealthMetricsScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _loadScreen,
        destinations: _destinations,
      ),
    );
  }
}
