// Vercel Serverless Function for Auth
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');

// Connect to MongoDB
let isConnected = false;

const connectToDatabase = async () => {
  if (isConnected) return;

  try {
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    isConnected = true;
    console.log('MongoDB connected');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    throw error;
  }
};

// User Schema
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  profile: {
    name: String,
    age: Number,
    gender: String,
    height: Number,
    weight: Number
  }
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  const bcrypt = require('bcryptjs');
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

// Compare password method
userSchema.methods.comparePassword = async function(password) {
  const bcrypt = require('bcryptjs');
  return bcrypt.compare(password, this.password);
};

const User = mongoose.models.User || mongoose.model('User', userSchema);

// Handler
export default async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader('Access-Control-Allow-Headers', 'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, Authorization');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  await connectToDatabase();

  const { method, query } = req;
  const path = query.path || '';

  // Login endpoint
  if (method === 'POST' && path === 'login') {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({
          status: 'error',
          message: 'Please provide email and password'
        });
      }

      const user = await User.findOne({ email });
      if (!user) {
        return res.status(401).json({
          status: 'error',
          message: 'Invalid credentials'
        });
      }

      const isValid = await user.comparePassword(password);
      if (!isValid) {
        return res.status(401).json({
          status: 'error',
          message: 'Invalid credentials'
        });
      }

      const token = jwt.sign(
        { id: user._id, email: user.email },
        process.env.JWT_SECRET || 'default-secret',
        { expiresIn: '30d' }
      );

      return res.status(200).json({
        status: 'success',
        message: 'Login successful',
        data: {
          token,
          user: {
            email: user.email,
            name: user.profile?.name || 'User'
          }
        }
      });
    } catch (error) {
      return res.status(500).json({
        status: 'error',
        message: error.message
      });
    }
  }

  // Register endpoint
  if (method === 'POST' && path === 'register') {
    try {
      const { email, password, profile } = req.body;

      if (!email || !password) {
        return res.status(400).json({
          status: 'error',
          message: 'Please provide email and password'
        });
      }

      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return res.status(400).json({
          status: 'error',
          message: 'User already exists'
        });
      }

      const user = new User({ email, password, profile });
      await user.save();

      const token = jwt.sign(
        { id: user._id, email: user.email },
        process.env.JWT_SECRET || 'default-secret',
        { expiresIn: '30d' }
      );

      return res.status(201).json({
        status: 'success',
        message: 'Registration successful',
        data: {
          token,
          user: {
            email: user.email,
            name: user.profile?.name || 'User'
          }
        }
      });
    } catch (error) {
      return res.status(500).json({
        status: 'error',
        message: error.message
      });
    }
  }

  // Health check
  if (method === 'GET' && path === 'health') {
    return res.status(200).json({
      status: 'success',
      message: 'Auth API is running'
    });
  }

  res.status(404).json({
    status: 'error',
    message: 'Endpoint not found'
  });
}