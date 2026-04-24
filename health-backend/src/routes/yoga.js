const express = require('express');
const router = express.Router();
const yogaController = require('../controllers/yogaController');
const { authenticate } = require('../middleware/auth');
const { validate, schemas } = require('../middleware/validation');

/**
 * @route   POST /api/yoga/session
 * @desc    Create yoga session
 * @access  Private
 */
router.post('/session', authenticate, validate(schemas.yogaSession), yogaController.createSession);

/**
 * @route   GET /api/yoga/sessions/:period
 * @desc    Get yoga sessions for period
 * @access  Private
 */
router.get('/sessions/:period', authenticate, yogaController.getSessions);

/**
 * @route   GET /api/yoga/poses
 * @desc    Get yoga pose library
 * @access  Private
 */
router.get('/poses', authenticate, yogaController.getPoses);

/**
 * @route   GET /api/yoga/routines
 * @desc    Get yoga routines
 * @access  Private
 */
router.get('/routines', authenticate, yogaController.getRoutines);

/**
 * @route   GET /api/yoga/progress/:userId
 * @desc    Get yoga progress and statistics
 * @access  Private
 */
router.get('/progress/:userId', authenticate, yogaController.getProgress);

/**
 * @route   PUT /api/yoga/session/:id
 * @desc    Update yoga session
 * @access  Private
 */
router.put('/session/:id', authenticate, yogaController.updateSession);

/**
 * @route   DELETE /api/yoga/session/:id
 * @desc    Delete yoga session
 * @access  Private
 */
router.delete('/session/:id', authenticate, yogaController.deleteSession);

module.exports = router;