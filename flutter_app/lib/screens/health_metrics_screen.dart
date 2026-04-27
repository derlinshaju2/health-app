import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/health_metrics_model.dart';

/// Example Health Metrics Screen
/// Demonstrates health metrics API usage
class HealthMetricsScreen extends StatefulWidget {
  const HealthMetricsScreen({super.key});

  @override
  State<HealthMetricsScreen> createState() => _HealthMetricsScreenState();
}

class _HealthMetricsScreenState extends State<HealthMetricsScreen> {
  final _apiService = ApiService();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _bloodSugarController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  HealthMetrics? _latestMetrics;
  List<HealthMetrics> _metricsHistory = [];

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _bloodSugarController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);

    try {
      // Load latest metrics
      final latestResponse = await _apiService.getLatestHealthMetrics();
      if (latestResponse.isSuccess) {
        final data = latestResponse.data?['data'];
        if (data != null) {
          setState(() {
            _latestMetrics = HealthMetrics.fromJson(data);
          });
        }
      }

      // Load metrics history
      final historyResponse = await _apiService.getHealthMetricsHistory(
        limit: 10,
      );
      if (historyResponse.isSuccess) {
        final data = historyResponse.data?['data'] as List?;
        if (data != null) {
          setState(() {
            _metricsHistory = data
                .map((e) => HealthMetrics.fromJson(e))
                .toList();
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading metrics: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addMetrics() async {
    if (_systolicController.text.isEmpty ||
        _diastolicController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter blood pressure values';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.addHealthMetrics(
        bloodPressure: {
          'systolic': int.parse(_systolicController.text),
          'diastolic': int.parse(_diastolicController.text),
        },
        bloodSugar: _bloodSugarController.text.isNotEmpty
            ? int.parse(_bloodSugarController.text)
            : null,
        notes: _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
      );

      if (response.isSuccess) {
        // Clear form and reload
        _systolicController.clear();
        _diastolicController.clear();
        _bloodSugarController.clear();
        _notesController.clear();
        await _loadMetrics();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Health metrics saved!')),
          );
        }
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to save metrics';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Metrics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadMetrics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Latest Metrics Card
                  if (_latestMetrics != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Latest Metrics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_latestMetrics!.bloodPressure != null)
                              Text(
                                'Blood Pressure: ${_latestMetrics!.bloodPressure}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            if (_latestMetrics!.bloodSugar != null)
                              Text(
                                'Blood Sugar: ${_latestMetrics!.bloodSugar} mg/dL',
                                style: const TextStyle(fontSize: 16),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Add Metrics Form
                  const Text(
                    'Add Health Metrics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _systolicController,
                          decoration: const InputDecoration(
                            labelText: 'Systolic (mmHg)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _diastolicController,
                          decoration: const InputDecoration(
                            labelText: 'Diastolic (mmHg)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bloodSugarController,
                    decoration: const InputDecoration(
                      labelText: 'Blood Sugar (mg/dL)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _addMetrics,
                      child: const Text('Save Metrics'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Metrics History
                  const Text(
                    'Recent History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._metricsHistory.map((metrics) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        title: Text(
                          'BP: ${metrics.bloodPressure ?? "N/A"}',
                        ),
                        subtitle: Text(
                          'Sugar: ${metrics.bloodSugar ?? "N/A"} mg/dL',
                        ),
                        trailing: Text(
                          metrics.createdAt != null
                              ? '${metrics.createdAt!.day}/${metrics.createdAt!.month}/${metrics.createdAt!.year}'
                              : '',
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
