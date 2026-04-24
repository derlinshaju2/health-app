import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

class DietProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  Map<String, dynamic>? _recommendations;
  Map<String, dynamic>? _mealPlan;
  List<dynamic> _foodLog = [];
  List<dynamic> _foodLogHistory = [];
  int _waterIntake = 0;
  Map<String, dynamic>? _dietStats;

  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  Map<String, dynamic>? get recommendations => _recommendations;
  Map<String, dynamic>? get mealPlan => _mealPlan;
  List<dynamic> get foodLog => _foodLog;
  List<dynamic> get foodLogHistory => _foodLogHistory;
  int get waterIntake => _waterIntake;
  Map<String, dynamic>? get dietStats => _dietStats;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Fetch diet recommendations
  Future<bool> fetchRecommendations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConstants.dietRecommendations);

      if (response.statusCode == 200) {
        _recommendations = response.data['data'];
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load recommendations';
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

  // Fetch meal plan for specific date
  Future<bool> fetchMealPlan(String date) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '${ApiConstants.mealPlan}/$date',
      );

      if (response.statusCode == 200) {
        _mealPlan = response.data['data']['mealPlan'];
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load meal plan';
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

  // Fetch food log for specific date
  Future<bool> fetchFoodLog(String date) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '${ApiConstants.foodLog}/$date',
      );

      if (response.statusCode == 200) {
        _foodLog = response.data['data']['foodLog'] ?? [];
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load food log';
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

  // Fetch food log history
  Future<bool> fetchFoodLogHistory(String period) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '${ApiConstants.foodLogHistory}/$period',
      );

      if (response.statusCode == 200) {
        _foodLogHistory = response.data['data']['foodLogs'] ?? [];
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load history';
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

  // Add food log entry
  Future<bool> addFoodLog(Map<String, dynamic> foodData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.foodLog,
        data: foodData,
      );

      if (response.statusCode == 201) {
        // Refresh food log
        await fetchFoodLog(DateTime.now().toIso8601String().split('T')[0]);
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to add food log';
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

  // Update water intake
  Future<bool> updateWaterIntake(int glasses) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.put(
        ApiConstants.waterIntake,
        data: {'glasses': glasses},
      );

      if (response.statusCode == 200) {
        _waterIntake = response.data['data']['waterIntake'] ?? glasses;
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to update water intake';
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

  // Increment water intake (local optimization)
  void incrementWaterIntake() {
    _waterIntake++;
    notifyListeners();
    // Sync with server in background
    updateWaterIntake(_waterIntake);
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}