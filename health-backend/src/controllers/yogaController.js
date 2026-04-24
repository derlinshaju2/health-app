const YogaSession = require('../models/YogaSession');

/**
 * Create yoga session
 * @route POST /api/yoga/session
 */
const createSession = async (req, res) => {
  try {
    const { date, routineType, routineName, duration, poses, difficulty, notes, mood, userRating } = req.body;

    const yogaSession = await YogaSession.create({
      userId: req.userId,
      date: date || new Date(),
      routineType,
      routineName,
      duration,
      poses: poses || [],
      difficulty: difficulty || 'beginner',
      notes,
      mood,
      userRating
    });

    res.status(201).json({
      status: 'success',
      message: 'Yoga session created successfully',
      data: { yogaSession }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get yoga sessions for a period
 * @route GET /api/yoga/sessions/:period
 */
const getSessions = async (req, res) => {
  try {
    const { period } = req.params; // week, month, quarter, year
    const { limit = 30 } = req.query;

    const now = new Date();
    let startDate;

    switch (period) {
      case 'week':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case 'month':
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        break;
      case 'quarter':
        startDate = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
        break;
      case 'year':
        startDate = new Date(now.getTime() - 365 * 24 * 60 * 60 * 1000);
        break;
      default:
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
    }

    const sessions = await YogaSession.find({
      userId: req.userId,
      date: {
        $gte: startDate,
        $lte: now
      }
    })
      .sort({ date: -1 })
      .limit(parseInt(limit));

    // Get statistics
    const stats = await YogaSession.getUserStats(req.userId, startDate, now);
    const currentStreak = await YogaSession.getCurrentStreak(req.userId);
    const mostPracticedRoutine = await YogaSession.getMostPracticedRoutine(req.userId);

    res.status(200).json({
      status: 'success',
      data: {
        sessions,
        stats: {
          ...stats,
          currentStreak,
          mostPracticedRoutine
        },
        period,
        startDate,
        endDate: now
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get yoga pose library
 * @route GET /api/yoga/poses
 */
const getPoses = async (req, res) => {
  try {
    const { difficulty, type } = req.query;

    let poses = getYogaPoses();

    // Filter by difficulty if specified
    if (difficulty) {
      poses = poses.filter(pose => pose.difficulty === difficulty);
    }

    // Filter by type if specified
    if (type) {
      poses = poses.filter(pose => pose.categories.includes(type));
    }

    res.status(200).json({
      status: 'success',
      data: { poses }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get yoga routines
 * @route GET /api/yoga/routines
 */
const getRoutines = async (req, res) => {
  try {
    const { type, difficulty } = req.query;

    let routines = getYogaRoutines();

    // Filter by type if specified
    if (type) {
      routines = routines.filter(routine => routine.type === type);
    }

    // Filter by difficulty if specified
    if (difficulty) {
      routines = routines.filter(routine => routine.difficulty === difficulty);
    }

    res.status(200).json({
      status: 'success',
      data: { routines }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get yoga progress for user
 * @route GET /api/yoga/progress/:userId
 */
const getProgress = async (req, res) => {
  try {
    const { userId } = req.params;

    // Verify user is requesting their own progress
    if (userId !== req.userId.toString()) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    const now = new Date();
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    // Get recent sessions
    const recentSessions = await YogaSession.find({
      userId: req.userId,
      date: { $gte: thirtyDaysAgo, $lte: now }
    }).sort({ date: 1 });

    // Calculate progress metrics
    const progress = {
      totalSessions: recentSessions.length,
      totalDuration: recentSessions.reduce((sum, s) => sum + s.duration, 0),
      totalCaloriesBurned: recentSessions.reduce((sum, s) => sum + (s.caloriesBurned || 0), 0),
      averageDuration: recentSessions.length > 0
        ? Math.round(recentSessions.reduce((sum, s) => sum + s.duration, 0) / recentSessions.length)
        : 0,
      completedSessions: recentSessions.filter(s => s.completed).length,
      currentStreak: await YogaSession.getCurrentStreak(req.userId),
      mostPracticedRoutine: await YogaSession.getMostPracticedRoutine(req.userId),
      routineBreakdown: calculateRoutineBreakdown(recentSessions),
      weeklyProgress: calculateWeeklyProgress(recentSessions)
    };

    res.status(200).json({
      status: 'success',
      data: { progress }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Update yoga session
 * @route PUT /api/yoga/session/:id
 */
const updateSession = async (req, res) => {
  try {
    const { id } = req.params;
    const { duration, poses, completed, notes, mood, userRating } = req.body;

    const yogaSession = await YogaSession.findOneAndUpdate(
      { _id: id, userId: req.userId },
      {
        $set: {
          ...(duration && { duration }),
          ...(poses && { poses }),
          ...(completed !== undefined && { completed }),
          ...(notes !== undefined && { notes }),
          ...(mood && { mood }),
          ...(userRating && { userRating })
        }
      },
      { new: true, runValidators: true }
    );

    if (!yogaSession) {
      return res.status(404).json({
        status: 'error',
        message: 'Yoga session not found'
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Yoga session updated successfully',
      data: { yogaSession }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Delete yoga session
 * @route DELETE /api/yoga/session/:id
 */
const deleteSession = async (req, res) => {
  try {
    const { id } = req.params;

    const yogaSession = await YogaSession.findOneAndDelete({
      _id: id,
      userId: req.userId
    });

    if (!yogaSession) {
      return res.status(404).json({
        status: 'error',
        message: 'Yoga session not found'
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Yoga session deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

// Helper function to get yoga poses
const getYogaPoses = () => {
  return [
    {
      id: 'mountain-pose',
      name: 'Mountain Pose (Tadasana)',
      sanskritName: 'Tadasana',
      difficulty: 'beginner',
      duration: 30,
      categories: ['standing', 'beginner', 'flexibility'],
      benefits: [
        'Improves posture',
        'Strengthens thighs, knees, and ankles',
        'Firms abdomen and buttocks',
        'Relieves sciatica'
      ],
      instructions: [
        'Stand with feet together',
        'Ground down through the feet',
        'Lengthen through the spine',
        'Relax shoulders down and back',
        'Breathe steadily'
      ],
      imageUrl: '/images/poses/mountain-pose.jpg'
    },
    {
      id: 'downward-dog',
      name: 'Downward-Facing Dog (Adho Mukha Svanasana)',
      sanskritName: 'Adho Mukha Svanasana',
      difficulty: 'beginner',
      duration: 60,
      categories: ['standing', 'flexibility', 'strength'],
      benefits: [
        'Stretches hamstrings and calves',
        'Strengthens arms and legs',
        'Relieves back pain',
        'Improves circulation'
      ],
      instructions: [
        'Start on hands and knees',
        'Lift hips up and back',
        'Straighten legs as much as comfortable',
        'Press heels toward the floor',
        'Relax head and neck'
      ],
      imageUrl: '/images/poses/downward-dog.jpg'
    },
    {
      id: 'warrior-one',
      name: 'Warrior I (Virabhadrasana I)',
      sanskritName: 'Virabhadrasana I',
      difficulty: 'intermediate',
      duration: 45,
      categories: ['standing', 'strength', 'balance'],
      benefits: [
        'Strengthens legs and core',
        'Opens hips and chest',
        'Improves balance and focus',
        'Stretches arms and back'
      ],
      instructions: [
        'Step one foot back',
        'Bend front knee to 90 degrees',
        'Reach arms overhead',
        'Keep hips square to front',
        'Ground through both feet'
      ],
      imageUrl: '/images/poses/warrior-one.jpg'
    },
    {
      id: 'tree-pose',
      name: 'Tree Pose (Vrksasana)',
      sanskritName: 'Vrksasana',
      difficulty: 'intermediate',
      duration: 30,
      categories: ['balance', 'standing', 'focus'],
      benefits: [
        'Improves balance and stability',
        'Strengthens legs and core',
        'Improves focus and concentration',
        'Stretches thighs and groin'
      ],
      instructions: [
        'Stand on one leg',
        'Place other foot on inner thigh',
        'Bring hands to heart center',
        'Find a focal point',
        'Hold and breathe steadily'
      ],
      imageUrl: '/images/poses/tree-pose.jpg'
    },
    {
      id: 'child-pose',
      name: "Child's Pose (Balasana)",
      sanskritName: 'Balasana',
      difficulty: 'beginner',
      duration: 60,
      categories: ['resting', 'flexibility', 'stress_relief'],
      benefits: [
        'Relieves stress and tension',
        'Gently stretches hips and thighs',
        'Calms the mind',
        'Relieves back and neck pain'
      ],
      instructions: [
        'Kneel on the floor',
        'Sit back on heels',
        'Fold forward, resting forehead on floor',
        'Extend arms forward or by sides',
        'Breathe deeply and relax'
      ],
      imageUrl: '/images/poses/child-pose.jpg'
    },
    {
      id: 'cobra-pose',
      name: 'Cobra Pose (Bhujangasana)',
      sanskritName: 'Bhujangasana',
      difficulty: 'beginner',
      duration: 30,
      categories: ['backbend', 'strength', 'flexibility'],
      benefits: [
        'Strengthens spine',
        'Stretches chest and lungs',
        'Relieves fatigue and stress',
        'Opens heart center'
      ],
      instructions: [
        'Lie on stomach',
        'Place hands under shoulders',
        'Press into hands, lift chest',
        'Keep elbows close to body',
        'Look upward slightly'
      ],
      imageUrl: '/images/poses/cobra-pose.jpg'
    }
  ];
};

// Helper function to get yoga routines
const getYogaRoutines = () => {
  return [
    {
      id: 'morning-energy',
      name: 'Morning Energy Flow',
      type: 'general',
      difficulty: 'beginner',
      duration: 15,
      description: 'A quick morning sequence to energize your body and mind',
      poses: [
        { poseId: 'mountain-pose', duration: 30 },
        { poseId: 'downward-dog', duration: 60 },
        { poseId: 'warrior-one', duration: 45 },
        { poseId: 'tree-pose', duration: 30 },
        { poseId: 'child-pose', duration: 60 }
      ],
      benefits: ['Increases energy', 'Improves focus', 'Stretches major muscle groups']
    },
    {
      id: 'stress-relief',
      name: 'Stress Relief Sequence',
      type: 'stress_relief',
      difficulty: 'beginner',
      duration: 20,
      description: 'A calming sequence to reduce stress and promote relaxation',
      poses: [
        { poseId: 'child-pose', duration: 90 },
        { poseId: 'cobra-pose', duration: 45 },
        { poseId: 'downward-dog', duration: 60 },
        { poseId: 'child-pose', duration: 90 }
      ],
      benefits: ['Reduces stress', 'Calms nervous system', 'Promotes relaxation']
    },
    {
      id: 'flexibility-builder',
      name: 'Flexibility Builder',
      type: 'flexibility',
      difficulty: 'intermediate',
      duration: 25,
      description: 'A sequence designed to improve overall flexibility',
      poses: [
        { poseId: 'downward-dog', duration: 90 },
        { poseId: 'warrior-one', duration: 60 },
        { poseId: 'cobra-pose', duration: 45 },
        { poseId: 'tree-pose', duration: 45 },
        { poseId: 'child-pose', duration: 60 }
      ],
      benefits: ['Increases flexibility', 'Strengthens muscles', 'Improves balance']
    },
    {
      id: 'diabetes-management',
      name: 'Diabetes Management Routine',
      type: 'diabetes_management',
      difficulty: 'beginner',
      duration: 20,
      description: 'Gentle yoga poses that may help manage diabetes symptoms',
      poses: [
        { poseId: 'mountain-pose', duration: 60 },
        { poseId: 'tree-pose', duration: 45 },
        { poseId: 'downward-dog', duration: 60 },
        { poseId: 'cobra-pose', duration: 45 },
        { poseId: 'child-pose', duration: 90 }
      ],
      benefits: ['Improves circulation', 'Reduces stress', 'Supports insulin sensitivity']
    }
  ];
};

// Helper function to calculate routine breakdown
const calculateRoutineBreakdown = (sessions) => {
  const breakdown = {};

  sessions.forEach(session => {
    const routine = session.routineType;
    if (!breakdown[routine]) {
      breakdown[routine] = {
        count: 0,
        totalDuration: 0,
        totalCalories: 0
      };
    }
    breakdown[routine].count += 1;
    breakdown[routine].totalDuration += session.duration;
    breakdown[routine].totalCalories += session.caloriesBurned || 0;
  });

  return breakdown;
};

// Helper function to calculate weekly progress
const calculateWeeklyProgress = (sessions) => {
  const weeklyData = [];
  const now = new Date();

  for (let i = 6; i >= 0; i--) {
    const date = new Date(now);
    date.setDate(date.getDate() - i);
    date.setHours(0, 0, 0, 0);

    const nextDate = new Date(date);
    nextDate.setDate(nextDate.getDate() + 1);

    const daySessions = sessions.filter(session => {
      const sessionDate = new Date(session.date);
      return sessionDate >= date && sessionDate < nextDate;
    });

    weeklyData.push({
      date: date.toISOString().split('T')[0],
      sessions: daySessions.length,
      duration: daySessions.reduce((sum, s) => sum + s.duration, 0),
      calories: daySessions.reduce((sum, s) => sum + (s.caloriesBurned || 0), 0)
    });
  }

  return weeklyData;
};

module.exports = {
  createSession,
  getSessions,
  getPoses,
  getRoutines,
  getProgress,
  updateSession,
  deleteSession
};