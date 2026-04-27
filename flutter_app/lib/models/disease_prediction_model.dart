/// Disease Prediction Model
class DiseasePrediction {
  final String riskLevel; // low, medium, high
  final String riskColor; // green, yellow, red
  final List<String> riskFactors;
  final List<String> recommendations;
  final String explanation;
  final Map<String, double> riskScores;

  DiseasePrediction({
    required this.riskLevel,
    required this.riskColor,
    required this.riskFactors,
    required this.recommendations,
    required this.explanation,
    required this.riskScores,
  });

  factory DiseasePrediction.fromJson(Map<String, dynamic> json) {
    return DiseasePrediction(
      riskLevel: json['riskLevel'] ?? 'unknown',
      riskColor: json['riskColor'] ?? 'gray',
      riskFactors: List<String>.from(json['riskFactors'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      explanation: json['explanation'] ?? '',
      riskScores: Map<String, double>.from(json['riskScores'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'riskLevel': riskLevel,
      'riskColor': riskColor,
      'riskFactors': riskFactors,
      'recommendations': recommendations,
      'explanation': explanation,
      'riskScores': riskScores,
    };
  }

  bool get isLowRisk => riskLevel == 'low';
  bool get isMediumRisk => riskLevel == 'medium';
  bool get isHighRisk => riskLevel == 'high';
}
