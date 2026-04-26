// Vercel Serverless Function for Registration - Enhanced Error Handling
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// Connect to MongoDB
let isConnected = false;

const connectToDatabase = async () => {
  if (isConnected) {
    console.log('✅ Using existing MongoDB connection');
    return;
  }

  console.log('🔄 Connecting to MongoDB...');
  console.log('📍 MONGODB_URI exists:', !!process.env.MONGODB_URI);

  if (!process.env.MONGODB_URI) {
    throw new Error('MONGODB_URI environment variable is not set');
  }

  try {
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
    });
    isConnected = true;
    console.log('✅ MongoDB connected successfully');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
    isConnected = false;
    throw error;
  }
};

// User Schema
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  password: { type: String, required: true },
  profile: {
    name: String,
    age: Number,
    gender: String,
    height: Number,
    weight: Number
  },
  createdAt: { type: Date, default: Date.now }
});

const User = mongoose.models.User || mongoose.model('User', userSchema);

// Handler
export default async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, Authorization');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({
      status: 'error',
      message: 'Method not allowed. Please use POST.'
    });
  }

  console.log('📝 Registration request received');
  console.log('📍 Request body keys:', Object.keys(req.body));

  try {
    // Step 1: Connect to database
    console.log('Step 1: Connecting to database...');
    await connectToDatabase();
    console.log('✅ Database connection successful');

    // Step 2: Validate request body
    console.log('Step 2: Validating request...');
    const { email, password, profile } = req.body;

    if (!email || !password) {
      console.log('❌ Missing required fields');
      return res.status(400).json({
        status: 'error',
        message: 'Please provide email and password'
      });
    }

    if (!profile || !profile.name) {
      console.log('❌ Missing name in profile');
      return res.status(400).json({
        status: 'error',
        message: 'Please provide your name'
      });
    }

    console.log('✅ Request validation passed');
    console.log('📧 Email:', email);
    console.log('👤 Name:', profile.name);

    // Step 3: Check if user exists
    console.log('Step 3: Checking if user exists...');
    const existingUser = await User.findOne({ email: email.toLowerCase() });

    if (existingUser) {
      console.log('❌ User already exists:', email);
      return res.status(400).json({
        status: 'error',
        message: 'User already exists with this email address'
      });
    }

    console.log('✅ User does not exist, proceeding with registration');

    // Step 4: Hash password
    console.log('Step 4: Hashing password...');
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log('✅ Password hashed');

    // Step 5: Create user
    console.log('Step 5: Creating user...');
    const user = new User({
      email: email.toLowerCase(),
      password: hashedPassword,
      profile: {
        name: profile.name,
        age: profile.age,
        gender: profile.gender,
        height: profile.height,
        weight: profile.weight
      }
    });

    console.log('💾 Saving user to database...');
    await user.save();
    console.log('✅ User saved successfully');

    // Step 6: Generate token
    console.log('Step 6: Generating token...');
    const token = jwt.sign(
      {
        id: user._id.toString(),
        email: user.email,
        name: user.profile.name
      },
      process.env.JWT_SECRET || 'default-secret-change-this-in-production',
      { expiresIn: '30d' }
    );
    console.log('✅ Token generated');

    // Step 7: Send response
    console.log('Step 7: Sending success response...');
    return res.status(201).json({
      status: 'success',
      message: 'Registration successful! Welcome to Health Monitoring App.',
      data: {
        token,
        user: {
          email: user.email,
          name: user.profile.name,
          id: user._id.toString()
        }
      }
    });

  } catch (error) {
    console.error('❌ Registration error:', error);
    console.error('Error name:', error.name);
    console.error('Error message:', error.message);

    // Handle duplicate key error
    if (error.code === 11000) {
      console.log('❌ Duplicate key error');
      return res.status(400).json({
        status: 'error',
        message: 'User already exists with this email address'
      });
    }

    // Handle validation errors
    if (error.name === 'ValidationError') {
      console.log('❌ Validation error:', error.message);
      return res.status(400).json({
        status: 'error',
        message: 'Validation error: ' + error.message
      });
    }

    // Handle MongoDB connection errors
    if (error.name === 'MongooseServerSelectionError') {
      console.log('❌ MongoDB connection error');
      return res.status(500).json({
        status: 'error',
        message: 'Database connection failed. Please check your MongoDB configuration.',
        debug: 'Make sure MONGODB_URI is set correctly in Vercel environment variables'
      });
    }

    // Generic error
    return res.status(500).json({
      status: 'error',
      message: 'Registration failed: ' + error.message,
      debug: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
}