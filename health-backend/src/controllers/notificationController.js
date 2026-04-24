const Notification = require('../models/Notification');

/**
 * Get user notifications
 * @route GET /api/notifications
 */
const getNotifications = async (req, res) => {
  try {
    const { limit = 20, unreadOnly = false } = req.query;

    let notifications;

    if (unreadOnly === 'true') {
      notifications = await Notification.getUnreadByUserId(req.userId, parseInt(limit));
    } else {
      notifications = await Notification.find({
        userId: req.userId,
        isActive: true
      })
        .sort({ createdAt: -1 })
        .limit(parseInt(limit));
    }

    res.status(200).json({
      status: 'success',
      data: { notifications }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Schedule notification
 * @route POST /api/notifications/schedule
 */
const scheduleNotification = async (req, res) => {
  try {
    const { type, title, message, scheduledTime, priority, actionRequired, actionType, recurrence, recurrenceEndDate } = req.body;

    const notification = await Notification.create({
      userId: req.userId,
      type,
      title,
      message,
      scheduledTime: new Date(scheduledTime),
      priority: priority || 'medium',
      actionRequired: actionRequired || false,
      actionType: actionType || 'none',
      recurrence: recurrence || 'none',
      recurrenceEndDate: recurrenceEndDate ? new Date(recurrenceEndDate) : null
    });

    res.status(201).json({
      status: 'success',
      message: 'Notification scheduled successfully',
      data: { notification }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Mark notification as read
 * @route PUT /api/notifications/:id/read
 */
const markAsRead = async (req, res) => {
  try {
    const { id } = req.params;

    const notification = await Notification.markAsRead(id, req.userId);

    if (!notification) {
      return res.status(404).json({
        status: 'error',
        message: 'Notification not found'
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Notification marked as read',
      data: { notification }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Mark all notifications as read
 * @route PUT /api/notifications/read-all
 */
const markAllAsRead = async (req, res) => {
  try {
    await Notification.markAllAsRead(req.userId);

    res.status(200).json({
      status: 'success',
      message: 'All notifications marked as read'
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Delete notification
 * @route DELETE /api/notifications/:id
 */
const deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;

    const notification = await Notification.findOneAndDelete({
      _id: id,
      userId: req.userId
    });

    if (!notification) {
      return res.status(404).json({
        status: 'error',
        message: 'Notification not found'
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Notification deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Send notification immediately
 * @route POST /api/notifications/send
 */
const sendNotification = async (req, res) => {
  try {
    const { type, title, message, priority, actionRequired, actionType } = req.body;

    const notification = await Notification.create({
      userId: req.userId,
      type,
      title,
      message,
      scheduledTime: new Date(),
      priority: priority || 'medium',
      actionRequired: actionRequired || false,
      actionType: actionType || 'none',
      sent: true,
      sentAt: new Date()
    });

    // Here you would integrate with a real notification service
    // For now, we'll just mark it as sent

    res.status(201).json({
      status: 'success',
      message: 'Notification sent successfully',
      data: { notification }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get scheduled notifications (for cron job)
 * @route GET /api/notifications/scheduled
 */
const getScheduledNotifications = async (req, res) => {
  try {
    const notifications = await Notification.getScheduledNotifications();

    res.status(200).json({
      status: 'success',
      data: { notifications }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Process scheduled notifications (for cron job)
 * @route POST /api/notifications/process-scheduled
 */
const processScheduledNotifications = async (req, res) => {
  try {
    const notifications = await Notification.getScheduledNotifications();

    const processed = [];

    for (const notification of notifications) {
      // Mark as sent
      await notification.markAsSent();
      processed.push(notification._id);

      // Create next occurrence if it's a recurring notification
      if (notification.shouldRecur()) {
        await notification.createNextOccurrence();
      }
    }

    res.status(200).json({
      status: 'success',
      message: `Processed ${processed.length} notifications`,
      data: { processed }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Create reminder notification
 * @route POST /api/notifications/reminder
 */
const createReminder = async (req, res) => {
  try {
    const { type, time, message } = req.body;

    const reminderTypes = {
      'medicine': {
        title: 'Medicine Reminder',
        defaultTime: '08:00'
      },
      'workout': {
        title: 'Workout Reminder',
        defaultTime: '07:00'
      },
      'checkup': {
        title: 'Health Checkup Reminder',
        defaultTime: '10:00'
      },
      'water': {
        title: 'Water Intake Reminder',
        defaultTime: '09:00'
      }
    };

    const reminderConfig = reminderTypes[type] || reminderTypes['medicine'];

    const notification = await Notification.create({
      userId: req.userId,
      type: type,
      title: reminderConfig.title,
      message: message || `Time to ${type === 'medicine' ? 'take your medicine' : type === 'workout' ? 'exercise' : 'check your health'}`,
      scheduledTime: new Date(time || `${reminderConfig.defaultTime}`),
      priority: 'medium',
      actionRequired: true,
      actionType: 'confirm',
      recurrence: 'daily'
    });

    res.status(201).json({
      status: 'success',
      message: 'Reminder created successfully',
      data: { notification }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get notification statistics
 * @route GET /api/notifications/stats
 */
const getNotificationStats = async (req, res) => {
  try {
    const total = await Notification.countDocuments({ userId: req.userId, isActive: true });
    const unread = await Notification.countDocuments({ userId: req.userId, read: false, isActive: true });
    const sent = await Notification.countDocuments({ userId: req.userId, sent: true, isActive: true });

    // Notifications by type
    const byType = await Notification.aggregate([
      { $match: { userId: req.userId, isActive: true } },
      { $group: { _id: '$type', count: { $sum: 1 } } }
    ]);

    res.status(200).json({
      status: 'success',
      data: {
        stats: {
          total,
          unread,
          read: total - unread,
          sent,
          pending: total - sent,
          byType: byType.reduce((acc, item) => {
            acc[item._id] = item.count;
            return acc;
          }, {})
        }
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

module.exports = {
  getNotifications,
  scheduleNotification,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  sendNotification,
  getScheduledNotifications,
  processScheduledNotifications,
  createReminder,
  getNotificationStats
};