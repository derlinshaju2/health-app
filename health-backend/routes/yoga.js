const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');

// Yoga recommendation engine based on fitness level and health conditions
const getYogaRecommendations = (userProfile, healthMetrics = {}) => {
    const { fitnessLevel, age, goal, flexibility } = userProfile;

    // Determine yoga difficulty level
    let yogaLevel, sessionDuration, posesCount;

    switch (fitnessLevel) {
        case 'beginner':
            yogaLevel = 'beginner';
            sessionDuration = 20; // minutes
            posesCount = 5;
            break;
        case 'intermediate':
            yogaLevel = 'intermediate';
            sessionDuration = 30; // minutes
            posesCount = 8;
            break;
        case 'advanced':
            yogaLevel = 'advanced';
            sessionDuration = 45; // minutes
            posesCount = 12;
            break;
        default:
            yogaLevel = 'beginner';
            sessionDuration = 20;
            posesCount = 5;
    }

    // Adjust for age
    if (age > 50) {
        sessionDuration -= 5;
        posesCount -= 2;
    } else if (age < 30) {
        sessionDuration += 5;
        posesCount += 2;
    }

    // Generate yoga routine
    const yogaRoutine = generateYogaRoutine(yogaLevel, posesCount, sessionDuration, healthMetrics);

    // Get warm-up and cool-down exercises
    const warmup = getWarmupExercises(yogaLevel);
    const cooldown = getCooldownExercises(yogaLevel);

    // Get breathing exercises
    const breathing = getBreathingExercises();

    // Get tips and precautions
    const tips = getYogaTips(yogaLevel, healthMetrics);
    const precautions = getPrecautions(healthMetrics);

    return {
        yogaLevel,
        sessionDuration,
        posesCount,
        routine: yogaRoutine,
        warmup,
        cooldown,
        breathing,
        tips,
        precautions,
        weeklySchedule: generateWeeklySchedule(yogaLevel, goal)
    };
};

// Generate yoga routine based on level
const generateYogaRoutine = (level, posesCount, duration, healthMetrics) => {
    const poses = {
        beginner: [
            { name: 'Mountain Pose (Tadasana)', duration: 1, benefits: 'Improves posture, strengthens legs', difficulty: 1 },
            { name: 'Downward-Facing Dog (Adho Mukha Svanasana)', duration: 2, benefits: 'Strengthens arms, stretches hamstrings', difficulty: 2 },
            { name: 'Cat-Cow Stretch (Marjaryasana-Bitilasana)', duration: 2, benefits: 'Warms up spine, relieves back pain', difficulty: 1 },
            { name: 'Tree Pose (Vrksasana)', duration: 1, benefits: 'Improves balance, strengthens legs', difficulty: 2 },
            { name: 'Child\'s Pose (Balasana)', duration: 2, benefits: 'Relaxes body, stretches hips', difficulty: 1 },
            { name: 'Warrior I (Virabhadrasana I)', duration: 2, benefits: 'Strengthens legs, opens hips', difficulty: 2 },
            { name: 'Seated Forward Bend (Paschimottanasana)', duration: 2, benefits: 'Stretches spine, hamstrings', difficulty: 2 },
            { name: 'Corpse Pose (Savasana)', duration: 5, benefits: 'Deep relaxation, reduces stress', difficulty: 1 }
        ],
        intermediate: [
            { name: 'Sun Salutation (Surya Namaskar)', duration: 5, benefits: 'Full body workout, improves flexibility', difficulty: 3 },
            { name: 'Warrior II (Virabhadrasana II)', duration: 2, benefits: 'Strengthens legs, opens hips and chest', difficulty: 3 },
            { name: 'Triangle Pose (Trikonasana)', duration: 2, benefits: 'Stretches hips, groins, hamstrings', difficulty: 3 },
            { name: 'Extended Side Angle (Utthita Parsvakonasana)', duration: 2, benefits: 'Strengthens legs, opens side body', difficulty: 3 },
            { name: 'Bridge Pose (Setu Bandha Sarvangasana)', duration: 2, benefits: 'Strengthens back, opens chest', difficulty: 3 },
            { name: 'Cobra Pose (Bhujangasana)', duration: 2, benefits: 'Strengthens spine, opens chest', difficulty: 2 },
            { name: 'Camel Pose (Ustrasana)', duration: 2, benefits: 'Opens chest, improves flexibility', difficulty: 3 },
            { name: 'Headstand (Sirsasana)', duration: 3, benefits: 'Strengthens core, improves circulation', difficulty: 4 },
            { name: 'Plow Pose (Halasana)', duration: 2, benefits: 'Stretches spine, calms brain', difficulty: 3 },
            { name: 'Fish Pose (Matsyasana)', duration: 2, benefits: 'Opens chest, throat', difficulty: 3 },
            { name: 'Crow Pose (Bakasana)', duration: 2, benefits: 'Strengthens arms, core', difficulty: 4 },
            { name: 'Corpse Pose (Savasana)', duration: 5, benefits: 'Deep relaxation', difficulty: 1 }
        ],
        advanced: [
            { name: 'Advanced Sun Salutation', duration: 8, benefits: 'Full body workout with variations', difficulty: 5 },
            { name: 'Handstand (Adho Mukha Vrksasana)', duration: 3, benefits: 'Strengthens arms, shoulders, core', difficulty: 5 },
            { name: 'Scorpion Pose (Vrschikasana)', duration: 3, benefits: 'Strengthens back, opens chest', difficulty: 5 },
            { name: 'Lotus Pose (Padmasana)', duration: 5, benefits: 'Meditation, hip opening', difficulty: 4 },
            { name: 'Wheel Pose (Urdhva Dhanurasana)', duration: 3, benefits: 'Strengthens back, opens chest', difficulty: 4 },
            { name: 'Peacock Pose (Mayurasana)', duration: 2, benefits: 'Strengthens arms, core', difficulty: 5 },
            { name: 'Side Crow Pose (Parsva Bakasana)', duration: 2, benefits: 'Strengthens arms, core', difficulty: 4 },
            { name: 'Eight-Angle Pose (Astavakrasana)', duration: 2, benefits: 'Strengthens arms, core', difficulty: 5 },
            { name: 'Forearm Stand (Pincha Mayurasana)', duration: 4, benefits: 'Strengthens shoulders, core', difficulty: 5 },
            { name: 'King Pigeon Pose (Rajakapotasana)', duration: 3, benefits: 'Hip opening, chest opening', difficulty: 4 },
            { name: 'Split Pose (Hanumanasana)', duration: 3, benefits: 'Hip opening, hamstring flexibility', difficulty: 4 },
            { name: 'Corpse Pose (Savasana)', duration: 8, benefits: 'Deep relaxation', difficulty: 1 }
        ]
    };

    let selectedPoses = poses[level] || poses.beginner;

    // Customize based on health conditions
    if (healthMetrics.bloodPressure) {
        const { systolic, diastolic } = healthMetrics.bloodPressure;
        if (systolic > 140 || diastolic > 90) {
            // Avoid inversions for high blood pressure
            selectedPoses = selectedPoses.filter(pose =>
                !pose.name.includes('Headstand') &&
                !pose.name.includes('Handstand') &&
                !pose.name.includes('Forearm Stand')
            );
        }
    }

    if (healthMetrics.bmi && healthMetrics.bmi > 30) {
        // Modify poses for obesity
        selectedPoses = selectedPoses.filter(pose =>
            !pose.name.includes('Crow') &&
            !pose.name.includes('Peacock')
        );
    }

    // Select the required number of poses
    const routine = selectedPoses.slice(0, Math.min(posesCount, selectedPoses.length));

    // Adjust durations to fit session time
    const totalPoseTime = routine.reduce((sum, pose) => sum + pose.duration, 0);
    const timeMultiplier = (duration - 5) / totalPoseTime; // -5 for Savasana

    return routine.map(pose => ({
        ...pose,
        duration: Math.round(pose.duration * timeMultiplier * 10) / 10
    }));
};

// Get warm-up exercises
const getWarmupExercises = (level) => {
    const warmups = [
        { name: 'Neck Rolls', duration: 1, instructions: 'Gently roll neck in circles, 5 times each direction' },
        { name: 'Shoulder Rolls', duration: 1, instructions: 'Roll shoulders backward and forward, 10 times each' },
        { name: 'Arm Circles', duration: 1, instructions: 'Make large circles with arms, 10 times each direction' },
        { name: 'Torso Twists', duration: 1, instructions: 'Gently twist torso side to side, 10 times' },
        { name: 'Knee Circles', duration: 1, instructions: 'Circle knees in one direction, then reverse, 10 times' }
    ];

    if (level === 'intermediate' || level === 'advanced') {
        warmups.push(
            { name: 'Hip Circles', duration: 1, instructions: 'Circle hips in one direction, then reverse, 10 times' },
            { name: 'Ankle Rotations', duration: 1, instructions: 'Rotate ankles in circles, 10 times each direction' }
        );
    }

    return warmups;
};

// Get cool-down exercises
const getCooldownExercises = (level) => {
    const cooldowns = [
        { name: 'Seated Forward Fold', duration: 2, instructions: 'Sit and fold forward, relax spine' },
        { name: 'Butterfly Pose', duration: 2, instructions: 'Sit with soles together, gently press knees' },
        { name: 'Reclined Twist', duration: 2, instructions: 'Lie on back, drop knees to one side' },
        { name: 'Corpse Pose', duration: 5, instructions: 'Lie flat, close eyes, relax completely' }
    ];

    return cooldowns;
};

// Get breathing exercises
const getBreathingExercises = () => {
    return [
        { name: 'Deep Breathing', duration: 3, instructions: 'Inhale deeply for 4 counts, exhale for 6 counts' },
        { name: 'Alternate Nostril Breathing (Nadi Shodhana)', duration: 3, instructions: 'Alternate breathing through left and right nostrils' },
        { name: 'Ocean Breath (Ujjayi)', duration: 2, instructions: 'Constrict throat and breathe with sound' },
        { name: 'Skull Shining Breath (Kapalabhati)', duration: 2, instructions: 'Short forceful exhalations, passive inhalations' }
    ];
};

// Get yoga tips
const getYogaTips = (level, healthMetrics) => {
    const tips = [
        'Practice on an empty stomach or 2-3 hours after meals',
        'Listen to your body and don\'t push beyond your limits',
        'Focus on your breath throughout the practice',
        'Use props (blocks, straps) to modify poses as needed',
        'Be consistent - practice regularly rather than intensely'
    ];

    if (level === 'beginner') {
        tips.push('Start with shorter sessions and gradually increase duration');
        tips.push('Focus on proper alignment rather than depth of poses');
    } else if (level === 'advanced') {
        tips.push('Always warm up properly before advanced poses');
        tips.push('Consider practicing with a qualified teacher for advanced poses');
    }

    if (healthMetrics.bloodPressure && healthMetrics.bloodPressure.systolic > 140) {
        tips.push('Avoid inversions and hold poses for shorter durations');
        tips.push('Focus on restorative poses and forward bends');
    }

    return tips;
};

// Get precautions
const getPrecautions = (healthMetrics) => {
    const precautions = [];

    if (healthMetrics.bloodPressure) {
        const { systolic, diastolic } = healthMetrics.bloodPressure;
        if (systolic > 140 || diastolic > 90) {
            precautions.push('Avoid or modify inversions (headstand, handstand, shoulderstand)');
            precautions.push('Avoid holding breath during poses');
            precautions.push('Focus on grounding and calming poses');
        }
    }

    if (healthMetrics.bmi && healthMetrics.bmi > 30) {
        precautions.push('Modify poses to accommodate body size');
        precautions.push('Use props for support in balancing poses');
        precautions.push('Focus on building strength gradually');
    }

    if (healthMetrics.bloodSugar && healthMetrics.bloodSugar > 100) {
        precautions.push('Monitor blood sugar before and after practice');
        precautions.push('Avoid intense poses if blood sugar is unstable');
    }

    return precautions;
};

// Generate weekly schedule
const generateWeeklySchedule = (level, goal) => {
    const schedules = {
        weight_loss: {
            monday: 'Active Vinyasa Flow - 30 mins',
            tuesday: 'Power Yoga - 30 mins',
            wednesday: 'Restorative Yoga - 20 mins',
            thursday: 'Ashtanga Primary - 30 mins',
            friday: 'HIIT Yoga - 25 mins',
            saturday: 'Yin Yoga - 30 mins',
            sunday: 'Rest or gentle stretching'
        },
        flexibility: {
            monday: 'Hatha Yoga - 30 mins',
            tuesday: 'Yin Yoga - 40 mins',
            wednesday: 'Vinyasa Flow - 30 mins',
            thursday: 'Deep Stretch - 35 mins',
            friday: 'Restorative - 30 mins',
            saturday: 'Ashtanga - 30 mins',
            sunday: 'Gentle Flow - 25 mins'
        },
        strength: {
            monday: 'Power Yoga - 35 mins',
            tuesday: 'Ashtanga - 40 mins',
            wednesday: 'Core Yoga - 30 mins',
            thursday: 'Arm Balance Practice - 30 mins',
            friday: 'Inversion Practice - 25 mins',
            saturday: 'Vinyasa Flow - 35 mins',
            sunday: 'Restorative - 20 mins'
        },
        stress_relief: {
            monday: 'Gentle Hatha - 25 mins',
            tuesday: 'Yin Yoga - 35 mins',
            wednesday: 'Restorative - 30 mins',
            thursday: 'Breathing Focus - 20 mins',
            friday: 'Meditation & Yoga - 25 mins',
            saturday: 'Yoga Nidra - 30 mins',
            sunday: 'Nature Walk & Gentle Stretching'
        },
        general: {
            monday: 'Hatha Yoga - 30 mins',
            tuesday: 'Vinyasa Flow - 30 mins',
            wednesday: 'Rest Day',
            thursday: 'Yin Yoga - 30 mins',
            friday: 'Ashtanga - 30 mins',
            saturday: 'Power Yoga - 30 mins',
            sunday: 'Meditation & Gentle Flow - 20 mins'
        }
    };

    return schedules[goal] || schedules.general;
};

// @route   GET /api/yoga
// @desc    Get personalized yoga recommendations
// @access  Private
router.get('/', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;

    // Get user parameters
    const fitnessLevel = req.query.fitnessLevel || 'beginner';
    const age = parseInt(req.query.age) || 30;
    const goal = req.query.goal || 'general';
    const flexibility = req.query.flexibility || 'moderate';

    const userProfile = { fitnessLevel, age, goal, flexibility };

    // Get health metrics if available
    const healthMetrics = {};
    if (req.query.bmi) healthMetrics.bmi = parseFloat(req.query.bmi);
    if (req.query.bloodSugar) healthMetrics.bloodSugar = parseFloat(req.query.bloodSugar);
    if (req.query.systolic && req.query.diastolic) {
        healthMetrics.bloodPressure = {
            systolic: parseInt(req.query.systolic),
            diastolic: parseInt(req.query.diastolic)
        };
    }

    // Generate recommendations
    const recommendations = getYogaRecommendations(userProfile, healthMetrics);

    res.status(200).json({
      status: 'success',
      message: 'Yoga recommendations generated successfully',
      data: {
        userProfile,
        recommendations
      }
    });
  } catch (error) {
    console.error('Error generating yoga recommendations:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to generate yoga recommendations',
      error: error.message
    });
  }
});

// @route   GET /api/yoga/routine
// @desc    Get detailed yoga routine for the day
// @access  Private
router.get('/routine', authenticateToken, async (req, res) => {
  try {
    const { fitnessLevel = 'beginner', goal = 'general' } = req.query;

    const userProfile = { fitnessLevel, goal, age: 30 };
    const recommendations = getYogaRecommendations(userProfile);

    res.status(200).json({
      status: 'success',
      message: 'Yoga routine generated successfully',
      data: {
        routine: recommendations.routine,
        warmup: recommendations.warmup,
        cooldown: recommendations.cooldown,
        sessionDuration: recommendations.sessionDuration
      }
    });
  } catch (error) {
    console.error('Error generating yoga routine:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to generate yoga routine',
      error: error.message
    });
  }
});

module.exports = router;