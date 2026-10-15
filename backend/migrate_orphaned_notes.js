const dotenv = require('dotenv');
const path = require('path');
dotenv.config({ path: path.join(__dirname, '.env') });

const mongoose = require('mongoose');
const connectDB = require('./src/config/database');
const Note = require('./src/models/Note');
const College = require('./src/models/College');
const User = require('./src/models/User');

async function migrateNotes() {
  await connectDB();
  console.log('=== MIGRATING ORPHANED NOTES TO COLLEGE OF TECHNOLOGY ===');

  const svpuatId = '6ac652c82edf58da8c76243f';

  // Find College of Technology
  const cot = await College.findOne({ code: 'COT' });
  if (!cot) {
    console.error('College of Technology not found.');
    process.exit(1);
  }

  const cotId = cot._id;
  console.log(`Target College: College of Technology (${cotId})`);

  // Update Notes
  const updateNotesResult = await Note.updateMany(
    { collegeId: svpuatId },
    { $set: { collegeId: cotId } }
  );
  console.log(`Migrated ${updateNotesResult.modifiedCount} notes from SVPUAT to College of Technology.`);

  // Update Users (Admins assigned to SVPUAT need to be assigned to COT to see/manage them)
  const updateUsersResult = await User.updateMany(
    { collegeId: svpuatId },
    { $set: { collegeId: cotId } }
  );
  console.log(`Migrated ${updateUsersResult.modifiedCount} users from SVPUAT to College of Technology.`);

  process.exit(0);
}

migrateNotes().catch((err) => {
  console.error('Migration Error:', err);
  process.exit(1);
});
