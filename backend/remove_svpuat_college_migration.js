const dotenv = require('dotenv');
const path = require('path');
dotenv.config({ path: path.join(__dirname, '.env') });

const mongoose = require('mongoose');
const connectDB = require('./src/config/database');
const College = require('./src/models/College');
const Note = require('./src/models/Note');
const User = require('./src/models/User');

async function migrateSvpuatCollege() {
  await connectDB();
  console.log('=== MIGRATION: REMOVE SVPUAT FROM COLLEGE SELECTION LISTS ===');

  // 1. Find SVPUAT Record
  const svpuat = await College.findOne({ code: 'SVPUAT' });
  if (svpuat) {
    console.log(`Found SVPUAT University Record ID: ${svpuat._id.toString()}`);

    // Check existing references in Users and Notes
    const userCount = await User.countDocuments({ collegeId: svpuat._id });
    const noteCount = await Note.countDocuments({ collegeId: svpuat._id, isDeleted: { $ne: true } });
    console.log(`  Existing References -> Users: ${userCount} | Active Notes: ${noteCount}`);

    // Soft-deactivate SVPUAT so it NEVER appears in active GET /api/colleges dropdown queries
    svpuat.isActive = false;
    await svpuat.save();
    console.log('  SVPUAT record set to isActive: false. Removed from constituent college lists.');
  } else {
    console.log('SVPUAT college record not found in database.');
  }

  // 2. Query Active Colleges (Constituent Colleges Only)
  const activeColleges = await College.find({ isActive: true, code: { $ne: 'SVPUAT' } }).sort({ name: 1 });
  console.log(`\nRemaining Constituent Colleges in Database (${activeColleges.length} total):`);
  activeColleges.forEach((c) => {
    console.log(`- ID: ${c._id.toString()} | Name: "${c.name}" | Code: "${c.code}"`);
  });

  process.exit(0);
}

migrateSvpuatCollege().catch((err) => {
  console.error('Migration Error:', err);
  process.exit(1);
});
