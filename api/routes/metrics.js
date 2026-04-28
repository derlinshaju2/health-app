const express = require('express');
const router = express.Router();
const HealthMetrics = require('../../models/HealthMetrics');
const { authenticate } = require('../middleware/auth');

// Add health metrics
router.post('/add', authenticate, async (req, res) => {
    try {
        const { bloodPressure, bloodSugar, cholesterol, notes } = req.body;

        // Validate at least one metric is provided
        if (!bloodPressure && !bloodSugar && !cholesterol) {
            return res.status(400).json({
                status: 'error',
                message: 'Please provide at least one health metric'
            });
        }

        const metricData = {
            userId: req.user.id,
            notes: notes || ''
        };

        // Add blood pressure if provided
        if (bloodPressure) {
            metricData.bloodPressure = {
                systolic: bloodPressure.systolic,
                diastolic: bloodPressure.diastolic
            };
        }

        // Add blood sugar if provided
        if (bloodSugar !== undefined) {
            metricData.bloodSugar = bloodSugar;
        }

        // Add cholesterol if provided
        if (cholesterol) {
            metricData.cholesterol = {
                ldl: cholesterol.ldl,
                hdl: cholesterol.hdl,
                total: cholesterol.total
            };
        }

        const newMetric = new HealthMetrics(metricData);
        await newMetric.save();

        res.status(201).json({
            status: 'success',
            message: 'Health metrics added successfully',
            data: newMetric
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

// Get health metrics history
router.get('/history', authenticate, async (req, res) => {
    try {
        const { limit = 50, skip = 0 } = req.query;

        const metrics = await HealthMetrics.find({ userId: req.user.id })
            .sort({ timestamp: -1 })
            .limit(parseInt(limit))
            .skip(parseInt(skip));

        const total = await HealthMetrics.countDocuments({ userId: req.user.id });

        res.status(200).json({
            status: 'success',
            data: {
                metrics,
                total,
                count: metrics.length
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

// Get metrics analytics
router.get('/analytics', authenticate, async (req, res) => {
    try {
        const metrics = await HealthMetrics.find({ userId: req.user.id })
            .sort({ timestamp: -1 })
            .limit(100);

        // Calculate averages for each metric type
        const bpReadings = metrics.filter(m => m.bloodPressure?.systolic);
        const sugarReadings = metrics.filter(m => m.bloodSugar);
        const cholesterolReadings = metrics.filter(m => m.cholesterol?.total);

        const analytics = {
            totalReadings: metrics.length,
            bloodPressure: {
                count: bpReadings.length,
                avgSystolic: bpReadings.length > 0
                    ? Math.round(bpReadings.reduce((sum, m) => sum + m.bloodPressure.systolic, 0) / bpReadings.length)
                    : 0,
                avgDiastolic: bpReadings.length > 0
                    ? Math.round(bpReadings.reduce((sum, m) => sum + m.bloodPressure.diastolic, 0) / bpReadings.length)
                    : 0,
                latest: bpReadings.length > 0 ? bpReadings[0].bloodPressure : null
            },
            bloodSugar: {
                count: sugarReadings.length,
                average: sugarReadings.length > 0
                    ? Math.round(sugarReadings.reduce((sum, m) => sum + m.bloodSugar, 0) / sugarReadings.length)
                    : 0,
                latest: sugarReadings.length > 0 ? sugarReadings[0].bloodSugar : null
            },
            cholesterol: {
                count: cholesterolReadings.length,
                avgTotal: cholesterolReadings.length > 0
                    ? Math.round(cholesterolReadings.reduce((sum, m) => sum + m.cholesterol.total, 0) / cholesterolReadings.length)
                    : 0,
                latest: cholesterolReadings.length > 0 ? cholesterolReadings[0].cholesterol : null
            }
        };

        res.status(200).json({
            status: 'success',
            data: analytics
        });
    } catch (error) {
        console.error('Error calculating analytics:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to calculate analytics',
            error: error.message
        });
    }
});

// Delete a metric entry
router.delete('/:metricId', authenticate, async (req, res) => {
    try {
        const metric = await HealthMetrics.findOneAndDelete({
            _id: req.params.metricId,
            userId: req.user.id
        });

        if (!metric) {
            return res.status(404).json({
                status: 'error',
                message: 'Health metric not found'
            });
        }

        res.status(200).json({
            status: 'success',
            message: 'Health metric deleted successfully'
        });
    } catch (error) {
        console.error('Error deleting health metric:', error);
        res.status(500).json({
            status: 'error',
            message: 'Failed to delete health metric',
            error: error.message
        });
    }
});

module.exports = router;