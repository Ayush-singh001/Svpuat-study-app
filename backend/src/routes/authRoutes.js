const express = require('express');
const router = express.Router();
const {
  registerStudent,
  loginStudent,
  adminLogin,
  getMe,
  logout,
} = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

// Student Auth Routes
router.post('/student/register', registerStudent);
router.post('/student/login', loginStudent);

// Admin Auth Routes
router.post('/admin/login', adminLogin);

// Common Protected Routes
router.get('/me', protect, getMe);
router.post('/logout', protect, logout);

module.exports = router;
