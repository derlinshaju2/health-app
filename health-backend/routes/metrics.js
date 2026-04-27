const express = require('express');
const router = express.Router();
const HealthMetrics = require('../models/HealthMetrics');
const { authenticateToken } = require('../middleware/auth');

// @route   POST /api/metrics/add
// @desc    Add health metrics for a user
// @access  Private
router.post('/add', authenticateToken, async (req, res) => {
  try {
    const { bloodPressure, bloodSugar, cholesterol, notes } = req.body;
    const userId = req.user.id;

    // Validate input
    if (!bloodPressure && !bloodSugar && !cholesterol) {
      return res.status(400).json({
        status: 'error',
        message: 'At least one metric (blood pressure, blood sugar, or cholesterol) is required'
      });
    }

    // Create new health metrics entry
    const newMetrics = new HealthMetrics({
      userId,
      bloodPressure: bloodPressure || { systolic: null, diastolic: null },
      bloodSugar: bloodSugar || null,
      cholesterol: cholesterol || { ldl: null, hdl: null, total: null },
      notes: notes || ''
    });

    const savedMetrics = await newMetrics.save();

    res.status(201).json({
      status: 'success',
      message: 'Health metrics added successfully',
      data: savedMetrics
    });
  } catch (error) {
    console.error('Error adding health metrics:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to add health metrics',
      error: error.message
    });
  }
});

// @route   GET /api/metrics/history
// @desc    Get health metrics history for a user
// @access  Private
router.get('/history', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { limit = 50, skip = 0, startDate, endDate } = req.query;

    // Build query
    const query = { userId };

    // Add date range filter if provided
    if (startDate || endDate) {
      query.timestamp = {};
      if (startDate) query.timestamp.$gte = new Date(startDate);
      if (endDate) query.timestamp.$lte = new Date(endDate);
    }

    // Get metrics with pagination
    const metrics = await HealthMetrics.find(query)
      .sort({ timestamp: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(skip))
      .exec();

    // Get total count
    const total = await HealthMetrics.countDocuments(query);

    res.status(200).json({
      status: 'success',
      message: 'Health metrics retrieved successfully',
      data: {
        metrics,
        pagination: {
          total,
          limit: parseInt(limit),
          skip: parseInt(skip),
          hasMore: parseInt(skip) + parseInt(limit) < total
        }
      }
    });
  } catch (error) {
    console.error('Error fetching health metrics:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch health metrics',
      error: error.message
    });
  }
});

// @route   GET /api/metrics/latest
// @desc    Get latest health metrics for a user
// @access  Private
router.get('/latest', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;

    const latestMetrics = await HealthMetrics.findOne({ userId })
      .sort({ timestamp: -1 })
      .exec();

    if (!latestMetrics) {
      return res.status(404).json({
        status: 'error',
        message: 'No health metrics found for this user'
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Latest health metrics retrieved successfully',
      data: latestMetrics
    });
  } catch (error) {
    console.error('Error fetching latest health metrics:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to fetch latest health metrics',
      error: error.message
    });
  }
});

// @route   GET /api/metrics/analytics
// @desc    Get health metrics analytics for a user
// @access  Private
router.get('/analytics', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { days = 30 } = req.query;

    // Calculate date range
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    // Get metrics in date range
    const metrics = await HealthMetrics.find({
      userId,
      timestamp: { $gte: startDate, $lte: endDate }
    }).sort({ timestamp: 1 });

    // Calculate analytics
    const analytics = {
      totalEntries: metrics.length,
      dateRange: {
        start: startDate,
        end: endDate,
        days: parseInt(days)
      },
      bloodPressure: {
        readings: metrics.filter(m => m.bloodPressure?.systolic && m.bloodPressure?.diastolic),
        average: null,
        highest: null,
        lowest: null
      },
      bloodSugar: {
        readings: metrics.filter(m => m.bloodSugar),
        average: null,
        highest: null,
        lowest: null
      },
      cholesterol: {
        ldl: { readings: [], average: null },
        hdl: { readings: [], average: null },
        total: { readings: [], average: null }
      },
      trends: []
    };

    // Blood pressure analytics
    if (analytics.bloodPressure.readings.length > 0) {
      const systolicValues = analytics.bloodPressure.readings.map(m => m.bloodPressure.systolic);
      const diastolicValues = analytics.bloodPressure.readings.map(m => m.bloodPressure.diastolic);

      analytics.bloodPressure.average = {
        systolic: Math.round(systolicValues.reduce((a, b) => a + b, 0) / systolicValues.length),
        diastolic: Math.round(diastolicValues.reduce((a, b) => a + b, 0) / diastolicValues.length)
      };

      analytics.bloodPressure.highest = {
        systolic: Math.max(...systolicValues),
        diastolic: Math.max(...diastolicValues)
      };

      analytics.bloodPressure.lowest = {
        systolic: Math.min(...systolicValues),
        diastolic: Math.min(...diastolicValues)
      };
    }

    // Blood sugar analytics
    if (analytics.bloodSugar.readings.length > 0) {
      const sugarValues = analytics.bloodSugar.readings.map(m => m.bloodSugar);
      analytics.bloodSugar.average = Math.round(sugarValues.reduce((a, b) => a + b, 0) / sugarValues.length);
      analytics.bloodSugar.highest = Math.max(...sugarValues);
      analytics.bloodSugar.lowest = Math.min(...sugarValues);
    }

    // Cholesterol analytics
    metrics.forEach(m => {
      if (m.cholesterol?.ldl) analytics.cholesterol.ldl.readings.push(m.cholesterol.ldl);
      if (m.cholesterol?.hdl) analytics.cholesterol.hdl.readings.push(m.cholesterol.hdl);
      if (m.cholesterol?.total) analytics.cholesterol.total.readings.push(m.cholesterol.total);
    });

    ['ldl', 'hdl', 'total'].forEach(type => {
      if (analytics.cholesterol[type].readings.length > 0) {
        analytics.cholesterol[type].average = Math.round(
          analytics.cholesterol[type].readings.reduce((a, b) => a + b, 0) / analytics.cholesterol[type].readings.length
        );
      }
    });

    res.status(200).json({
      status: 'success',
      message: 'Health metrics analytics retrieved successfully',
      data: analytics
    });
  } catch (error) {
    console.error('Error calculating health metrics analytics:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to calculate health metrics analytics',
      error: error.message
    });
  }
});

// @route   DELETE /api/metrics/:id
// @desc    Delete a health metrics entry
// @access  Private
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const metrics = await HealthMetrics.findOneAndDelete({ _id: id, userId });

    if (!metrics) {
      return res.status(404).json({
        status: 'error',
        message: 'Health metrics not found or unauthorized'
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Health metrics deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting health metrics:', error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to delete health metrics',
      error: error.message
    });
  }
});

module.exports = router;