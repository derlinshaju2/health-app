import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/disease_prediction_model.dart';

/// Example Disease Prediction Screen
/// Demonstrates disease prediction API usage
class DiseasePredictionScreen extends StatefulWidget {
  const DiseasePredictionScreen({super.key});

  @override
  State<DiseasePredictionScreen> createState() => _DiseasePredictionScreenState();
}

class _DiseasePredictionScreenState extends State<DiseasePredictionScreen> {
  final _apiService = ApiService();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _bloodSugarController = TextEditingController();
  final _bmiController = TextEditingController();
  final _totalCholesterolController = TextEditingController();
  final _ldlController = TextEditingController();
  final _hdlController = TextEditingController();

  bool _isLoading = false;
  DiseasePrediction? _prediction;

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _bloodSugarController.dispose();
    _bmiController.dispose();
    _totalCholesterolController.dispose();
    _ldlController.dispose();
    _hdlController.dispose();
    super.dispose();
  }

  Future<void> _getPrediction() async {
    if (_systolicController.text.isEmpty ||
        _diastolicController.text.isEmpty) {
      _showError('Please enter blood pressure values');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getDiseasePrediction(
        bloodPressure: {
          'systolic': int.parse(_systolicController.text),
          'diastolic': int.parse(_diastolicController.text),
        },
        bloodSugar: _bloodSugarController.text.isNotEmpty
            ? int.parse(_bloodSugarController.text)
            : null,
        bmi: _bmiController.text.isNotEmpty
            ? double.parse(_bmiController.text)
            : null,
        cholesterol: _totalCholesterolController.text.isNotEmpty
            ? {
                'total': int.parse(_totalCholesterolController.text),
                'ldl': _ldlController.text.isNotEmpty
                    ? int.parse(_ldlController.text)
                    : null,
                'hdl': _hdlController.text.isNotEmpty
                    ? int.parse(_hdlController.text)
                    : null,
              }
            : null,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _prediction = DiseasePrediction.fromJson(
            response.data?['prediction'] ?? response.data?['data'],
          );
        });
      } else {
        _showError(response.error ?? 'Prediction failed');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getRiskColor() {
    switch (_prediction?.riskColor) {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Risk Prediction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Your Health Metrics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _systolicController,
                            decoration: const InputDecoration(
                              labelText: 'Systolic BP',
                              border: OutlineInputBorder(),
                              hintText: '120',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _diastolicController,
                            decoration: const InputDecoration(
                              labelText: 'Diastolic BP',
                              border: OutlineInputBorder(),
                              hintText: '80',
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
                        hintText: '100',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _bmiController,
                      decoration: const InputDecoration(
                        labelText: 'BMI',
                        border: OutlineInputBorder(),
                        hintText: '22.5',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _totalCholesterolController,
                      decoration: const InputDecoration(
                        labelText: 'Total Cholesterol (mg/dL)',
                        border: OutlineInputBorder(),
                        hintText: '200',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ldlController,
                            decoration: const InputDecoration(
                              labelText: 'LDL (mg/dL)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _hdlController,
                            decoration: const InputDecoration(
                              labelText: 'HDL (mg/dL)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _getPrediction,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Get Risk Prediction'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Prediction Result
            if (_prediction != null) ...[
              const SizedBox(height: 20),
              Card(
                color: _getRiskColor().withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.health_and_safety,
                            color: _getRiskColor(),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Risk Level: ${_prediction!.riskLevel.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _getRiskColor(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _prediction!.explanation,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Risk Factors:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ..._prediction!.riskFactors.map((factor) => Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                            child: Text('• $factor'),
                          )),
                      const SizedBox(height: 12),
                      const Text(
                        'Recommendations:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ..._prediction!.recommendations.map((rec) => Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                            child: Text('• $rec'),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
