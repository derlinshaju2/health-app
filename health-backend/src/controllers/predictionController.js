const DiseasePrediction = require('../models/DiseasePrediction');
const HealthMetric = require('../models/HealthMetric');
const User = require('../models/User');
const mlServiceClient = require('../config/ml-service');

/**
 * Generate disease predictions using ML service
 * @route POST /api/predictions/generate
 */
const generatePredictions = async (req, res) => {
  try {
    const { metrics, useLatestMetrics } = req.body;

    let inputMetrics = metrics;

    // If useLatestMetrics is true, get the most recent health metrics
    if (useLatestMetrics) {
      const latestMetrics = await HealthMetric.findOne({
        userId: req.userId
      }).sort({ date: -1 });

      if (!latestMetrics) {
        return res.status(404).json({
          status: 'error',
          message: 'No health metrics found. Please provide metrics manually.'
        });
      }

      inputMetrics = latestMetrics.metrics;
    }

    // Get user profile for additional context
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    // Prepare data for ML service
    const mlRequestData = {
      age: user.profile.age || 45,
      gender: user.profile.gender || 'other',
      bmi: user.profile.bmi || user.calculateBMI() || 25,
      blood_pressure_systolic: inputMetrics.bloodPressure?.systolic || 120,
      blood_pressure_diastolic: inputMetrics.bloodPressure?.diastolic || 80,
      blood_sugar: inputMetrics.bloodSugar || 100,
      cholesterol_total: inputMetrics.cholesterol?.total || 200,
      cholesterol_ldl: inputMetrics.cholesterol?.ldl || 100,
      cholesterol_hdl: inputMetrics.cholesterol?.hdl || 50,
      smoking: user.profile.existingConditions?.includes('smoking') ? 1 : 0,
      activity_level: getActivityLevelValue(user.profile.activityLevel),
      family_history_diabetes: user.profile.medicalHistory?.includes('diabetes') ? 1 : 0,
      family_history_hypertension: user.profile.medicalHistory?.includes('hypertension') ? 1 : 0
    };

    // Call ML service
    let mlResponse;
    try {
      const mlServiceResponse = await mlServiceClient.post('/predict', mlRequestData);
      mlResponse = mlServiceResponse.data;
    } catch (mlError) {
      console.error('ML Service Error:', mlError.message);

      // Fallback to rule-based predictions if ML service is unavailable
      mlResponse = generateRuleBasedPredictions(mlRequestData);
    }

    // Transform ML response to database format
    const predictions = mlResponse.predictions.map(pred => ({
      disease: pred.disease,
      riskScore: Math.round(pred.risk_score),
      likelihood: getRiskCategory(pred.risk_score),
      factors: pred.factors || [],
      recommendations: getRecommendationsForDisease(pred.disease, pred.risk_score)
    }));

    // Save predictions to database
    const diseasePrediction = await DiseasePrediction.create({
      userId: req.userId,
      date: new Date(),
      predictions,
      inputMetrics: {
        age: mlRequestData.age,
        bmi: mlRequestData.bmi,
        bloodPressure: {
          systolic: mlRequestData.blood_pressure_systolic,
          diastolic: mlRequestData.blood_pressure_diastolic
        },
        bloodSugar: mlRequestData.blood_sugar,
        cholesterol: {
          total: mlRequestData.cholesterol_total,
          ldl: mlRequestData.cholesterol_ldl,
          hdl: mlRequestData.cholesterol_hdl
        },
        smoking: mlRequestData.smoking === 1,
        activityLevel: user.profile.activityLevel
      },
      modelVersion: mlResponse.model_version || '1.0.0'
    });

    // Check if high risk and potentially send alert
    if (diseasePrediction.isHighRisk) {
      // TODO: Implement notification system for high-risk alerts
      console.log(`High risk detected for user ${req.userId}`);
    }

    res.status(200).json({
      status: 'success',
      message: 'Disease predictions generated successfully',
      data: {
        prediction: diseasePrediction,
        riskSummary: diseasePrediction.getRiskSummary()
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get prediction results for user
 * @route GET /api/predictions/:userId
 */
const getPredictions = async (req, res) => {
  try {
    const { userId } = req.params;

    // Verify user is requesting their own predictions
    if (userId !== req.userId.toString()) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    const predictions = await DiseasePrediction.find({
      userId: req.userId
    })
      .sort({ date: -1 })
      .limit(10)
      .select('-inputMetrics');

    res.status(200).json({
      status: 'success',
      data: { predictions }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get latest prediction
 * @route GET /api/predictions/latest
 */
const getLatestPrediction = async (req, res) => {
  try {
    const prediction = await DiseasePrediction.getLatestByUserId(req.userId);

    if (!prediction) {
      return res.status(404).json({
        status: 'error',
        message: 'No predictions found. Generate a prediction first.'
      });
    }

    res.status(200).json({
      status: 'success',
      data: {
        prediction,
        riskSummary: prediction.getRiskSummary()
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get prediction history
 * @route GET /api/predictions/history/:userId
 */
const getPredictionHistory = async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 10 } = req.query;

    // Verify user is requesting their own history
    if (userId !== req.userId.toString()) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    const history = await DiseasePrediction.getHistoryByUserId(
      req.userId,
      parseInt(limit)
    );

    res.status(200).json({
      status: 'success',
      data: { history }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get risk trends over time
 * @route GET /api/predictions/trends
 */
const getRiskTrends = async (req, res) => {
  try {
    const { period = 'month' } = req.query;

    const now = new Date();
    let startDate;

    switch (period) {
      case 'week':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case 'month':
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        break;
      case 'quarter':
        startDate = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
        break;
      case 'year':
        startDate = new Date(now.getTime() - 365 * 24 * 60 * 60 * 1000);
        break;
      default:
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
    }

    const predictions = await DiseasePrediction.find({
      userId: req.userId,
      date: { $gte: startDate, $lte: now }
    }).sort({ date: 1 });

    // Calculate trends
    const trends = predictions.map(pred => ({
      date: pred.date,
      overallRisk: pred.getRiskSummary().averageRiskScore,
      hypertensionRisk: pred.predictions.find(p => p.disease === 'hypertension')?.riskScore || 0,
      diabetesRisk: pred.predictions.find(p => p.disease === 'diabetes')?.riskScore || 0,
      heartDiseaseRisk: pred.predictions.find(p => p.disease === 'heart_disease')?.riskScore || 0,
      obesityRisk: pred.predictions.find(p => p.disease === 'obesity_related')?.riskScore || 0
    }));

    res.status(200).json({
      status: 'success',
      data: {
        trends,
        period,
        startDate,
        endDate: now
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

// Helper function to convert activity level to numeric value
const getActivityLevelValue = (activityLevel) => {
  const levels = {
    'sedentary': 1,
    'light': 2,
    'moderate': 3,
    'active': 4,
    'very_active': 5
  };
  return levels[activityLevel] || 1;
};

// Helper function to get risk category from score
const getRiskCategory = (score) => {
  if (score < 30) return 'low';
  if (score < 50) return 'medium';
  if (score < 70) return 'high';
  return 'very_high';
};

// Helper function to get recommendations based on disease and risk score
const getRecommendationsForDisease = (disease, riskScore) => {
  const recommendations = {
    hypertension: [
      'Monitor blood pressure regularly',
      'Reduce sodium intake',
      'Exercise regularly (30 min, 5 days/week)',
      'Maintain healthy weight',
      'Limit alcohol consumption',
      'Manage stress through meditation or yoga'
    ],
    diabetes: [
      'Monitor blood sugar levels regularly',
      'Follow a balanced diet with controlled carbohydrates',
      'Exercise regularly to improve insulin sensitivity',
      'Maintain healthy body weight',
      'Stay hydrated',
      'Get regular check-ups'
    ],
    heart_disease: [
      'Maintain healthy cholesterol levels',
      'Exercise regularly (cardio activities)',
      'Follow a heart-healthy diet',
      'Manage stress',
      'Avoid smoking and limit alcohol',
      'Get regular health check-ups'
    ],
    obesity_related: [
      'Create a moderate calorie deficit',
      'Increase physical activity gradually',
      'Focus on nutrient-dense foods',
      'Get adequate sleep',
      'Consider working with a dietitian',
      'Set realistic weight loss goals'
    ]
  };

  // Return top recommendations based on risk score
  const baseRecs = recommendations[disease] || [];
  const priorityCount = riskScore > 70 ? 6 : riskScore > 50 ? 4 : 2;

  return baseRecs.slice(0, priorityCount);
};

// Fallback function for rule-based predictions
const generateRuleBasedPredictions = (input) => {
  const predictions = [];

  // Hypertension risk calculation
  const bpSystolic = input.blood_pressure_systolic;
  const bpDiastolic = input.blood_pressure_diastolic;
  let hypertensionRisk = 25; // Base risk

  if (bpSystolic >= 140 || bpDiastolic >= 90) hypertensionRisk += 30;
  if (bpSystolic >= 120 || bpDiastolic >= 80) hypertensionRisk += 15;
  if (input.age > 50) hypertensionRisk += 10;
  if (input.bmi > 30) hypertensionRisk += 15;
  if (input.smoking === 1) hypertensionRisk += 10;

  predictions.push({
    disease: 'hypertension',
    risk_score: Math.min(100, hypertensionRisk),
    factors: ['Blood Pressure', 'Age', 'BMI', 'Smoking Status']
  });

  // Diabetes risk calculation
  const bloodSugar = input.blood_sugar;
  let diabetesRisk = 20; // Base risk

  if (bloodSugar > 126) diabetesRisk += 35;
  if (bloodSugar > 100) diabetesRisk += 20;
  if (input.bmi > 30) diabetesRisk += 15;
  if (input.family_history_diabetes === 1) diabetesRisk += 15;
  if (input.age > 45) diabetesRisk += 10;

  predictions.push({
    disease: 'diabetes',
    risk_score: Math.min(100, diabetesRisk),
    factors: ['Blood Sugar', 'BMI', 'Family History', 'Age']
  });

  // Heart disease risk calculation
  let heartDiseaseRisk = 15; // Base risk

  if (input.cholesterol_total > 240) heartDiseaseRisk += 25;
  if (input.cholesterol_total > 200) heartDiseaseRisk += 15;
  if (bpSystolic > 140 || bpDiastolic > 90) heartDiseaseRisk += 20;
  if (input.age > 55) heartDiseaseRisk += 15;
  if (input.smoking === 1) heartDiseaseRisk += 20;
  if (input.bmi > 30) heartDiseaseRisk += 10;

  predictions.push({
    disease: 'heart_disease',
    risk_score: Math.min(100, heartDiseaseRisk),
    factors: ['Cholesterol', 'Blood Pressure', 'Age', 'Smoking Status']
  });

  // Obesity-related conditions
  let obesityRisk = input.bmi > 30 ? 60 : input.bmi > 25 ? 40 : 20;
  predictions.push({
    disease: 'obesity_related',
    risk_score: obesityRisk,
    factors: ['BMI', 'Activity Level', 'Weight']
  });

  return {
    predictions,
    model_version: 'rule-based-fallback'
  };
};

module.exports = {
  generatePredictions,
  getPredictions,
  getLatestPrediction,
  getPredictionHistory,
  getRiskTrends
};