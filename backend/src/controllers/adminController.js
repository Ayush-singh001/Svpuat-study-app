const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');
const User = require('../models/User');
const College = require('../models/College');

// @desc    Super Admin: Create New College Admin Account
// @route   POST /api/admin/users
// @access  Private (Super Admin Only)
const createCollegeAdmin = async (req, res) => {
  try {
    const { fullName, email, mobile, collegeId, password, confirmPassword } = req.body;

    // Validate Required Fields
    if (!fullName || !email || !collegeId || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide full name, email, college, and password',
      });
    }

    // Password Length Check
    if (password.length < 8) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 8 characters long',
      });
    }

    // Confirm Password Check
    if (confirmPassword && password !== confirmPassword) {
      return res.status(400).json({
        success: false,
        message: 'Password and Confirm Password do not match',
      });
    }

    const cleanEmail = email.toLowerCase().trim();
    const cleanMobile = mobile ? mobile.trim() : `97${Math.floor(10000000 + Math.random() * 90000000)}`;

    // Check Duplicate Email
    const existingUser = await User.findOne({ email: cleanEmail });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'An account with this email address already exists',
      });
    }

    // Validate College Existence & Active Status
    if (!mongoose.Types.ObjectId.isValid(collegeId)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid college ID selection',
      });
    }

    const college = await College.findOne({ _id: collegeId, isActive: true });
    if (!college) {
      return res.status(400).json({
        success: false,
        message: 'Selected college does not exist or is currently inactive',
      });
    }

    // Hash Password using bcrypt
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Create College Admin Account (Role forced to 'collegeAdmin')
    const adminUser = await User.create({
      fullName: fullName.trim(),
      email: cleanEmail,
      mobile: cleanMobile,
      passwordHash,
      role: 'collegeAdmin', // Forced server-side
      collegeId: college._id,
    });

    return res.status(201).json({
      success: true,
      message: `College Admin created successfully for ${college.name}`,
      data: adminUser,
    });
  } catch (error) {
    console.error('Create College Admin Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Error creating College Admin account',
    });
  }
};

module.exports = {
  createCollegeAdmin,
};
