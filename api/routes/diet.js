const express = require('express');
const router = express.Router();
const dietController = require('../controllers/dietController');
const { authenticate } = require('../middleware/auth');
const { validate, schemas } = require('../middleware/validation');

/**
 * @route   GET /api/diet/recommendations
 * @desc    Get diet recommendations
 * @access  Private
 */
router.get('/recommendations', authenticate, dietController.getRecommendations);

/**
 * @route   POST /api/diet/food-log
 * @desc    Create food log
 * @access  Private
 */
router.post('/food-log', authenticate, validate(schemas.foodLog), dietController.createFoodLog);

/**
 * @route   GET /api/diet/food-log/:date
 * @desc    Get food log for date
 * @access  Private
 */
router.get('/food-log/:date', authenticate, dietController.getFoodLog);

/**
 * @route   GET /api/diet/food-log/history/:period
 * @desc    Get food log history
 * @access  Private
 */
router.get('/food-log/history/:period', authenticate, dietController.getFoodLogHistory);

/**
 * @route   PUT /api/diet/water-intake
 * @desc    Update water intake
 * @access  Private
 */
router.put('/water-intake', authenticate, dietController.updateWaterIntake);

/**
 * @route   GET /api/diet/meal-plan/:date
 * @desc    Get meal plan for date
 * @access  Private
 */
router.get('/meal-plan/:date', authenticate, dietController.getMealPlan);

module.exports = router;