const Joi = require('joi');

// Validation middleware factory
const validate = (schema) => {
  return (req, res, next) => {
    const { error } = schema.validate(req.body);

    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));

      return res.status(400).json({
        status: 'error',
        message: 'Validation error',
        errors
      });
    }

    next();
  };
};

// Validation schemas
const schemas = {
  // Auth schemas
  register: Joi.object({
    email: Joi.string().email().required().messages({
      'string.email': 'Please provide a valid email',
      'any.required': 'Email is required'
    }),
    password: Joi.string().min(6).required().messages({
      'string.min': 'Password must be at least 6 characters long',
      'any.required': 'Password is required'
    }),
    profile: Joi.object({
      name: Joi.string().min(2).max(50),
      age: Joi.number().integer().min(1).max(120),
      gender: Joi.string().valid('male', 'female', 'other'),
      height: Joi.number().min(50).max(300),
      weight: Joi.number().min(2).max(300),
      medicalHistory: Joi.array().items(Joi.string()),
      existingConditions: Joi.array().items(Joi.string()),
      activityLevel: Joi.string().valid('sedentary', 'light', 'moderate', 'active', 'very_active')
    })
  }),

  login: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().required()
  }),

  // Health metrics schemas
  healthMetrics: Joi.object({
    date: Joi.date(),
    metrics: Joi.object({
      bloodPressure: Joi.object({
        systolic: Joi.number().min(70).max(250),
        diastolic: Joi.number().min(40).max(150)
      }),
      bloodSugar: Joi.number().min(50).max(600),
      cholesterol: Joi.object({
        total: Joi.number().min(100).max(400),
        ldl: Joi.number().min(50).max(250),
        hdl: Joi.number().min(20).max(100)
      }),
      weight: Joi.number().min(2).max(300),
      temperature: Joi.number().min(35).max(42),
      heartRate: Joi.number().min(40).max(200)
    }).required(),
    notes: Joi.string().max(500),
    source: Joi.string().valid('manual', 'device', 'import')
  }),

  // Diet plan schemas
  dietPlan: Joi.object({
    date: Joi.date(),
    dailyCalorieTarget: Joi.number().min(1000).max(5000).required(),
    meals: Joi.array().items(Joi.object({
      type: Joi.string().valid('breakfast', 'lunch', 'dinner', 'snack').required(),
      foods: Joi.array().items(Joi.object({
        name: Joi.string().required(),
        calories: Joi.number().min(0).required(),
        protein: Joi.number().min(0),
        carbs: Joi.number().min(0),
        fats: Joi.number().min(0),
        fiber: Joi.number().min(0),
        servingSize: Joi.string()
      })),
      notes: Joi.string()
    })),
    waterIntake: Joi.object({
      target: Joi.number().min(1),
      current: Joi.number().min(0)
    })
  }),

  // Food log schemas
  foodLog: Joi.object({
    date: Joi.date(),
    meals: Joi.array().items(Joi.object({
      type: Joi.string().valid('breakfast', 'lunch', 'dinner', 'snack').required(),
      time: Joi.date(),
      foods: Joi.array().items(Joi.object({
        name: Joi.string().required(),
        calories: Joi.number().min(0),
        protein: Joi.number().min(0),
        carbs: Joi.number().min(0),
        fats: Joi.number().min(0)
      })),
      notes: Joi.string()
    })),
    waterIntake: Joi.number().min(0),
    notes: Joi.string().max(500)
  }),

  // Yoga session schemas
  yogaSession: Joi.object({
    date: Joi.date(),
    routineType: Joi.string().valid('flexibility', 'stress_relief', 'weight_loss', 'diabetes_management', 'general', 'custom').required(),
    routineName: Joi.string().required(),
    duration: Joi.number().min(1).max(180).required(),
    poses: Joi.array().items(Joi.object({
      name: Joi.string().required(),
      duration: Joi.number().min(10).max(300).required(),
      repetitions: Joi.number().min(1),
      completed: Joi.boolean()
    })),
    difficulty: Joi.string().valid('beginner', 'intermediate', 'advanced'),
    caloriesBurned: Joi.number().min(0),
    completed: Joi.boolean(),
    notes: Joi.string().max(500),
    mood: Joi.string().valid('energetic', 'relaxed', 'tired', 'stressed', 'neutral'),
    userRating: Joi.number().min(1).max(5)
  }),

  // Notification schemas
  notification: Joi.object({
    type: Joi.string().valid('medicine', 'workout', 'checkup', 'risk_alert', 'diet', 'water', 'system').required(),
    title: Joi.string().max(100).required(),
    message: Joi.string().max(500).required(),
    scheduledTime: Joi.date().required(),
    priority: Joi.string().valid('low', 'medium', 'high', 'urgent'),
    actionRequired: Joi.boolean(),
    actionType: Joi.string().valid('none', 'confirm', 'dismiss', 'log_data', 'view_details'),
    metadata: Joi.object(),
    recurrence: Joi.string().valid('none', 'daily', 'weekly', 'monthly'),
    recurrenceEndDate: Joi.date()
  })
};

module.exports = { validate, schemas };