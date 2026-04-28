const HealthMetric = require('../models/HealthMetric');
const { calculateBMI } = require('../utils/bmiCalculator');

/**
 * Create or update health metrics
 * @route POST /api/health/metrics
 */
const createMetrics = async (req, res) => {
  try {
    const { date, metrics, notes, source } = req.body;

    // Check if metrics already exist for this date
    const existingMetrics = await HealthMetric.findOne({
      userId: req.userId,
      date: new Date(date)
    });

    let healthMetric;

    if (existingMetrics) {
      // Update existing metrics
      healthMetric = await HealthMetric.findByIdAndUpdate(
        existingMetrics._id,
        { $set: { metrics, notes, source } },
        { new: true, runValidators: true }
      );
    } else {
      // Create new metrics
      healthMetric = await HealthMetric.create({
        userId: req.userId,
        date: date || new Date(),
        metrics,
        notes,
        source
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Health metrics saved successfully',
      data: { healthMetric }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get health metrics for a specific date
 * @route GET /api/health/metrics/:date
 */
const getMetricsByDate = async (req, res) => {
  try {
    const { date } = req.params;
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);

    const healthMetric = await HealthMetric.findOne({
      userId: req.userId,
      date: {
        $gte: startOfDay,
        $lte: endOfDay
      }
    });

    if (!healthMetric) {
      return res.status(404).json({
        status: 'error',
        message: 'No health metrics found for this date'
      });
    }

    res.status(200).json({
      status: 'success',
      data: { healthMetric }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get health metrics history
 * @route GET /api/health/metrics/history/:period
 */
const getMetricsHistory = async (req, res) => {
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

    const healthMetrics = await HealthMetric.find({
      userId: req.userId,
      date: {
        $gte: startDate,
        $lte: now
      }
    })
      .sort({ date: -1 })
      .limit(parseInt(limit))
      .select('-notes -source');

    // Calculate statistics
    const stats = calculateHealthStats(healthMetrics);

    res.status(200).json({
      status: 'success',
      data: {
        healthMetrics,
        stats,
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
 * Get latest health metrics
 * @route GET /api/health/metrics/latest
 */
const getLatestMetrics = async (req, res) => {
  try {
    const healthMetric = await HealthMetric.findOne({
      userId: req.userId
    }).sort({ date: -1 });

    if (!healthMetric) {
      return res.status(404).json({
        status: 'error',
        message: 'No health metrics found'
      });
    }

    // Add categories for metrics
    const enrichedMetric = {
      ...healthMetric.toObject(),
      categories: {
        bloodPressure: healthMetric.getBloodPressureCategory(),
        bloodSugar: healthMetric.getBloodSugarCategory(),
        cholesterol: healthMetric.getCholesterolCategory()
      }
    };

    res.status(200).json({
      status: 'success',
      data: { healthMetric: enrichedMetric }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Update health metrics
 * @route PUT /api/health/metrics/:id
 */
const updateMetrics = async (req, res) => {
  try {
    const { id } = req.params;
    const { metrics, notes } = req.body;

    const healthMetric = await HealthMetric.findOneAndUpdate(
      { _id: id, userId: req.userId },
      { $set: { metrics, notes } },
      { new: true, runValidators: true }
    );

    if (!healthMetric) {
      return res.status(404).json({
        status: 'error',
        message: 'Health metrics not found'
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Health metrics updated successfully',
      data: { healthMetric }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Delete health metrics
 * @route DELETE /api/health/metrics/:id
 */
const deleteMetrics = async (req, res) => {
  try {
    const { id } = req.params;

    const healthMetric = await HealthMetric.findOneAndDelete({
      _id: id,
      userId: req.userId
    });

    if (!healthMetric) {
      return res.status(404).json({
        status: 'error',
        message: 'Health metrics not found'
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Health metrics deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

/**
 * Get health dashboard overview
 * @route GET /api/health/dashboard
 */
const getDashboard = async (req, res) => {
  try {
    // Get latest metrics
    const latestMetrics = await HealthMetric.findOne({
      userId: req.userId
    }).sort({ date: -1 });

    // Get metrics from last 30 days for trends
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const recentMetrics = await HealthMetric.find({
      userId: req.userId,
      date: { $gte: thirtyDaysAgo }
    }).sort({ date: 1 });

    // Calculate trends
    const trends = calculateTrends(recentMetrics);

    // Get recent predictions (will be implemented with ML service)
    const latestPrediction = null; // Placeholder

    res.status(200).json({
      status: 'success',
      data: {
        latestMetrics,
        recentMetrics: recentMetrics.slice(-7), // Last 7 days
        trends,
        latestPrediction
      }
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

// Helper function to calculate health statistics
const calculateHealthStats = (metrics) => {
  if (!metrics || metrics.length === 0) {
    return {
      averageBloodPressure: null,
      averageBloodSugar: null,
      averageWeight: null,
      totalEntries: 0
    };
  }

  const totalSystolic = metrics.reduce((sum, m) =>
    sum + (m.metrics.bloodPressure?.systolic || 0), 0);
  const totalDiastolic = metrics.reduce((sum, m) =>
    sum + (m.metrics.bloodPressure?.diastolic || 0), 0);
  const totalBloodSugar = metrics.reduce((sum, m) =>
    sum + (m.metrics.bloodSugar || 0), 0);
  const totalWeight = metrics.reduce((sum, m) =>
    sum + (m.metrics.weight || 0), 0);

  const count = metrics.length;

  return {
    averageBloodPressure: {
      systolic: Math.round(totalSystolic / count) || null,
      diastolic: Math.round(totalDiastolic / count) || null
    },
    averageBloodSugar: Math.round(totalBloodSugar / count) || null,
    averageWeight: Math.round(totalWeight * 10) / 10 || null,
    totalEntries: count
  };
};

// Helper function to calculate trends
const calculateTrends = (metrics) => {
  if (!metrics || metrics.length < 2) {
    return {
      weightTrend: null,
      bloodSugarTrend: null,
      bloodPressureTrend: null
    };
  }

  const first = metrics[0];
  const last = metrics[metrics.length - 1];

  return {
    weightTrend: {
      change: last.metrics.weight - first.metrics.weight,
      percentage: first.metrics.weight > 0 ?
        ((last.metrics.weight - first.metrics.weight) / first.metrics.weight * 100).toFixed(1) : 0
    },
    bloodSugarTrend: {
      change: last.metrics.bloodSugar - first.metrics.bloodSugar,
      percentage: first.metrics.bloodSugar > 0 ?
        ((last.metrics.bloodSugar - first.metrics.bloodSugar) / first.metrics.bloodSugar * 100).toFixed(1) : 0
    },
    bloodPressureTrend: {
      systolicChange: last.metrics.bloodPressure?.systolic - first.metrics.bloodPressure?.systolic,
      diastolicChange: last.metrics.bloodPressure?.diastolic - first.metrics.bloodPressure?.diastolic
    }
  };
};

module.exports = {
  createMetrics,
  getMetricsByDate,
  getMetricsHistory,
  getLatestMetrics,
  updateMetrics,
  deleteMetrics,
  getDashboard
};