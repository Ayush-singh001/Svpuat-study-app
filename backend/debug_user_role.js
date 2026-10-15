const dotenv = require('dotenv');
const path = require('path');
dotenv.config({ path: path.join(__dirname, '.env') });

const mongoose = require('mongoose');
const connectDB = require('./src/config/database');
const User = require('./src/models/User');

async function checkUserRole() {
  await connectDB();
  const users = await User.find({ email: 'ayushsinghsainthwar@gmail.com' });
  console.log('Users found:', users.map(u => ({ email: u.email, role: u.role, collegeId: u.collegeId })));

  const superusers = await User.find({ email: 'ayushsinghsainthwar002@gmail.com' });
  console.log('SuperUsers found:', superusers.map(u => ({ email: u.email, role: u.role, collegeId: u.collegeId })));

  process.exit(0);
}

checkUserRole().catch(console.error);
