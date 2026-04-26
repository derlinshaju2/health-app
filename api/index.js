// Vercel serverless function for health check
const express = require('express');
const app = require('../health-backend/src/app.js');

module.exports = app;
