const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required'],
    index: true
  },
  type: {
    type: String,
    required: true,
    enum: ['medicine', 'workout', 'checkup', 'risk_alert', 'diet', 'water', 'system']
  },
  title: {
    type: String,
    required: true,
    trim: true,
    maxlength: [100, 'Title must be less than 100 characters']
  },
  message: {
    type: String,
    required: true,
    trim: true,
    maxlength: [500, 'Message must be less than 500 characters']
  },
  scheduledTime: {
    type: Date,
    required: true,
    index: true
  },
  sent: {
    type: Boolean,
    default: false
  },
  sentAt: {
    type: Date
  },
  read: {
    type: Boolean,
    default: false
  },
  readAt: {
    type: Date
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high', 'urgent'],
    default: 'medium'
  },
  actionRequired: {
    type: Boolean,
    default: false
  },
  actionType: {
    type: String,
    enum: ['none', 'confirm', 'dismiss', 'log_data', 'view_details'],
    default: 'none'
  },
  metadata: {
    type: mongoose.Schema.Types.Mixed
  },
  recurrence: {
    type: String,
    enum: ['none', 'daily', 'weekly', 'monthly'],
    default: 'none'
  },
  recurrenceEndDate: {
    type: Date
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Compound index for efficient queries
notificationSchema.index({ userId: 1, read: 1, createdAt: -1 });
notificationSchema.index({ scheduledTime: 1, sent: 1 });
notificationSchema.index({ userId: 1, scheduledTime: 1, isActive: 1 });

// Static method to get unread notifications
notificationSchema.statics.getUnreadByUserId = function(userId, limit = 20) {
  return this.find({
    userId,
    read: false,
    isActive: true
  })
    .sort({ createdAt: -1 })
    .limit(limit);
};

// Static method to get scheduled notifications
notificationSchema.statics.getScheduledNotifications = function(date = new Date()) {
  return this.find({
    scheduledTime: { $lte: date },
    sent: false,
    isActive: true
  });
};

// Static method to mark as read
notificationSchema.statics.markAsRead = function(notificationId, userId) {
  return this.findOneAndUpdate(
    { _id: notificationId, userId },
    {
      read: true,
      readAt: new Date()
    },
    { new: true }
  );
};

// Static method to mark all as read for user
notificationSchema.statics.markAllAsRead = function(userId) {
  return this.updateMany(
    { userId, read: false },
    {
      read: true,
      readAt: new Date()
    }
  );
};

// Method to mark as sent
notificationSchema.methods.markAsSent = function() {
  this.sent = true;
  this.sentAt = new Date();
  return this.save();
};

// Method to check if notification should recur
notificationSchema.methods.shouldRecur = function() {
  if (this.recurrence === 'none') return false;

  if (this.recurrenceEndDate) {
    return new Date() < this.recurrenceEndDate;
  }

  return true;
};

// Method to create next recurring notification
notificationSchema.methods.createNextOccurrence = function() {
  if (!this.shouldRecur()) return null;

  const nextScheduledTime = new Date(this.scheduledTime);

  switch (this.recurrence) {
    case 'daily':
      nextScheduledTime.setDate(nextScheduledTime.getDate() + 1);
      break;
    case 'weekly':
      nextScheduledTime.setDate(nextScheduledTime.getDate() + 7);
      break;
    case 'monthly':
      nextScheduledTime.setMonth(nextScheduledTime.getMonth() + 1);
      break;
  }

  const nextNotification = new Notification({
    userId: this.userId,
    type: this.type,
    title: this.title,
    message: this.message,
    scheduledTime: nextScheduledTime,
    priority: this.priority,
    actionRequired: this.actionRequired,
    actionType: this.actionType,
    metadata: this.metadata,
    recurrence: this.recurrence,
    recurrenceEndDate: this.recurrenceEndDate
  });

  return nextNotification.save();
};

const Notification = mongoose.model('Notification', notificationSchema);

module.exports = Notification;