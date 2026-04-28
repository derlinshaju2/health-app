const mongoose = require('mongoose');

const diseasePredictionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required'],
    index: true
  },
  date: {
    type: Date,
    required: [true, 'Date is required'],
    default: Date.now,
    index: true
  },
  predictions: [{
    disease: {
      type: String,
      required: true,
      enum: ['hypertension', 'diabetes', 'heart_disease', 'obesity_related']
    },
    riskScore: {
      type: Number,
      required: true,
      min: [0, 'Risk score must be at least 0'],
      max: [100, 'Risk score must be at most 100']
    },
    likelihood: {
      type: String,
      enum: ['low', 'medium', 'high', 'very_high'],
      required: true
    },
    factors: [{
      type: String,
      trim: true
    }],
    recommendations: [{
      type: String,
      trim: true
    }]
  }],
  inputMetrics: {
    // Store the metrics used for prediction
    age: Number,
    bmi: Number,
    bloodPressure: {
      systolic: Number,
      diastolic: Number
    },
    bloodSugar: Number,
    cholesterol: {
      total: Number,
      ldl: Number,
      hdl: Number
    },
    smoking: Boolean,
    activityLevel: String
  },
  modelVersion: {
    type: String,
    default: '1.0.0'
  },
  isHighRisk: {
    type: Boolean,
    default: false
  },
  alertSent: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// Compound index for efficient queries
diseasePredictionSchema.index({ userId: 1, date: -1 });
diseasePredictionSchema.index({ userId: 1, isHighRisk: 1 });

// Pre-save middleware to check if high risk
diseasePredictionSchema.pre('save', function(next) {
  const hasHighRisk = this.predictions.some(p =>
    p.riskScore >= 70 || p.likelihood === 'high' || p.likelihood === 'very_high'
  );
  this.isHighRisk = hasHighRisk;
  next();
});

// Method to get risk summary
diseasePredictionSchema.methods.getRiskSummary = function() {
  const totalRisk = this.predictions.reduce((sum, p) => sum + p.riskScore, 0);
  const avgRisk = totalRisk / this.predictions.length;

  let overallRisk;
  if (avgRisk < 30) overallRisk = 'low';
  else if (avgRisk < 50) overallRisk = 'medium';
  else if (avgRisk < 70) overallRisk = 'high';
  else overallRisk = 'very_high';

  return {
    overallRisk,
    averageRiskScore: Math.round(avgRisk),
    highRisks: this.predictions.filter(p => p.riskScore >= 70),
    recommendationCount: this.predictions.reduce((sum, p) => sum + p.recommendations.length, 0)
  };
};

// Static method to get latest prediction for user
diseasePredictionSchema.statics.getLatestByUserId = function(userId) {
  return this.findOne({ userId }).sort({ date: -1 });
};

// Static method to get prediction history
diseasePredictionSchema.statics.getHistoryByUserId = function(userId, limit = 10) {
  return this.find({ userId })
    .sort({ date: -1 })
    .limit(limit)
    .select('-inputMetrics');
};

const DiseasePrediction = mongoose.model('DiseasePrediction', diseasePredictionSchema);

module.exports = DiseasePrediction;