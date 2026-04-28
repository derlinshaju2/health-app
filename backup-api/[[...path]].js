// Main Vercel serverless function for all API routes
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

// Import middleware
const { connectDatabase } = require('./src/config/database');

// Import routes
const authRoutes = require('./src/routes/auth');
const healthRoutes = require('./src/routes/health');
const predictionRoutes = require('./src/routes/predictions');
const dietRoutes = require('./src/routes/diet');
const yogaRoutes = require('./src/routes/yoga');
const notificationRoutes = require('./src/routes/notifications');
const metricsRoutes = require('./src/routes/metrics');

// Create Express app
const app = express();

// Middleware
app.use(cors({
  origin: '*',
  credentials: true
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'Health Monitoring API is running on Vercel',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/health', healthRoutes);
app.use('/api/predictions', predictionRoutes);
app.use('/api/diet', dietRoutes);
app.use('/api/yoga', yogaRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/metrics', metricsRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Route not found'
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({
    status: 'error',
    message: err.message || 'Internal server error'
  });
});

// Export for Vercel
module.exports = async (req, res) => {
  // Connect to database
  try {
    await connectDatabase();
  } catch (error) {
    console.error('Database connection error:', error);
  }

  // Handle the request
  return app(req, res);
};