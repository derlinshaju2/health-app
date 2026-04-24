const express = require('express');
const router = express.Router();
const predictionController = require('../controllers/predictionController');
const { authenticate } = require('../middleware/auth');

/**
 * @route   POST /api/predictions/generate
 * @desc    Generate disease predictions
 * @access  Private
 */
router.post('/generate', authenticate, predictionController.generatePredictions);

/**
 * @route   GET /api/predictions/latest
 * @desc    Get latest prediction
 * @access  Private
 */
router.get('/latest', authenticate, predictionController.getLatestPrediction);

/**
 * @route   GET /api/predictions/trends
 * @desc    Get risk trends over time
 * @access  Private
 */
router.get('/trends', authenticate, predictionController.getRiskTrends);

/**
 * @route   GET /api/predictions/:userId
 * @desc    Get predictions for user
 * @access  Private
 */
router.get('/:userId', authenticate, predictionController.getPredictions);

/**
 * @route   GET /api/predictions/history/:userId
 * @desc    Get prediction history
 * @access  Private
 */
router.get('/history/:userId', authenticate, predictionController.getPredictionHistory);

module.exports = router;