const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const { authenticate } = require('../middleware/auth');
const { validate, schemas } = require('../middleware/validation');

/**
 * @route   GET /api/notifications
 * @desc    Get user notifications
 * @access  Private
 */
router.get('/', authenticate, notificationController.getNotifications);

/**
 * @route   GET /api/notifications/stats
 * @desc    Get notification statistics
 * @access  Private
 */
router.get('/stats', authenticate, notificationController.getNotificationStats);

/**
 * @route   POST /api/notifications/schedule
 * @desc    Schedule notification
 * @access  Private
 */
router.post('/schedule', authenticate, validate(schemas.notification), notificationController.scheduleNotification);

/**
 * @route   POST /api/notifications/send
 * @desc    Send notification immediately
 * @access  Private
 */
router.post('/send', authenticate, notificationController.sendNotification);

/**
 * @route   POST /api/notifications/reminder
 * @desc    Create reminder notification
 * @access  Private
 */
router.post('/reminder', authenticate, notificationController.createReminder);

/**
 * @route   PUT /api/notifications/:id/read
 * @desc    Mark notification as read
 * @access  Private
 */
router.put('/:id/read', authenticate, notificationController.markAsRead);

/**
 * @route   PUT /api/notifications/read-all
 * @desc    Mark all notifications as read
 * @access  Private
 */
router.put('/read-all', authenticate, notificationController.markAllAsRead);

/**
 * @route   DELETE /api/notifications/:id
 * @desc    Delete notification
 * @access  Private
 */
router.delete('/:id', authenticate, notificationController.deleteNotification);

// Admin routes for cron jobs
/**
 * @route   GET /api/notifications/scheduled
 * @desc    Get scheduled notifications (for cron job)
 * @access  Private (Admin)
 */
router.get('/scheduled', authenticate, notificationController.getScheduledNotifications);

/**
 * @route   POST /api/notifications/process-scheduled
 * @desc    Process scheduled notifications (for cron job)
 * @access  Private (Admin)
 */
router.post('/process-scheduled', authenticate, notificationController.processScheduledNotifications);

module.exports = router;