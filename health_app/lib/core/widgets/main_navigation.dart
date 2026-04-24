import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/dashboard/presentation/screens/home_dashboard.dart';
import '../../../features/health_metrics/presentation/screens/metrics_input_screen.dart';
import '../../../features/predictions/presentation/screens/prediction_results_screen.dart';
import '../../../features/diet/presentation/screens/diet_recommendations_screen.dart';
import '../../../features/profile/presentation/screens/profile_screen.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../themes/colors.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;
  late PageController _pageController;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _screens = [
      const HomeDashboard(),
      const MetricsInputScreen(),
      const DietRecommendationsScreen(),
      const PredictionResultsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_outlined),
            activeIcon: Icon(Icons.restaurant),
            label: 'Diet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined),
            activeIcon: Icon(Icons.psychology),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Create a wrapper widget for authenticated screens
class AuthenticatedWrapper extends StatelessWidget {
  final Widget child;

  const AuthenticatedWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      // Redirect to login if not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return child;
  }
}