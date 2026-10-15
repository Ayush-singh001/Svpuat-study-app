const dotenv = require('dotenv');
const path = require('path');
dotenv.config({ path: path.join(__dirname, '.env') });

const mongoose = require('mongoose');
const connectDB = require('./src/config/database');
const User = require('./src/models/User');
const College = require('./src/models/College');

async function checkUsers() {
  await connectDB();
  const users = await User.find({ role: { $in: ['superAdmin', 'collegeAdmin'] } }).populate('collegeId', 'name code');
  console.log('=== ADMIN USERS IN DATABASE ===');
  users.forEach(u => {
    console.log(`Email: ${u.email}`);
    console.log(`Role: ${u.role}`);
    console.log(`College: ${u.collegeId ? u.collegeId.name : 'None'} (${u.collegeId ? u.collegeId._id : 'N/A'})`);
    console.log('---');
  });
  process.exit(0);
}

checkUsers().catch(console.error);
