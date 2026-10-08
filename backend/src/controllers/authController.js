const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
const User = require('../models/User');
const College = require('../models/College');
const EmailService = require('../services/emailService');

// Helper to generate JWT Token
const generateToken = (userId, role) => {
  return jwt.sign({ id: userId, role }, process.env.JWT_SECRET, {
    expiresIn: '30d',
  });
};

const checkDbConnection = (res) => {
  if (mongoose.connection.readyState !== 1) {
    res.status(503).json({
      success: false,
      message: 'Database not connected. Please whitelist current IP in MongoDB Atlas Network Access Settings (0.0.0.0/0).',
    });
    return false;
  }
  return true;
};

// @desc    Register New SVPUAT Student with Password
// @route   POST /api/auth/student/register
// @access  Public
const registerStudent = async (req, res) => {
  try {
    if (!checkDbConnection(res)) return;

    const {
      fullName,
      email,
      mobile,
      studentId,
      department,
      course,
      year,
      semester,
      password,
      confirmPassword,
    } = req.body;

    // Required Fields Validation
    if (!fullName || !email || !mobile || !studentId || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide full name, email, mobile, student ID, and password',
      });
    }

    // Password Length Check (min 8 chars)
    if (password.length < 8) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 8 characters long',
      });
    }

    // Confirm Password Mismatch Check
    if (confirmPassword && password !== confirmPassword) {
      return res.status(400).json({
        success: false,
        message: 'Password and Confirm Password do not match',
      });
    }

    const cleanEmail = email.toLowerCase().trim();
    const cleanMobile = mobile.trim();
    const cleanStudentId = studentId.trim();

    // Check duplicate email
    const emailExists = await User.findOne({ email: cleanEmail });
    if (emailExists) {
      return res.status(400).json({
        success: false,
        message: 'An account with this email address already exists',
      });
    }

    // Check duplicate mobile
    const mobileExists = await User.findOne({ mobile: cleanMobile });
    if (mobileExists) {
      return res.status(400).json({
        success: false,
        message: 'An account with this mobile number already exists',
      });
    }

    // Check duplicate Student ID
    const idExists = await User.findOne({ studentId: cleanStudentId });
    if (idExists) {
      return res.status(400).json({
        success: false,
        message: 'An account with this Student ID / Roll No already exists',
      });
    }

    let targetCollege = null;
    if (req.body.collegeId && mongoose.Types.ObjectId.isValid(req.body.collegeId)) {
      targetCollege = await College.findOne({ _id: req.body.collegeId, isActive: true });
    }
    if (!targetCollege) {
      targetCollege = await College.findOne({ code: 'SVPUAT' });
    }

    // Hash Password securely using bcrypt
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Create Student Account (Role locked to student)
    const user = await User.create({
      fullName: fullName.trim(),
      email: cleanEmail,
      mobile: cleanMobile,
      studentId: cleanStudentId,
      passwordHash,
      department: department || 'Computer Science & Engineering',
      course: course || 'B.Tech',
      year: year || '2nd Year',
      semester: semester || '3rd Semester',
      role: 'student', // Locked to student
      collegeId: targetCollege._id,
    });

    const token = generateToken(user._id, user.role);

    return res.status(201).json({
      success: true,
      message: 'Student account created successfully',
      token,
      user,
    });
  } catch (error) {
    console.error('Student Registration Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Error creating student account',
    });
  }
};

// @desc    Student Login using Student ID OR Email + Password
// @route   POST /api/auth/student/login
// @access  Public
const loginStudent = async (req, res) => {
  try {
    if (!checkDbConnection(res)) return;

    const { identifier, password } = req.body;

    if (!identifier || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please enter Student ID / Email and password',
      });
    }

    const cleanIdentifier = identifier.trim();

    // Query user by email OR studentId
    const user = await User.findOne({
      $or: [
        { email: cleanIdentifier.toLowerCase() },
        { studentId: cleanIdentifier },
      ],
      role: 'student',
    }).select('+passwordHash');

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid Student ID / Email or password',
      });
    }

    // Handle legacy accounts created without passwordHash during OTP testing
    if (!user.passwordHash) {
      return res.status(400).json({
        success: false,
        message: 'Account requires password setup. Please contact SVPUAT Admin or register a new account.',
      });
    }

    // Compare Password Hash
    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid Student ID / Email or password',
      });
    }

    const token = generateToken(user._id, user.role);

    return res.status(200).json({
      success: true,
      message: 'Student login successful',
      token,
      user,
    });
  } catch (error) {
    console.error('Student Login Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Error logging in student',
    });
  }
};

// @desc    Admin Login (Email + Password for College Admin & Super Admin)
// @route   POST /api/auth/admin/login
// @access  Public
const adminLogin = async (req, res) => {
  try {
    if (!checkDbConnection(res)) return;

    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password',
      });
    }

    const user = await User.findOne({
      email: email.toLowerCase(),
      role: { $in: ['collegeAdmin', 'superAdmin'] },
    }).select('+passwordHash');

    if (!user || !user.passwordHash) {
      return res.status(401).json({
        success: false,
        message: 'Invalid admin credentials',
      });
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid admin credentials',
      });
    }

    const token = generateToken(user._id, user.role);

    return res.status(200).json({
      success: true,
      message: 'Admin login successful',
      token,
      user,
    });
  } catch (error) {
    console.error('Admin Login Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error during admin login',
    });
  }
};

// @desc    Request Password Reset Link via Email (Generic response to prevent email enumeration)
// @route   POST /api/auth/forgot-password
// @access  Public
const forgotPassword = async (req, res) => {
  try {
    if (!checkDbConnection(res)) return;

    const { email } = req.body;

    const genericMessage = 'If the account exists, a password reset link has been sent to the registered email.';

    if (!email || !email.trim()) {
      return res.status(200).json({
        success: true,
        message: genericMessage,
      });
    }

    const cleanEmail = email.toLowerCase().trim();
    const user = await User.findOne({ email: cleanEmail });

    if (!user) {
      return res.status(200).json({
        success: true,
        message: genericMessage,
      });
    }

    // Generate secure random 32-byte token
    const rawToken = crypto.randomBytes(32).toString('hex');

    // Hash token before saving to DB
    const hashedToken = crypto.createHash('sha256').update(rawToken).digest('hex');

    user.resetPasswordToken = hashedToken;
    user.resetPasswordExpires = new Date(Date.now() + 30 * 60 * 1000); // 30 minutes expiration
    await user.save();

    // Construct reset link containing raw token
    const baseUrl = process.env.RESET_PASSWORD_BASE_URL || 'https://svpuat-study-app.onrender.com';
    const resetLink = `${baseUrl}/reset-password?token=${rawToken}`;

    // Dispatch email
    await EmailService.sendPasswordResetEmail(user.email, resetLink);

    const responsePayload = {
      success: true,
      message: genericMessage,
    };

    // Include devResetToken in DEVELOPMENT mode
    if ((process.env.EMAIL_PROVIDER || 'CONSOLE').toUpperCase() === 'CONSOLE') {
      responsePayload.devResetToken = rawToken;
    }

    return res.status(200).json(responsePayload);
  } catch (error) {
    console.error('Forgot Password Error:', error);
    return res.status(200).json({
      success: true,
      message: 'If the account exists, a password reset link has been sent to the registered email.',
    });
  }
};

// @desc    Reset Password using Token
// @route   POST /api/auth/reset-password
// @access  Public
const resetPassword = async (req, res) => {
  try {
    if (!checkDbConnection(res)) return;

    const { token, password, confirmPassword } = req.body;

    if (!token) {
      return res.status(400).json({
        success: false,
        message: 'Password reset token is required',
      });
    }

    if (!password || password.length < 8) {
      return res.status(400).json({
        success: false,
        message: 'New password must be at least 8 characters long',
      });
    }

    if (confirmPassword && password !== confirmPassword) {
      return res.status(400).json({
        success: false,
        message: 'Password and Confirm Password do not match',
      });
    }

    // Hash supplied token to match DB entry
    const hashedToken = crypto.createHash('sha256').update(token.trim()).digest('hex');

    // Find user with valid unexpired token
    const user = await User.findOne({
      resetPasswordToken: hashedToken,
      resetPasswordExpires: { $gt: new Date() },
    }).select('+passwordHash +resetPasswordToken +resetPasswordExpires');

    if (!user) {
      return res.status(400).json({
        success: false,
        message: 'Password reset token is invalid, expired, or has already been used.',
      });
    }

    // Hash new password securely
    const salt = await bcrypt.genSalt(10);
    user.passwordHash = await bcrypt.hash(password, salt);

    // Invalidate/clear reset token after one-time use
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;

    await user.save();

    return res.status(200).json({
      success: true,
      message: 'Password reset successfully. You can now log in.',
    });
  } catch (error) {
    console.error('Reset Password Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Error resetting password',
    });
  }
};

// @desc    Change Password for Authenticated User (Admin / Student)
// @route   PUT /api/auth/change-password
// @access  Private
const changePassword = async (req, res) => {
  try {
    if (!checkDbConnection(res)) return;

    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Please provide current password and new password',
      });
    }

    if (newPassword.length < 8) {
      return res.status(400).json({
        success: false,
        message: 'New password must be at least 8 characters long',
      });
    }

    // Fetch authenticated user with passwordHash
    const user = await User.findById(req.user._id).select('+passwordHash');
    if (!user || !user.passwordHash) {
      return res.status(404).json({
        success: false,
        message: 'User account or password record not found',
      });
    }

    // Verify Current Password using bcrypt
    const isMatch = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: 'Current password is incorrect',
      });
    }

    // Hash new password securely
    const salt = await bcrypt.genSalt(10);
    user.passwordHash = await bcrypt.hash(newPassword, salt);
    await user.save();

    return res.status(200).json({
      success: true,
      message: 'Password updated successfully',
    });
  } catch (error) {
    console.error('Change Password Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error changing password',
    });
  }
};

// @desc    Get Current Authenticated User Profile
// @route   GET /api/auth/me
// @access  Private
const getMe = async (req, res) => {
  try {
    if (!checkDbConnection(res)) return;

    return res.status(200).json({
      success: true,
      user: req.user,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error fetching profile',
    });
  }
};

// @desc    Logout User
// @route   POST /api/auth/logout
// @access  Private
const logout = async (req, res) => {
  return res.status(200).json({
    success: true,
    message: 'Logged out successfully',
  });
};

module.exports = {
  registerStudent,
  loginStudent,
  adminLogin,
  forgotPassword,
  resetPassword,
  changePassword,
  getMe,
  logout,
};
