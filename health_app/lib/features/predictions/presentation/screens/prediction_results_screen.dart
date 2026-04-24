import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/colors.dart';
import '../providers/prediction_provider.dart';

class PredictionResultsScreen extends StatefulWidget {
  const PredictionResultsScreen({super.key});

  @override
  State<PredictionResultsScreen> createState() => _PredictionResultsScreenState();
}

class _PredictionResultsScreenState extends State<PredictionResultsScreen> {
  @override
  void initState() {
    super.initState();
    _loadPredictions();
  }

  Future<void> _loadPredictions() async {
    final predictionProvider = context.read<PredictionProvider>();
    await predictionProvider.generatePredictions(useLatestMetrics: true);
  }

  Color _getRiskColor(int riskScore) {
    if (riskScore < 30) return AppColors.riskLow;
    if (riskScore < 50) return AppColors.riskMedium;
    if (riskScore < 70) return AppColors.warning;
    return AppColors.riskVeryHigh;
  }

  String _getRiskLabel(int riskScore) {
    if (riskScore < 30) return 'Low Risk';
    if (riskScore < 50) return 'Medium Risk';
    if (riskScore < 70) return 'High Risk';
    return 'Very High Risk';
  }

  IconData _getDiseaseIcon(String disease) {
    switch (disease) {
      case 'hypertension':
        return Icons.favorite;
      case 'diabetes':
        return Icons.bloodtype;
      case 'heart_disease':
        return Icons.monitor_heart;
      case 'obesity_related':
        return Icons.monitor_weight;
      default:
        return Icons.warning;
    }
  }

  String _getDiseaseName(String disease) {
    switch (disease) {
      case 'hypertension':
        return 'Hypertension';
      case 'diabetes':
        return 'Diabetes';
      case 'heart_disease':
        return 'Heart Disease';
      case 'obesity_related':
        return 'Obesity Related';
      default:
        return disease;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Disease Predictions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPredictions,
          ),
        ],
      ),
      body: Consumer<PredictionProvider>(
        builder: (context, predictionProvider, child) {
          if (predictionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final prediction = predictionProvider.latestPrediction?['prediction'];
          final riskSummary = predictionProvider.latestPrediction?['riskSummary'];

          if (prediction == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.psychology_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No predictions available',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate your first AI health prediction',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadPredictions,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate Prediction'),
                  ),
                ],
              ),
            );
          }

          final predictions = prediction['predictions'] as List<dynamic>;

          return RefreshIndicator(
            onRefresh: _loadPredictions,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Risk Summary Card
                if (riskSummary != null)
                  Card(
                    color: AppColors.primary.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Overall Risk Analysis',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getRiskColor(riskSummary['averageRiskScore']?.toInt() ?? 0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getRiskLabel(riskSummary['averageRiskScore']?.toInt() ?? 0),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: (riskSummary['averageRiskScore'] ?? 0) / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getRiskColor(riskSummary['averageRiskScore']?.toInt() ?? 0),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Average Risk Score: ${riskSummary['averageRiskScore']?.toStringAsFixed(1) ?? 0}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Predictions List
                const Text(
                  'Disease Risk Predictions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...predictions.map((pred) => _buildPredictionCard(pred)).toList(),

                const SizedBox(height: 24),

                // Disclaimer
                Card(
                  color: AppColors.warning.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.warning),
                            const SizedBox(width: 8),
                            const Text(
                              'Medical Disclaimer',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'These predictions are for informational purposes only and should not be used as a substitute for professional medical advice, diagnosis, or treatment.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPredictionCard(dynamic prediction) {
    final disease = prediction['disease'] as String;
    final riskScore = prediction['riskScore'] as int;
    final likelihood = prediction['likelihood'] as String;
    final factors = prediction['factors'] as List<dynamic>;
    final recommendations = prediction['recommendations'] as List<dynamic>;

    final riskColor = _getRiskColor(riskScore);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(_getDiseaseIcon(disease), color: riskColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDiseaseName(disease),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        likelihood.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: riskColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: riskColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$riskScore%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Risk Bar
            LinearProgressIndicator(
              value: riskScore / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(riskColor),
            ),
            const SizedBox(height: 16),

            // Contributing Factors
            if (factors.isNotEmpty) ...[
              const Text(
                'Key Factors:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: factors.map<Widget>((factor) {
                  return Chip(
                    label: Text(
                      factor.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: riskColor.withOpacity(0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Recommendations
            if (recommendations.isNotEmpty) ...[
              const Text(
                'Recommendations:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...recommendations.map<Widget>((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            rec.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
