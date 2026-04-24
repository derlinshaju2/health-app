const express = require('express');
const router = express.Router();
const healthController = require('../controllers/healthController');
const { authenticate } = require('../middleware/auth');
const { validate, schemas } = require('../middleware/validation');

/**
 * @route   GET /api/health/dashboard
 * @desc    Get health dashboard overview
 * @access  Private
 */
router.get('/dashboard', authenticate, healthController.getDashboard);

/**
 * @route   POST /api/health/metrics
 * @desc    Create or update health metrics
 * @access  Private
 */
router.post('/metrics', authenticate, validate(schemas.healthMetrics), healthController.createMetrics);

/**
 * @route   GET /api/health/metrics/latest
 * @desc    Get latest health metrics
 * @access  Private
 */
router.get('/metrics/latest', authenticate, healthController.getLatestMetrics);

/**
 * @route   GET /api/health/metrics/:date
 * @desc    Get health metrics for a specific date
 * @access  Private
 */
router.get('/metrics/:date', authenticate, healthController.getMetricsByDate);

/**
 * @route   GET /api/health/metrics/history/:period
 * @desc    Get health metrics history
 * @access  Private
 */
router.get('/metrics/history/:period', authenticate, healthController.getMetricsHistory);

/**
 * @route   PUT /api/health/metrics/:id
 * @desc    Update health metrics
 * @access  Private
 */
router.put('/metrics/:id', authenticate, healthController.updateMetrics);

/**
 * @route   DELETE /api/health/metrics/:id
 * @desc    Delete health metrics
 * @access  Private
 */
router.delete('/metrics/:id', authenticate, healthController.deleteMetrics);

module.exports = router;