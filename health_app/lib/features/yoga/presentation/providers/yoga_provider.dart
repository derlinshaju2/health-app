import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

class YogaProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<dynamic> _yogaPoses = [];
  List<dynamic> _yogaRoutines = [];
  List<dynamic> _yogaSessions = [];
  Map<String, dynamic>? _yogaProgress;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSessionActive = false;
  int _currentSessionDuration = 0;

  // Getters
  List<dynamic> get yogaPoses => _yogaPoses;
  List<dynamic> get yogaRoutines => _yogaRoutines;
  List<dynamic> get yogaSessions => _yogaSessions;
  Map<String, dynamic>? get yogaProgress => _yogaProgress;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isSessionActive => _isSessionActive;
  int get currentSessionDuration => _currentSessionDuration;

  // Fetch yoga poses library
  Future<bool> fetchYogaPoses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConstants.yogaPoses);

      if (response.statusCode == 200) {
        _yogaPoses = response.data['data']['poses'] ?? [];
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load yoga poses';
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

  // Fetch yoga routines
  Future<bool> fetchYogaRoutines() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConstants.yogaRoutines);

      if (response.statusCode == 200) {
        _yogaRoutines = response.data['data']['routines'] ?? [];
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load yoga routines';
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

  // Fetch yoga sessions history
  Future<bool> fetchYogaSessions(String period) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '${ApiConstants.yogaSessions}/$period',
      );

      if (response.statusCode == 200) {
        _yogaSessions = response.data['data']['sessions'] ?? [];
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load sessions';
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

  // Fetch yoga progress
  Future<bool> fetchYogaProgress(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        '${ApiConstants.yogaProgress}/$userId',
      );

      if (response.statusCode == 200) {
        _yogaProgress = response.data['data']['progress'];
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load progress';
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

  // Start yoga session
  Future<bool> startYogaSession(Map<String, dynamic> sessionData) async {
    _isLoading = true;
    _errorMessage = null;
    _isSessionActive = true;
    _currentSessionDuration = 0;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.yogaSession,
        data: sessionData,
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to start session';
        _isSessionActive = false;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isSessionActive = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Complete yoga session
  Future<bool> completeYogaSession(String sessionId, Map<String, dynamic> completionData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.put(
        '${ApiConstants.yogaSession}/$sessionId',
        data: completionData,
      );

      if (response.statusCode == 200) {
        _isSessionActive = false;
        _currentSessionDuration = 0;
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to complete session';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      _isSessionActive = false;
      notifyListeners();
    }
  }

  // Update session duration (local)
  void updateSessionDuration(int seconds) {
    _currentSessionDuration = seconds;
    notifyListeners();
  }

  // Cancel session
  void cancelSession() {
    _isSessionActive = false;
    _currentSessionDuration = 0;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}