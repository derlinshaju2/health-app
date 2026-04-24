const axios = require('axios');

const ML_SERVICE_URL = process.env.ML_SERVICE_URL || 'http://localhost:8000';

const mlServiceClient = axios.create({
  baseURL: ML_SERVICE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Request interceptor
mlServiceClient.interceptors.request.use(
  (config) => {
    console.log(`ML Service Request: ${config.method.toUpperCase()} ${config.url}`);
    return config;
  },
  (error) => {
    console.error('ML Service Request Error:', error.message);
    return Promise.reject(error);
  }
);

// Response interceptor
mlServiceClient.interceptors.response.use(
  (response) => {
    console.log(`ML Service Response: ${response.status} ${response.config.url}`);
    return response;
  },
  (error) => {
    console.error('ML Service Response Error:', error.message);
    return Promise.reject(error);
  }
);

module.exports = mlServiceClient;