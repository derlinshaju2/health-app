const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { authenticate } = require('../middleware/auth');
const { validate, schemas } = require('../middleware/validation');

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post('/register', validate(schemas.register), authController.register);

/**
 * @route   POST /api/auth/login
 * @desc    Login user
 * @access  Public
 */
router.post('/login', validate(schemas.login), authController.login);

/**
 * @route   POST /api/auth/logout
 * @desc    Logout user
 * @access  Private
 */
router.post('/logout', authenticate, authController.logout);

/**
 * @route   GET /api/auth/me
 * @desc    Get current user profile
 * @access  Private
 */
router.get('/me', authenticate, authController.getProfile);

/**
 * @route   PUT /api/auth/profile
 * @desc    Update user profile
 * @access  Private
 */
router.put('/profile', authenticate, authController.updateProfile);

/**
 * @route   POST /api/auth/profile/picture
 * @desc    Upload profile picture
 * @access  Private
 */
router.post('/profile/picture', authenticate, authController.upload.single('profilePicture'), authController.uploadProfilePicture);

/**
 * @route   DELETE /api/auth/profile/picture
 * @desc    Delete profile picture
 * @access  Private
 */
router.delete('/profile/picture', authenticate, authController.deleteProfilePicture);

// Serve static files from uploads directory
router.use('/uploads', express.static('uploads'));

module.exports = router;