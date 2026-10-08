const mongoose = require('mongoose');
const College = require('../models/College');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      serverSelectionTimeoutMS: 15000,
    });
    console.log(`MongoDB Connected: ${conn.connection.host}`);

    // Idempotent initialization of SVPUAT College
    await initializeSVPUATCollege();
  } catch (error) {
    console.error(`MongoDB Atlas Connection Warning: ${error.message}`);
    if (error.message.includes('whitelisted') || error.message.includes('connect')) {
      console.log(`Tip: Ensure your current IP address is whitelisted (e.g., 0.0.0.0/0) in MongoDB Atlas Network Access Settings.`);
    }
  }
};

const initializeSVPUATCollege = async () => {
  try {
    const existingCollege = await College.findOne({ code: 'SVPUAT' });
    if (!existingCollege) {
      const svpuat = await College.create({
        name: 'Sardar Vallabhbhai Patel University of Agriculture & Technology',
        shortName: 'SVPUAT Meerut',
        location: 'Meerut, Uttar Pradesh',
        state: 'Uttar Pradesh',
        code: 'SVPUAT',
        description: 'Premier Agricultural and Technological State University.',
        isActive: true,
      });
      console.log(`SVPUAT College Initialized: ${svpuat._id}`);
    } else {
      let updated = false;
      if (!existingCollege.isActive) {
        existingCollege.isActive = true;
        updated = true;
      }
      if (!existingCollege.shortName) {
        existingCollege.shortName = 'SVPUAT Meerut';
        updated = true;
      }
      if (updated) {
        await existingCollege.save();
      }
      console.log(`SVPUAT College Already Exists & Active: ${existingCollege._id}`);
    }
  } catch (err) {
    console.error(`Error initializing SVPUAT College: ${err.message}`);
  }
};

module.exports = connectDB;
