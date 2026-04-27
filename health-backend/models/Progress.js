const mongoose = require('mongoose');

const progressSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    date: {
        type: Date,
        required: true,
        default: Date.now
    },
    // Diet Progress
    diet: {
        caloriesConsumed: {
            type: Number,
            default: 0
        },
        caloriesTarget: {
            type: Number,
            default: 2000
        },
        waterIntake: {
            type: Number,
            default: 0
        },
        waterTarget: {
            type: Number,
            default: 8
        },
        mealsLogged: {
            type: Number,
            default: 0
        },
        dietPlanFollowed: {
            type: Boolean,
            default: false
        },
        dietNotes: {
            type: String,
            default: ''
        }
    },
    // Yoga Progress
    yoga: {
        durationMinutes: {
            type: Number,
            default: 0
        },
        targetMinutes: {
            type: Number,
            default: 30
        },
        posesCompleted: {
            type: Number,
            default: 0
        },
        difficulty: {
            type: String,
            enum: ['beginner', 'intermediate', 'advanced'],
            default: 'beginner'
        },
        yogaType: {
            type: String,
            default: 'hatha'
        },
        exercisesCompleted: [{
            name: String,
            duration: Number,
            repetitions: Number
        }],
        yogaNotes: {
            type: String,
            default: ''
        }
    },
    // Overall Wellness
    wellness: {
        energyLevel: {
            type: Number,
            min: 1,
            max: 10,
            default: 5
        },
        mood: {
            type: String,
            enum: ['excellent', 'good', 'neutral', 'bad', 'terrible'],
            default: 'neutral'
        },
        sleepQuality: {
            type: Number,
            min: 1,
            max: 10,
            default: 5
        },
        stressLevel: {
            type: Number,
            min: 1,
            max: 10,
            default: 5
        }
    },
    // Achievements
    achievements: [{
        type: {
            type: String,
            enum: ['diet', 'yoga', 'wellness', 'streak']
        },
        title: String,
        description: String,
        date: {
            type: Date,
            default: Date.now
        }
    }]
}, {
    timestamps: true
});

// Index for efficient queries
progressSchema.index({ userId: 1, date: -1 });

module.exports = mongoose.model('Progress', progressSchema);