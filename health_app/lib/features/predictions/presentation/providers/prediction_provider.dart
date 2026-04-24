import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

class PredictionProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  Map<String, dynamic>? _latestPrediction;
  List<dynamic> _predictionHistory = [];
  Map<String, dynamic>? _riskTrends;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  Map<String, dynamic>? get latestPrediction => _latestPrediction;
  List<dynamic> get predictionHistory => _predictionHistory;
  Map<String, dynamic>? get riskTrends => _riskTrends;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Generate predictions
  Future<bool> generatePredictions({bool useLatestMetrics = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.generatePredictions,
        data: {'useLatestMetrics': useLatestMetrics},
      );

      if (response.statusCode == 200) {
        _latestPrediction = response.data['data'];
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to generate predictions';
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

  // Fetch latest prediction
  Future<bool> fetchLatestPrediction() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConstants.latestPrediction);

      if (response.statusCode == 200) {
        _latestPrediction = response.data['data'];
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load prediction';
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

  // Fetch prediction history
  Future<bool> fetchPredictionHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '${ApiConstants.predictions}/user_id', // Replace with actual user ID
      );

      if (response.statusCode == 200) {
        _predictionHistory = response.data['data']['predictions'] ?? [];
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

  // Fetch risk trends
  Future<bool> fetchRiskTrends({String period = 'month'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '${ApiConstants.predictionTrends}?period=$period',
      );

      if (response.statusCode == 200) {
        _riskTrends = response.data['data'];
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load trends';
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

  // Get risk summary
  Map<String, dynamic>? get riskSummary {
    return _latestPrediction?['riskSummary'];
  }

  // Get high risk predictions
  List<dynamic> get highRiskPredictions {
    final predictions = _latestPrediction?['prediction']?['predictions'] ?? [];
    return predictions.where((p) => p['riskScore'] >= 70).toList();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}