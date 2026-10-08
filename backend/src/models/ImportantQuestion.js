const mongoose = require('mongoose');

const importantQuestionSchema = new mongoose.Schema(
  {
    question: {
      type: String,
      required: [true, 'Question text is required'],
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
    unitTopic: {
      type: String,
      trim: true,
      default: 'General Topic',
    },
    questionType: {
      type: String,
      enum: ['Short Answer', 'Long Answer', 'Numerical', 'Theory', 'MCQ'],
      default: 'Long Answer',
    },
    difficulty: {
      type: String,
      enum: ['Easy', 'Medium', 'Hard'],
      default: 'Medium',
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

module.exports = mongoose.model('ImportantQuestion', importantQuestionSchema);
