const mongoose = require('mongoose');

const healthMetricSchema = new mongoose.Schema({
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
  metrics: {
    bloodPressure: {
      systolic: {
        type: Number,
        min: [70, 'Systolic pressure must be at least 70 mmHg'],
        max: [250, 'Systolic pressure must be less than 250 mmHg']
      },
      diastolic: {
        type: Number,
        min: [40, 'Diastolic pressure must be at least 40 mmHg'],
        max: [150, 'Diastolic pressure must be less than 150 mmHg']
      }
    },
    bloodSugar: {
      type: Number, // mg/dL
      min: [50, 'Blood sugar must be at least 50 mg/dL'],
      max: [600, 'Blood sugar must be less than 600 mg/dL']
    },
    cholesterol: {
      total: {
        type: Number,
        min: [100, 'Total cholesterol must be at least 100 mg/dL'],
        max: [400, 'Total cholesterol must be less than 400 mg/dL']
      },
      ldl: {
        type: Number,
        min: [50, 'LDL must be at least 50 mg/dL'],
        max: [250, 'LDL must be less than 250 mg/dL']
      },
      hdl: {
        type: Number,
        min: [20, 'HDL must be at least 20 mg/dL'],
        max: [100, 'HDL must be less than 100 mg/dL']
      }
    },
    weight: {
      type: Number, // kg
      min: [2, 'Weight must be at least 2 kg'],
      max: [300, 'Weight must be less than 300 kg']
    },
    temperature: {
      type: Number, // Celsius
      min: [35, 'Temperature must be at least 35°C'],
      max: [42, 'Temperature must be less than 42°C']
    },
    heartRate: {
      type: Number, // bpm
      min: [40, 'Heart rate must be at least 40 bpm'],
      max: [200, 'Heart rate must be less than 200 bpm']
    }
  },
  notes: {
    type: String,
    trim: true,
    maxlength: [500, 'Notes must be less than 500 characters']
  },
  source: {
    type: String,
    enum: ['manual', 'device', 'import'],
    default: 'manual'
  }
}, {
  timestamps: true
});

// Compound index for efficient queries
healthMetricSchema.index({ userId: 1, date: -1 });
healthMetricSchema.index({ userId: 1, createdAt: -1 });

// Method to get blood pressure category
healthMetricSchema.methods.getBloodPressureCategory = function() {
  if (!this.metrics.bloodPressure.systolic || !this.metrics.bloodPressure.diastolic) {
    return null;
  }

  const { systolic, diastolic } = this.metrics.bloodPressure;

  if (systolic < 120 && diastolic < 80) return 'Normal';
  if (systolic < 130 && diastolic < 80) return 'Elevated';
  if (systolic < 140 || diastolic < 90) return 'High Blood Pressure Stage 1';
  if (systolic < 180 || diastolic < 120) return 'High Blood Pressure Stage 2';
  return 'Hypertensive Crisis';
};

// Method to get blood sugar category
healthMetricSchema.methods.getBloodSugarCategory = function() {
  if (!this.metrics.bloodSugar) return null;

  const sugar = this.metrics.bloodSugar;

  if (sugar < 70) return 'Low (Hypoglycemia)';
  if (sugar < 100) return 'Normal (Fasting)';
  if (sugar < 126) return 'Prediabetes (Fasting)';
  return 'Diabetes (Fasting)';
};

// Method to get cholesterol category
healthMetricSchema.methods.getCholesterolCategory = function() {
  if (!this.metrics.cholesterol.total) return null;

  const total = this.metrics.cholesterol.total;

  if (total < 200) return 'Desirable';
  if (total < 240) return 'Borderline High';
  return 'High';
};

const HealthMetric = mongoose.model('HealthMetric', healthMetricSchema);

module.exports = HealthMetric;