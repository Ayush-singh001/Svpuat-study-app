const express = require('express');
const router = express.Router();
const {
  registerFcmToken,
  sendNotification,
  getNotifications,
} = require('../controllers/notificationController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

router.post('/register-token', protect, registerFcmToken);
router.post('/send', protect, authorize('collegeAdmin', 'superAdmin'), sendNotification);
router.get('/', protect, getNotifications);

module.exports = router;
