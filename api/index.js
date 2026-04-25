// Vercel serverless function entry point
// This file redirects to the main Express app

const app = require('../health-backend/src/app.js');

module.exports = app;