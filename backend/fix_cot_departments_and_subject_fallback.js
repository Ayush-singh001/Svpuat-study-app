const dotenv = require('dotenv');
const path = require('path');
dotenv.config({ path: path.join(__dirname, '.env') });

const mongoose = require('mongoose');
const connectDB = require('./src/config/database');
const College = require('./src/models/College');
const Note = require('./src/models/Note');

async function fixCotDepartments() {
  await connectDB();
  console.log('=== FIXING DEPARTMENTS & SUBJECT FALLBACK FOR COLLEGE OF TECHNOLOGY ===');

  // 1. Add "Computer Science & Engineering" and "BTech agriculture" to College of Technology's departments
  const cot = await College.findOne({ code: 'COT' });
  if (cot) {
    if (!cot.departments) cot.departments = [];
    const deptsToAdd = ['Computer Science & Engineering', 'BTech agriculture', 'mechanical engineering'];
    deptsToAdd.forEach((deptName) => {
      const exists = cot.departments.some((d) => d.name.toLowerCase() === deptName.toLowerCase());
      if (!exists) {
        cot.departments.push({ name: deptName, isActive: true });
      } else {
        cot.departments.forEach((d) => {
          if (d.name.toLowerCase() === deptName.toLowerCase()) d.isActive = true;
        });
      }
    });
    await cot.save();
    console.log('College of Technology Departments Updated:', cot.departments.map((d) => d.name));
  }

  // 2. Also update all active notes to ensure they belong to COT (6ac7eb6c5f31bfb677fb47df)
  const cotId = cot._id;
  const updateRes = await Note.updateMany(
    { isDeleted: { $ne: true } },
    { $set: { collegeId: cotId } }
  );
  console.log(`Updated ${updateRes.modifiedCount} active notes to College of Technology (${cotId})`);

  process.exit(0);
}

fixCotDepartments().catch((err) => {
  console.error('Fix Error:', err);
  process.exit(1);
});
