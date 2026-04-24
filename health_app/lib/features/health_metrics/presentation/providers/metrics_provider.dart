import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

class MetricsProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<dynamic> _metricsHistory = [];
  Map<String, dynamic>? _latestMetrics;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  List<dynamic> get metricsHistory => _metricsHistory;
  Map<String, dynamic>? get latestMetrics => _latestMetrics;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Fetch latest metrics
  Future<bool> fetchLatestMetrics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConstants.latestMetrics);

      if (response.statusCode == 200) {
        _latestMetrics = response.data['data']['healthMetric'];
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load metrics';
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

  // Fetch metrics history
  Future<bool> fetchMetricsHistory(String period) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '${ApiConstants.metricsHistory}/$period',
      );

      if (response.statusCode == 200) {
        _metricsHistory = response.data['data']['healthMetrics'] ?? [];
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

  // Save health metrics
  Future<bool> saveMetrics(Map<String, dynamic> metricsData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.healthMetrics,
        data: metricsData,
      );

      if (response.statusCode == 200) {
        // Refresh latest metrics
        await fetchLatestMetrics();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to save metrics';
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

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}