const User = require('../models/User');
const { generateToken } = require('../config/jwt');

/**
 * Register a new user
 * @route POST /api/auth/register
 */
const register = async (req, res) => {
  try {
    const { email, password, profile } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        status: 'error',
        message: 'User already exists with this email'
      });
    }

    // Calculate BMI if height and weight are provided
    let userProfile = { ...profile };
    if (userProfile.height && userProfile.weight) {
      const bmi = userProfile.weight / ((userProfile.height / 100) ** 2);
      userProfile.bmi = parseFloat(bmi.toFixed(1));
    }

    // Create user
    const user = await User.create({
      email,
      password,
      profile: userProfile
    });

    // Generate token
    const token = generateToken(user._id);

    res.status(201).json({
      status: 'success',
      message: 'User registered successfully',
      data: {
        user: {
          id: user._id,
          email: user.email,
          profile: user.profile
        },
        token
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
 * Login user
 * @route POST /api/auth/login
 */
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user and include password for comparison
    const user = await User.findOne({ email }).select('+password');
    if (!user) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid email or password'
      });
    }

    // Check if user is active
    if (!user.isActive) {
      return res.status(401).json({
        status: 'error',
        message: 'Account is inactive'
      });
    }

    // Compare password
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid email or password'
      });
    }

    // Update last login
    user.lastLogin = Date.now();
    await user.save();

    // Generate token
    const token = generateToken(user._id);

    res.status(200).json({
      status: 'success',
      message: 'Login successful',
      data: {
        user: {
          id: user._id,
          email: user.email,
          profile: user.profile
        },
        token
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
 * Get current user profile
 * @route GET /api/auth/me
 */
const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.userId);

    res.status(200).json({
      status: 'success',
      data: {
        user: {
          id: user._id,
          email: user.email,
          profile: user.profile,
          createdAt: user.createdAt
        }
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
 * Update user profile
 * @route PUT /api/auth/profile
 */
const updateProfile = async (req, res) => {
  try {
    const { profile } = req.body;

    // Recalculate BMI if height or weight changed
    if (profile.height && profile.weight) {
      const bmi = profile.weight / ((profile.height / 100) ** 2);
      profile.bmi = parseFloat(bmi.toFixed(1));
    }

    const user = await User.findByIdAndUpdate(
      req.userId,
      { $set: { profile } },
      { new: true, runValidators: true }
    );

    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Profile updated successfully',
      data: {
        user: {
          id: user._id,
          email: user.email,
          profile: user.profile
        }
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
 * Logout user (client-side token removal)
 * @route POST /api/auth/logout
 */
const logout = async (req, res) => {
  try {
    // In a stateless JWT system, logout is handled client-side
    // by removing the token. This endpoint is for logging purposes.
    res.status(200).json({
      status: 'success',
      message: 'Logout successful'
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
};

module.exports = {
  register,
  login,
  getProfile,
  updateProfile,
  logout
};