const mongoose = require('mongoose');

const collegeSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'College name is required'],
      trim: true,
    },
    shortName: {
      type: String,
      trim: true,
      default: '',
    },
    location: {
      type: String,
      required: [true, 'College location is required'],
      trim: true,
    },
    state: {
      type: String,
      trim: true,
      default: 'Uttar Pradesh',
    },
    code: {
      type: String,
      required: [true, 'College code is required'],
      unique: true,
      trim: true,
      uppercase: true,
    },
    logoUrl: {
      type: String,
      trim: true,
      default: '',
    },
    description: {
      type: String,
      trim: true,
      default: '',
    },
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('College', collegeSchema);
