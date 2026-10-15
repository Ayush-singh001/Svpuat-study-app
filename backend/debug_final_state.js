const dotenv = require('dotenv');
const path = require('path');
dotenv.config({ path: path.join(__dirname, '.env') });

const mongoose = require('mongoose');
const connectDB = require('./src/config/database');
const Note = require('./src/models/Note');
const College = require('./src/models/College');

async function debugFinalState() {
  await connectDB();
  console.log('=== DEBUGGING LIVE DB STATE FOR BUG 2 ===');

  const cot = await College.findOne({ code: 'COT' });
  console.log(`\nCollege of Technology ID: ${cot._id}`);

  const notes = await Note.find({ collegeId: cot._id, isDeleted: { $ne: true } });
  console.log(`\nFound ${notes.length} notes in COT:`);

  notes.forEach((n) => {
    console.log(`- Note: "${n.title}" | Subject: "${n.subject}" | Dept: "${n.department}" | Year: "${n.year}" | Sem: "${n.semester}"`);
  });

  const filter = {
    collegeId: cot._id,
    course: 'B.Tech',
    department: { $regex: 'Computer Science & Engineering', $options: 'i' },
    year: '2nd Year',
    semester: '3rd Semester',
    isDeleted: { $ne: true }
  };

  const matchingNotes = await Note.find(filter);
  console.log(`\nNotes matching exact student filter: ${matchingNotes.length}`);

  const distinctSubjs = await Note.distinct('subject', filter);
  console.log(`Distinct subjects matching exact student filter:`, distinctSubjs);

  process.exit(0);
}

debugFinalState().catch((err) => {
  console.error('Error:', err);
  process.exit(1);
});
