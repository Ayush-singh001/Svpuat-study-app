const express = require('express');
const router = express.Router();
const {
  registerStudent,
  loginStudent,
  adminLogin,
  forgotPassword,
  resetPassword,
  changePassword,
  getMe,
  logout,
} = require('../controllers/authController');
const { createCollegeAdmin } = require('../controllers/adminController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

// Student Auth Routes
router.post('/student/register', registerStudent);
router.post('/student/login', loginStudent);

// Admin Auth Routes
router.post('/admin/login', adminLogin);
router.post('/admin/user', protect, authorize('superAdmin'), createCollegeAdmin);

// Password Reset Routes
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

// Common Protected Routes
router.put('/change-password', protect, changePassword);
router.get('/me', protect, getMe);
router.post('/logout', protect, logout);

module.exports = router;
