const mongoose = require('mongoose');
const College = require('../models/College');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      serverSelectionTimeoutMS: 15000,
    });
    console.log(`MongoDB Connected: ${conn.connection.host}`);

    // Idempotent initialization of SVPUAT Constituent Colleges & Default Subjects
    await initializeSVPUATCollege();
    await initializeDefaultSubjects();
  } catch (error) {
    console.error(`MongoDB Atlas Connection Warning: ${error.message}`);
    if (error.message.includes('whitelisted') || error.message.includes('connect')) {
      console.log(`Tip: Ensure your current IP address is whitelisted (e.g., 0.0.0.0/0) in MongoDB Atlas Network Access Settings.`);
    }
  }
};

const initializeSVPUATCollege = async () => {
  try {
    const svpuatColleges = [
      {
        name: 'Sardar Vallabhbhai Patel University of Agriculture & Technology',
        shortName: 'SVPUAT Meerut',
        location: 'Meerut, Uttar Pradesh',
        state: 'Uttar Pradesh',
        code: 'SVPUAT',
        description: 'Premier Agricultural and Technological State University.',
        isActive: true,
      },
      {
        name: 'College of Agriculture',
        shortName: 'COA Meerut',
        location: 'Meerut, Uttar Pradesh',
        state: 'Uttar Pradesh',
        code: 'COA',
        description: 'Constituent College of Agriculture, SVPUAT Meerut.',
        isActive: true,
      },
      {
        name: 'College of Technology',
        shortName: 'COT Meerut',
        location: 'Meerut, Uttar Pradesh',
        state: 'Uttar Pradesh',
        code: 'COT',
        description: 'Constituent College of Technology, SVPUAT Meerut.',
        isActive: true,
      },
      {
        name: 'College of Veterinary & Animal Sciences',
        shortName: 'COVAS Meerut',
        location: 'Meerut, Uttar Pradesh',
        state: 'Uttar Pradesh',
        code: 'COVAS',
        description: 'Constituent College of Veterinary & Animal Sciences, SVPUAT Meerut.',
        isActive: true,
      },
      {
        name: 'College of Horticulture',
        shortName: 'COH Meerut',
        location: 'Meerut, Uttar Pradesh',
        state: 'Uttar Pradesh',
        code: 'COH',
        description: 'Constituent College of Horticulture, SVPUAT Meerut.',
        isActive: true,
      },
      {
        name: 'College of Biotechnology',
        shortName: 'COBT Meerut',
        location: 'Meerut, Uttar Pradesh',
        state: 'Uttar Pradesh',
        code: 'COBT',
        description: 'Constituent College of Biotechnology, SVPUAT Meerut.',
        isActive: true,
      },
      {
        name: 'College of Sugarcane Science & Technology',
        shortName: 'COSST Meerut',
        location: 'Meerut, Uttar Pradesh',
        state: 'Uttar Pradesh',
        code: 'COSST',
        description: 'Constituent College of Sugarcane Science & Technology, SVPUAT Meerut.',
        isActive: true,
      },
    ];

    for (const item of svpuatColleges) {
      const existing = await College.findOne({ code: item.code });
      if (!existing) {
        await College.create(item);
      } else if (!existing.isActive) {
        existing.isActive = true;
        await existing.save();
      }
    }
    console.log('SVPUAT Constituent Colleges Initialized & Active.');
  } catch (err) {
    console.error(`Error initializing SVPUAT Colleges: ${err.message}`);
  }
};

const initializeDefaultSubjects = async () => {
  try {
    const svpuat = await College.findOne({ code: 'SVPUAT' });
    if (!svpuat) return;

    const defaultSubjects = [
      { name: 'Data Structures & Algorithms', code: 'CS301', course: 'B.Tech', department: 'Computer Science & Engineering', year: '2nd Year', semester: '3rd Semester' },
      { name: 'Database Management Systems', code: 'CS302', course: 'B.Tech', department: 'Computer Science & Engineering', year: '2nd Year', semester: '3rd Semester' },
      { name: 'Discrete Mathematics', code: 'CS303', course: 'B.Tech', department: 'Computer Science & Engineering', year: '2nd Year', semester: '3rd Semester' },
      { name: 'Digital Logic Design', code: 'CS304', course: 'B.Tech', department: 'Computer Science & Engineering', year: '2nd Year', semester: '3rd Semester' },
      { name: 'Object Oriented Programming in C++', code: 'CS305', course: 'B.Tech', department: 'Computer Science & Engineering', year: '2nd Year', semester: '3rd Semester' },
      { name: 'Operating Systems', code: 'CS401', course: 'B.Tech', department: 'Computer Science & Engineering', year: '2nd Year', semester: '4th Semester' },
      { name: 'Computer Networks', code: 'CS402', course: 'B.Tech', department: 'Computer Science & Engineering', year: '2nd Year', semester: '4th Semester' },
      { name: 'Crop Production Technology', code: 'AGR301', course: 'B.Sc (Hons) Agriculture', department: 'Agronomy', year: '2nd Year', semester: '3rd Semester' },
      { name: 'Cell Biology & Genetics', code: 'BT301', course: 'B.Tech Biotechnology', department: 'Biotechnology', year: '2nd Year', semester: '3rd Semester' },
    ];

    const Subject = require('../models/Subject');
    for (const item of defaultSubjects) {
      const existing = await Subject.findOne({
        name: item.name,
        collegeId: svpuat._id,
        course: item.course,
        semester: item.semester,
        isDeleted: { $ne: true },
      });
      if (!existing) {
        await Subject.create({
          ...item,
          collegeId: svpuat._id,
          isDeleted: false,
        });
      }
    }
    console.log('SVPUAT Default Subjects Initialized & Persisted in MongoDB.');
  } catch (err) {
    console.error(`Error initializing SVPUAT Subjects: ${err.message}`);
  }
};

module.exports = connectDB;
