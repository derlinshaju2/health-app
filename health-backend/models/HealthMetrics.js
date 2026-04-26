const mongoose = require('mongoose');

const healthMetricsSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    bloodPressure: {
        systolic: { type: Number, required: false },
        diastolic: { type: Number, required: false }
    },
    bloodSugar: {
        type: Number,
        required: false
    },
    cholesterol: {
        ldl: { type: Number, required: false },
        hdl: { type: Number, required: false },
        total: { type: Number, required: false }
    },
    timestamp: {
        type: Date,
        default: Date.now
    },
    notes: {
        type: String,
        default: ''
    }
}, {
    timestamps: true
});

// Index for efficient queries
healthMetricsSchema.index({ userId: 1, timestamp: -1 });

module.exports = mongoose.model('HealthMetrics', healthMetricsSchema);