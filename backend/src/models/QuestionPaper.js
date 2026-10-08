const mongoose = require('mongoose');

const questionPaperSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Question paper title is required'],
      trim: true,
    },
    subject: {
      type: String,
      required: [true, 'Subject is required'],
      trim: true,
    },
    department: {
      type: String,
      trim: true,
      default: '',
    },
    course: {
      type: String,
      trim: true,
      default: '',
    },
    year: {
      type: String,
      trim: true,
      default: '',
    },
    semester: {
      type: String,
      trim: true,
      default: '',
    },
    examType: {
      type: String,
      trim: true,
      default: 'Mid-Term Exam',
    },
    paperYear: {
      type: String,
      trim: true,
      default: '',
    },
    fileUrl: {
      type: String,
      trim: true,
      default: '',
    },
    publicId: {
      type: String,
      trim: true,
      default: '',
    },
    fileName: {
      type: String,
      trim: true,
      default: '',
    },
    fileSize: {
      type: String,
      trim: true,
      default: '',
    },
    collegeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'College',
      required: [true, 'College ID is required'],
    },
    uploadedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('QuestionPaper', questionPaperSchema);
