const dotenv = require('dotenv');
const path = require('path');
dotenv.config({ path: path.join(__dirname, '.env') });

const mongoose = require('mongoose');
const connectDB = require('./src/config/database');
const College = require('./src/models/College');
const User = require('./src/models/User');

async function traceBug3() {
  await connectDB();
  console.log('=== TRACE: TARGET COLLEGE DROPDOWN SUPER ADMIN ISSUE ===');

  const users = await User.find({ email: 'ayushsinghsainthwar002@gmail.com' });
  console.log(`\nFound ${users.length} user(s) matching Super Admin email:\n`);

  for (const u of users) {
    console.log(`User ID: ${u._id}`);
    console.log(`  Role: "${u.role}"`);
    console.log(`  isActive: ${u.isActive}`);
  }

  process.exit(0);
}

traceBug3().catch((err) => {
  console.error('Trace Error:', err);
  process.exit(1);
});
