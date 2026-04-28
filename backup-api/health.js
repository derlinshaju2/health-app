// Health check endpoint
export default async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');

  try {
    // Test database connection
    const mongoose = require('mongoose');
    let isConnected = false;

    if (!isConnected) {
      await mongoose.connect(process.env.MONGODB_URI, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
      });
      isConnected = true;
    }

    return res.status(200).json({
      status: 'success',
      message: 'Health Monitoring API is running on Vercel',
      database: 'Connected',
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development'
    });
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'API running but database connection failed',
      error: error.message
    });
  }
}