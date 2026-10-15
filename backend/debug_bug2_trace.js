const dotenv = require('dotenv');
const path = require('path');
dotenv.config({ path: path.join(__dirname, '.env') });

const mongoose = require('mongoose');
const connectDB = require('./src/config/database');
const Note = require('./src/models/Note');
const College = require('./src/models/College');

async function traceBug2() {
  await connectDB();
  const notes = await Note.find({ isDeleted: { $ne: true } }).populate('collegeId', 'name code isActive');
  console.log(`\nFound ${notes.length} non-deleted notes in MongoDB Atlas:\n`);

  for (const n of notes) {
    const colId = n.collegeId ? (n.collegeId._id ? n.collegeId._id.toString() : n.collegeId.toString()) : 'NONE';
    const colName = n.collegeId ? (n.collegeId.name || 'UNKNOWN') : 'NONE';

    console.log(`Note ID: ${n._id.toString()}`);
    console.log(`  Title: "${n.title}"`);
    console.log(`  Subject: "${n.subject}"`);
    console.log(`  College: "${colName}" (ID: ${colId})`);
    console.log(`  Course: "${n.course}"`);
    console.log(`  Department: "${n.department}"`);
    console.log(`  Year: "${n.year}"`);
    console.log(`  Semester: "${n.semester}"`);
  }

  process.exit(0);
}

traceBug2().catch((err) => {
  console.error('Trace Error:', err);
  process.exit(1);
});
