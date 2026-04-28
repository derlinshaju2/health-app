const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');

// ML Service URL - configure in environment variables
const ML_SERVICE_URL = process.env.ML_SERVICE_URL || 'http://localhost:5001';

// Predict disease risk using ML service
router.post('/predict', authenticate, async (req, res) => {
    try {
        const healthData = req.body;

        // Validate that at least one metric is provided
        if (!healthData || Object.keys(healthData).length === 0) {
            return res.status(400).json({
                status: 'error',
                message: 'Please provide at least one health metric'
            });
        }

        console.log('Calling ML service with data:', healthData);

        // Call ML service
        const fetch = (await import('node-fetch')).default;
        const response = await fetch(`${ML_SERVICE_URL}/predict`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(healthData)
        });

        if (!response.ok) {
            throw new Error(`ML service responded with status ${response.status}`);
        }

        const prediction = await response.json();

        console.log('ML service response:', prediction);

        res.status(200).json({
            status: 'success',
            data: prediction.data
        });

    } catch (error) {
        console.error('Error calling ML service:', error);

        // If ML service is unavailable, provide a basic fallback
        const fallbackPrediction = getBasicPrediction(req.body);

        res.status(200).json({
            status: 'success',
            data: fallbackPrediction,
            warning: 'ML service unavailable, showing basic prediction'
        });
    }
});

// Fallback basic prediction if ML service is unavailable
function getBasicPrediction(healthData) {
    const riskFactors = [];
    let riskScore = 0;

    // Basic blood pressure check
    if (healthData.bloodPressure) {
        const { systolic, diastolic } = healthData.bloodPressure;
        if (systolic >= 140 || diastolic >= 90) {
            riskScore += 3;
            riskFactors.push('High blood pressure');
        }
    }

    // Basic blood sugar check
    if (healthData.bloodSugar !== undefined) {
        if (healthData.bloodSugar >= 126) {
            riskScore += 4;
            riskFactors.push('High blood sugar');
        }
    }

    // Basic BMI check
    if (healthData.bmi) {
        if (healthData.bmi >= 30) {
            riskScore += 3;
            riskFactors.push('Obesity');
        } else if (healthData.bmi >= 25) {
            riskScore += 2;
            riskFactors.push('Overweight');
        }
    }

    let riskLevel, color, recommendation;

    if (riskScore >= 6) {
        riskLevel = 'High';
        color = '#ef4444';
        recommendation = 'Consult a healthcare professional immediately.';
    } else if (riskScore >= 3) {
        riskLevel = 'Medium';
        color = '#f59e0b';
        recommendation = 'Consider lifestyle changes and schedule a check-up.';
    } else {
        riskLevel = 'Low';
        color = '#10b981';
        recommendation = 'Your metrics look good. Continue healthy habits.';
    }

    return {
        riskLevel,
        riskScore,
        riskFactors: riskFactors.length > 0 ? riskFactors : ['No significant risk factors'],
        recommendation,
        color
    };
}

// Test ML service connection
router.get('/test', async (req, res) => {
    try {
        const fetch = (await import('node-fetch')).default;
        const response = await fetch(`${ML_SERVICE_URL}/health`);

        if (response.ok) {
            const data = await response.json();
            res.status(200).json({
                status: 'success',
                message: 'ML service is connected',
                mlService: data
            });
        } else {
            throw new Error('ML service not responding');
        }
    } catch (error) {
        res.status(500).json({
            status: 'error',
            message: 'ML service is not available',
            error: error.message
        });
    }
});

module.exports = router;