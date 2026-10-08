const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: [true, 'Full name is required'],
      trim: true,
    },
    email: {
      type: String,
      required: [true, 'Email is required'],
      unique: true,
      lowercase: true,
      trim: true,
    },
    mobile: {
      type: String,
      required: [true, 'Mobile number is required'],
      unique: true,
      trim: true,
    },
    passwordHash: {
      type: String,
      select: false, // Excluded by default
    },
    studentId: {
      type: String,
      unique: true,
      sparse: true,
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
    role: {
      type: String,
      enum: ['student', 'collegeAdmin', 'superAdmin'],
      default: 'student',
    },
    fcmTokens: [
      {
        type: String,
        trim: true,
      },
    ],
    collegeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'College',
      required: [true, 'College reference is required'],
    },
  },
  {
    timestamps: true,
  }
);

userSchema.set('toJSON', {
  transform: (doc, ret) => {
    delete ret.passwordHash;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('User', userSchema);
