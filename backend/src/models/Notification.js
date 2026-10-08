const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Notification title is required'],
      trim: true,
    },
    message: {
      type: String,
      required: [true, 'Notification message is required'],
      trim: true,
    },
    contentType: {
      type: String,
      enum: ['Notice', 'Notes', 'Question Paper', 'Syllabus', 'Important Question', 'General'],
      default: 'General',
    },
    contentId: {
      type: String,
      trim: true,
      default: '',
    },
    department: {
      type: String,
      trim: true,
      default: 'All Departments',
    },
    collegeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'College',
      required: [true, 'College ID is required for college isolation'],
    },
    sentBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Notification', notificationSchema);
