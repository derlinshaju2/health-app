const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please provide a valid email']
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
    minlength: [6, 'Password must be at least 6 characters long'],
    select: false
  },
  profile: {
    name: {
      type: String,
      required: false,
      trim: true
    },
    age: {
      type: Number,
      min: [1, 'Age must be at least 1'],
      max: [120, 'Age must be less than 120']
    },
    gender: {
      type: String,
      enum: ['male', 'female', 'other'],
      required: false
    },
    height: {
      type: Number, // in centimeters
      min: [50, 'Height must be at least 50 cm'],
      max: [300, 'Height must be less than 300 cm']
    },
    weight: {
      type: Number, // in kilograms
      min: [2, 'Weight must be at least 2 kg'],
      max: [300, 'Weight must be less than 300 kg']
    },
    bmi: {
      type: Number,
      min: [10, 'BMI must be at least 10'],
      max: [60, 'BMI must be less than 60']
    },
    medicalHistory: [{
      type: String,
      trim: true
    }],
    existingConditions: [{
      type: String,
      trim: true
    }],
    activityLevel: {
      type: String,
      enum: ['sedentary', 'light', 'moderate', 'active', 'very_active'],
      default: 'sedentary'
    }
  },
  isActive: {
    type: Boolean,
    default: true
  },
  lastLogin: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Index for faster queries
userSchema.index({ email: 1 });
userSchema.index({ 'profile.age': 1 });
userSchema.index({ createdAt: -1 });

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();

  try {
    const salt = await bcrypt.genSalt(8); // Reduced from 10 to 8 for better performance
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Method to compare password
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Method to calculate BMI
userSchema.methods.calculateBMI = function() {
  if (this.profile.height && this.profile.weight) {
    const heightInMeters = this.profile.height / 100;
    const bmi = this.profile.weight / (heightInMeters * heightInMeters);
    return parseFloat(bmi.toFixed(1));
  }
  return null;
};

// Method to get BMI category
userSchema.methods.getBMICategory = function() {
  const bmi = this.calculateBMI();
  if (!bmi) return null;

  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25) return 'Normal weight';
  if (bmi < 30) return 'Overweight';
  return 'Obese';
};

// Method to calculate daily calorie needs
userSchema.methods.calculateDailyCalories = function() {
  const { age, gender, height, weight, activityLevel } = this.profile;

  if (!age || !gender || !height || !weight) return null;

  // Harris-Benedict Equation
  let bmr;
  if (gender === 'male') {
    bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
  } else {
    bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
  }

  const activityMultiplier = {
    'sedentary': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'active': 1.725,
    'very_active': 1.9
  };

  return Math.round(bmr * (activityMultiplier[activityLevel] || 1.2));
};

const User = mongoose.model('User', userSchema);

module.exports = User;