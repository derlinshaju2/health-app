import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  Map<String, dynamic>? _dashboardData;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  Map<String, dynamic>? get dashboardData => _dashboardData;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Fetch dashboard data
  Future<bool> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConstants.healthDashboard);

      if (response.statusCode == 200) {
        _dashboardData = response.data['data'];
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load dashboard';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh dashboard
  Future<void> refresh() async {
    await fetchDashboard();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get latest metrics
  Map<String, dynamic>? get latestMetrics {
    return _dashboardData?['latestMetrics'];
  }

  // Get recent metrics
  List<dynamic> get recentMetrics {
    return _dashboardData?['recentMetrics'] ?? [];
  }

  // Get trends
  Map<String, dynamic>? get trends {
    return _dashboardData?['trends'];
  }
}