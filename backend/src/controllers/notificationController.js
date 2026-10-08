const mongoose = require('mongoose');
const Notification = require('../models/Notification');
const User = require('../models/User');
const College = require('../models/College');
const { admin, isConfigured } = require('../config/firebaseAdmin');

// @desc    Register FCM Device Token for Authenticated User
// @route   POST /api/notifications/register-token
// @access  Private (Authenticated Student / Admin)
const registerFcmToken = async (req, res) => {
  try {
    const { fcmToken } = req.body;

    if (!fcmToken || fcmToken.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'FCM token is required',
      });
    }

    const cleanToken = fcmToken.trim();

    // Add token to user's fcmTokens array idempotently ($addToSet)
    await User.findByIdAndUpdate(req.user._id, {
      $addToSet: { fcmTokens: cleanToken },
    });

    return res.status(200).json({
      success: true,
      message: 'FCM device token registered successfully',
    });
  } catch (error) {
    console.error('Register FCM Token Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Error registering FCM token',
    });
  }
};

// @desc    Create & Send FCM Push Notification (Enforces College Isolation)
// @route   POST /api/notifications/send
// @access  Private (College Admin / Super Admin)
const sendNotification = async (req, res) => {
  try {
    const { title, message, contentType, contentId, department } = req.body;

    if (!title || !message) {
      return res.status(400).json({
        success: false,
        message: 'Title and message are required for notification',
      });
    }

    // College Isolation: collegeId is locked to req.user.collegeId
    const collegeId = req.user.collegeId;

    // Save Notification metadata in MongoDB Atlas
    const notification = await Notification.create({
      title: title.trim(),
      message: message.trim(),
      contentType: contentType || 'General',
      contentId: contentId || '',
      department: department || 'All Departments',
      collegeId,
      sentBy: req.user._id,
    });

    // Check Firebase Admin SDK Configuration
    if (!isConfigured()) {
      return res.status(200).json({
        success: true,
        message:
          'Notification saved to MongoDB history. To dispatch live FCM push notifications, please configure backend/src/config/serviceAccountKey.json.',
        data: notification,
        fcmDispatched: false,
      });
    }

    // Query target students belonging ONLY to the same collegeId
    const targetUsers = await User.find({
      collegeId,
      fcmTokens: { $exists: true, $not: { $size: 0 } },
    });

    // Extract all tokens
    const tokens = targetUsers.flatMap((u) => u.fcmTokens);

    if (tokens.length === 0) {
      return res.status(200).json({
        success: true,
        message: 'Notification saved to history. No active student FCM tokens found for this college.',
        data: notification,
        fcmDispatched: false,
      });
    }

    // Dispatch Multicast FCM Message
    const fcmMessage = {
      notification: {
        title: title.trim(),
        body: message.trim(),
      },
      data: {
        contentType: contentType || 'General',
        contentId: contentId || '',
        collegeId: collegeId.toString(),
      },
      tokens: tokens,
    };

    const response = await admin.messaging().sendEachForMulticast(fcmMessage);

    // Clean up dead/unregistered tokens
    const tokensToRemove = [];
    response.responses.forEach((resp, idx) => {
      if (!resp.success) {
        const error = resp.error;
        if (
          error &&
          (error.code === 'messaging/invalid-registration-token' ||
            error.code === 'messaging/registration-token-not-registered')
        ) {
          tokensToRemove.push(tokens[idx]);
        }
      }
    });

    if (tokensToRemove.length > 0) {
      await User.updateMany(
        { fcmTokens: { $in: tokensToRemove } },
        { $pull: { fcmTokens: { $in: tokensToRemove } } }
      );
    }

    return res.status(200).json({
      success: true,
      message: `Notification published and dispatched via FCM to ${response.successCount} device(s).`,
      data: notification,
      fcmDispatched: true,
      successCount: response.successCount,
      failureCount: response.failureCount,
    });
  } catch (error) {
    console.error('Send Notification Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Error sending push notification',
    });
  }
};

// @desc    Get Notification History for Authenticated Student
// @route   GET /api/notifications
// @access  Private (Authenticated Users)
const getNotifications = async (req, res) => {
  try {
    const collegeId = new mongoose.Types.ObjectId(req.user.collegeId);

    const notifications = await Notification.find({ collegeId })
      .sort({ createdAt: -1 })
      .limit(50);

    return res.status(200).json({
      success: true,
      count: notifications.length,
      data: notifications,
    });
  } catch (error) {
    return res.status(200).json({
      success: true,
      count: 0,
      data: [],
      error: error.message,
    });
  }
};

module.exports = {
  registerFcmToken,
  sendNotification,
  getNotifications,
};
