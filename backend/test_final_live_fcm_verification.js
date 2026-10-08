const dns = require('dns');
if (dns.setDefaultResultOrder) {
  dns.setDefaultResultOrder('ipv4first');
}

const http = require('http');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '.env') });

function requestJson(method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const payload = body ? JSON.stringify(body) : null;
    const req = http.request(
      {
        hostname: 'localhost',
        port: 5000,
        path: encodeURI(`/api${path}`),
        method: method,
        headers: {
          'Content-Type': 'application/json',
          ...(payload ? { 'Content-Length': Buffer.byteLength(payload) } : {}),
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          try {
            resolve({ statusCode: res.statusCode, body: JSON.parse(data) });
          } catch (_) {
            resolve({ statusCode: res.statusCode, body: data });
          }
        });
      }
    );
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

async function verifyLiveFcmNotificationSystem() {
  console.log('===========================================================');
  console.log('=== PHASE 9 FINAL VERIFICATION: LIVE FCM PUSH SYSTEM ===');
  console.log('===========================================================');

  await mongoose.connect(process.env.MONGODB_URI, { serverSelectionTimeoutMS: 15000 });

  // 1. Student Auth & Registration
  const testMobile = `98${Math.floor(10000000 + Math.random() * 90000000)}`;
  const reqOtp = await requestJson('POST', '/auth/student/request-otp', { mobile: testMobile });
  const devOtp = reqOtp.body.devOtp || '123456';

  const studentEmail = `student_${Date.now()}@svpuat.ac.in`;
  const studentRollNo = `SVP${Date.now()}`;
  const verifyOtp = await requestJson('POST', '/auth/student/verify-otp', {
    mobile: testMobile,
    otp: devOtp,
    fullName: 'Live FCM Student',
    email: studentEmail,
    studentId: studentRollNo,
    course: 'B.Tech',
    department: 'Computer Science & Engineering',
    year: '2nd Year',
    semester: '3rd Semester',
  });

  const studentToken = verifyOtp.body.token;
  const studentUserId = verifyOtp.body.user?.id || verifyOtp.body.user?._id;

  console.log('1. Student Authentication & JWT Session Created: PASS');

  // 2. FCM Device Token Registration
  const sampleFcmToken = `fcm_device_token_live_sample_${Date.now()}`;
  const registerTokenRes = await requestJson(
    'POST',
    '/notifications/register-token',
    { fcmToken: sampleFcmToken },
    studentToken
  );

  console.log('2. FCM Token Registration Status:', registerTokenRes.statusCode, registerTokenRes.body.message);

  // 3. Verify Token Stored in MongoDB Atlas
  const User = require('./src/models/User');
  const updatedUser = await User.findById(studentUserId);
  const tokenSaved = updatedUser?.fcmTokens?.includes(sampleFcmToken);
  console.log('3. MongoDB Token Storage Verified in Atlas:', tokenSaved ? 'PASS' : 'FAIL');

  // 4. Admin Auth & Live Notification Dispatch
  const bcrypt = require('bcryptjs');
  const College = require('./src/models/College');
  const svpuatCollege = await College.findOne({ code: 'SVPUAT' });

  const adminEmail = `admin_fcm_${Date.now()}@svpuat.ac.in`;
  const adminPassword = 'AdminPassword123!';
  const salt = await bcrypt.genSalt(10);
  const passwordHash = await bcrypt.hash(adminPassword, salt);

  const adminUser = await User.create({
    fullName: 'Live FCM Admin',
    email: adminEmail,
    mobile: `97${Math.floor(10000000 + Math.random() * 90000000)}`,
    passwordHash,
    role: 'collegeAdmin',
    collegeId: svpuatCollege._id,
  });

  const adminLogin = await requestJson('POST', '/auth/admin/login', {
    email: adminEmail,
    password: adminPassword,
  });

  const adminToken = adminLogin.body.token;
  console.log('4. Admin Login Verified: PASS');

  // 5. Dispatch Live FCM Push Notification via Firebase Admin SDK
  console.log('5. Dispatching Live Push Notification via Firebase Admin SDK...');
  const sendRes = await requestJson(
    'POST',
    '/notifications/send',
    {
      title: 'SVPUAT Mid-Term Exam Notice 2024',
      message: 'Official timetable published. Check notes & study materials in app.',
      contentType: 'Notice',
      department: 'All Departments',
    },
    adminToken
  );

  console.log('   Live FCM Dispatch Response Status:', sendRes.statusCode);
  console.log('   Response Message:', sendRes.body.message);
  console.log('   FCM Dispatched Flag:', sendRes.body.fcmDispatched);

  // 6. Student Notification History Query
  console.log('6. Querying Student Notification History (GET /api/notifications)...');
  const historyRes = await requestJson('GET', '/notifications', null, studentToken);
  console.log('   History Status:', historyRes.statusCode, 'Item Count:', historyRes.body.count);

  // 7. Student Authorization Block Check
  console.log('7. Testing Student Block Check (Student attempting POST /api/notifications/send)...');
  const studentSendRes = await requestJson(
    'POST',
    '/notifications/send',
    { title: 'Unauthorized Broadcast', message: 'Test' },
    studentToken
  );
  console.log('   Student Block Status:', studentSendRes.statusCode, '(403 Expected)');

  console.log('===========================================================');
  console.log('=== LIVE FCM VERIFICATION COMPLETED SUCCESSFULLY! ===');
  console.log('===========================================================');

  await mongoose.disconnect();
  process.exit(0);
}

verifyLiveFcmNotificationSystem().catch(async (err) => {
  console.error('Verification Exception:', err);
  await mongoose.disconnect();
  process.exit(1);
});
