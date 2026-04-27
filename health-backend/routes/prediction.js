const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const axios = require('axios');

// ML Service URL - configure based on environment
const ML_SERVICE_URL = process.env.ML_SERVICE_URL || 'http://localhost:5001';

// @route   POST /api/predict
// @desc    Get disease risk prediction from ML service
// @access  Private
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { bloodPressure, bloodSugar, bmi, cholesterol } = req.body;

    // Validate that at least one metric is provided
    if (!bloodPressure && !bloodSugar && !bmi && !cholesterol) {
      return res.status(400).json({
        status: 'error',
        message: 'At least one health metric must be provided for prediction'
      });
    }

    // Build request payload for ML service
    const mlRequestData = {};

    if (bloodPressure) {
      mlRequestData.bloodPressure = {
        systolic: bloodPressure.systolic || null,
        diastolic: bloodPressure.diastolic || null
      };
    }

    if (bloodSugar !== undefined) {
      mlRequestData.bloodSugar = bloodSugar;
    }

    if (bmi !== undefined) {
      mlRequestData.bmi = bmi;
    }

    if (cholesterol) {
      mlRequestData.cholesterol = {
        total: cholesterol.total || null,
        ldl: cholesterol.ldl || null,
        hdl: cholesterol.hdl || null
      };
    }

    // Call ML service
    try {
      const mlResponse = await axios.post(`${ML_SERVICE_URL}/predict`, mlRequestData, {
        headers: {
          'Content-Type': 'application/json'
        },
        timeout: 10000 // 10 second timeout
      });

      const mlData = mlResponse.data;

      if (mlData.status === 'success') {
        return res.status(200).json({
          status: 'success',
          message: 'Disease risk prediction completed successfully',
          data: {
            prediction: mlData.data,
            userId: req.user.id,
            timestamp: new Date().toISOString()
          }
        });
      } else {
        throw new Error(mlData.message || 'ML service returned error');
      }

    } catch (mlError) {
      console.error('ML Service Error:', mlError.message);

      // If ML service is unavailable, provide a basic prediction
      const basicPrediction = generateBasicPrediction(mlRequestData);

      return res.status(200).json({
        status: 'success',
        message: 'Disease risk prediction completed (fallback mode)',
        data: {
          prediction: basicPrediction,
          userId: req.user.id,
          timestamp: new Date().toISOString(),
          fallback: true
        }
      });
    }

  } catch (error) {
    console.error('Prediction error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to generate disease risk prediction',
      error: error.message
    });
  }
});

// @route   GET /api/predict/health
// @desc    Check ML service health
// @access  Private
router.get('/health', authenticateToken, async (req, res) => {
  try {
    const mlResponse = await axios.get(`${ML_SERVICE_URL}/health`, {
      timeout: 5000
    });

    res.status(200).json({
      status: 'success',
      message: 'ML prediction service is healthy',
      mlService: mlResponse.data
    });
  } catch (error) {
    res.status(503).json({
      status: 'error',
      message: 'ML prediction service is unavailable',
      error: error.message
    });
  }
});

// Fallback prediction function when ML service is unavailable
function generateBasicPrediction(healthData) {
  let riskScore = 0;
  const riskFactors = [];

  // Blood Pressure Analysis
  if (healthData.bloodPressure) {
    const { systolic, diastolic } = healthData.bloodPressure;

    if (systolic >= 140 || diastolic >= 90) {
      riskScore += 3;
      riskFactors.push("High blood pressure (Hypertension)");
    } else if (systolic >= 120 || diastolic >= 80) {
      riskScore += 2;
      riskFactors.push("Elevated blood pressure");
    } else if (systolic < 90 || diastolic < 60) {
      riskScore += 1;
      riskFactors.push("Low blood pressure");
    }
  }

  // Blood Sugar Analysis
  if (healthData.bloodSugar !== undefined && healthData.bloodSugar !== null) {
    const bloodSugar = healthData.bloodSugar;

    if (bloodSugar >= 126) {
      riskScore += 4;
      riskFactors.push("High blood sugar (Diabetes range)");
    } else if (bloodSugar >= 100) {
      riskScore += 2;
      riskFactors.push("Elevated blood sugar (Pre-diabetes)");
    } else if (bloodSugar < 70) {
      riskScore += 1;
      riskFactors.push("Low blood sugar (Hypoglycemia)");
    }
  }

  // BMI Analysis
  if (healthData.bmi !== undefined && healthData.bmi !== null) {
    const bmi = healthData.bmi;

    if (bmi >= 35) {
      riskScore += 4;
      riskFactors.push(`Obesity Class II (BMI: ${bmi.toFixed(1)})`);
    } else if (bmi >= 30) {
      riskScore += 3;
      riskFactors.push(`Obesity Class I (BMI: ${bmi.toFixed(1)})`);
    } else if (bmi >= 25) {
      riskScore += 2;
      riskFactors.push(`Overweight (BMI: ${bmi.toFixed(1)})`);
    } else if (bmi < 18.5) {
      riskScore += 1;
      riskFactors.push(`Underweight (BMI: ${bmi.toFixed(1)})`);
    }
  }

  // Cholesterol Analysis
  if (healthData.cholesterol) {
    const { total, ldl, hdl } = healthData.cholesterol;

    if (total && total >= 240) {
      riskScore += 3;
      riskFactors.push(`High total cholesterol (${total} mg/dL)`);
    } else if (ldl && ldl >= 160) {
      riskScore += 3;
      riskFactors.push(`High LDL cholesterol (${ldl} mg/dL)`);
    } else if (hdl && hdl < 40) {
      riskScore += 2;
      riskFactors.push(`Low HDL cholesterol (${hdl} mg/dL)`);
    }
  }

  // Determine risk level
  let riskLevel, riskColor, recommendation;

  if (riskScore >= 8) {
    riskLevel = "High";
    riskColor = "#ef4444"; // Red
    recommendation = "Consult a healthcare professional immediately. Your health metrics indicate significant risk factors.";
  } else if (riskScore >= 4) {
    riskLevel = "Medium";
    riskColor = "#f59e0b"; // Yellow/Orange
    recommendation = "Consider lifestyle changes and schedule a check-up with a healthcare provider.";
  } else {
    riskLevel = "Low";
    riskColor = "#10b981"; // Green
    recommendation = "Your health metrics are within normal ranges. Continue maintaining a healthy lifestyle.";
  }

  return {
    riskLevel,
    riskScore,
    riskFactors: riskFactors.length > 0 ? riskFactors : ["No significant risk factors detected"],
    recommendation,
    color: riskColor,
    timestamp: new Date().toISOString()
  };
}

module.exports = router;