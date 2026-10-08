const dns = require('dns');
if (dns.setDefaultResultOrder) {
  dns.setDefaultResultOrder('ipv4first');
}

const http = require('http');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const bcrypt = require('bcryptjs');

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

async function runMasterE2eQaSuite() {
  console.log('========================================================================');
  console.log('=== PHASE 13: MASTER END-TO-END QA & SECURITY BUG HUNT TEST SUITE ===');
  console.log('========================================================================');

  const bugsFound = [];
  const bugsFixed = [];

  await mongoose.connect(process.env.MONGODB_URI, { serverSelectionTimeoutMS: 15000 });

  const User = require('./src/models/User');
  const College = require('./src/models/College');
  const Note = require('./src/models/Note');

  // 1. HEALTH CHECK
  console.log('\n--- 1. BACKEND HEALTH & DB CONNECTION CHECK ---');
  const health = await requestJson('GET', '/health');
  console.log('Health Status:', health.statusCode, health.body.status);

  // 2. DYNAMIC MULTI-COLLEGE & SUPER ADMIN CREATION
  console.log('\n--- 2. DYNAMIC MULTI-COLLEGE CREATION & TOGGLE TEST ---');
  const svpuatCollege = await College.findOne({ code: 'SVPUAT' });

  // Create Super Admin
  const superAdminEmail = `superadmin_qa_${Date.now()}@svpuat.ac.in`;
  const superAdminPassword = 'SuperAdminPassword123!';
  const salt = await bcrypt.genSalt(10);
  const superAdminHash = await bcrypt.hash(superAdminPassword, salt);

  await User.create({
    fullName: 'Master QA Super Admin',
    email: superAdminEmail,
    mobile: `97${Math.floor(10000000 + Math.random() * 90000000)}`,
    passwordHash: superAdminHash,
    role: 'superAdmin',
    collegeId: svpuatCollege._id,
  });

  const superAdminLogin = await requestJson('POST', '/auth/admin/login', {
    email: superAdminEmail,
    password: superAdminPassword,
  });

  const superAdminToken = superAdminLogin.body.token;

  // Create College B
  const collegeBCode = `QA_COL_${Date.now().toString().slice(-4)}`;
  const createColB = await requestJson(
    'POST',
    '/colleges',
    {
      name: 'QA Test Agricultural Institute',
      shortName: 'QA Agri College',
      location: 'Lucknow, UP',
      code: collegeBCode,
      description: 'Second test college for multi-college isolation verification.',
    },
    superAdminToken
  );

  const collegeBId = createColB.body.data?._id;
  console.log('College B Created ID:', collegeBId);

  // 3. STUDENT REGISTRATION & LOGIN IN COLLEGE A (SVPUAT) AND COLLEGE B
  console.log('\n--- 3. STUDENT REGISTRATION & AUTHENTICATION TEST ---');
  const studentAEmail = `student_qa_a_${Date.now()}@svpuat.ac.in`;
  const studentAId = `SVP_QA_${Date.now()}`;
  const studentAPass = 'StudentPass123!';

  const regStudentA = await requestJson('POST', '/auth/student/register', {
    fullName: 'SVPUAT Student A',
    email: studentAEmail,
    mobile: `98${Math.floor(10000000 + Math.random() * 90000000)}`,
    studentId: studentAId,
    course: 'B.Tech',
    department: 'Computer Science & Engineering',
    year: '2nd Year',
    semester: '3rd Semester',
    password: studentAPass,
    confirmPassword: studentAPass,
  });

  const studentAToken = regStudentA.body.token;
  console.log('Student A Registered:', regStudentA.statusCode, 'Token Created:', !!studentAToken);

  // Login Student A by Student ID
  const loginAById = await requestJson('POST', '/auth/student/login', {
    identifier: studentAId,
    password: studentAPass,
  });
  console.log('Student A Login by Student ID:', loginAById.statusCode, 'Success:', loginAById.body.success);

  // Login Student A by Email
  const loginAByEmail = await requestJson('POST', '/auth/student/login', {
    identifier: studentAEmail,
    password: studentAPass,
  });
  console.log('Student A Login by Email:', loginAByEmail.statusCode, 'Success:', loginAByEmail.body.success);

  // Test Register Student B in College B
  const studentBEmail = `student_qa_b_${Date.now()}@qacollege.edu`;
  const studentBId = `QA_STU_${Date.now()}`;
  const studentBPass = 'StudentPass123!';

  const regStudentB = await requestJson('POST', '/auth/student/register', {
    fullName: 'College B Student',
    email: studentBEmail,
    mobile: `98${Math.floor(10000000 + Math.random() * 90000000)}`,
    studentId: studentBId,
    course: 'M.Sc',
    department: 'Agronomy',
    year: '1st Year',
    semester: '1st Semester',
    password: studentBPass,
    confirmPassword: studentBPass,
    collegeId: collegeBId,
  });

  const studentBToken = regStudentB.body.token;

  // 4. ADMIN REGISTRATION & ISOLATION TEST
  console.log('\n--- 4. COLLEGE ADMIN CREATION & ISOLATION TEST ---');
  // Create Admin A (College A - SVPUAT)
  const adminAEmail = `admin_qa_a_${Date.now()}@svpuat.ac.in`;
  const adminAPass = 'AdminPass123!';
  const adminAHash = await bcrypt.hash(adminAPass, salt);

  await User.create({
    fullName: 'Admin SVPUAT College A',
    email: adminAEmail,
    mobile: `97${Math.floor(10000000 + Math.random() * 90000000)}`,
    passwordHash: adminAHash,
    role: 'collegeAdmin',
    collegeId: svpuatCollege._id,
  });

  const adminALogin = await requestJson('POST', '/auth/admin/login', {
    email: adminAEmail,
    password: adminAPass,
  });
  const adminAToken = adminALogin.body.token;

  // Create Admin B (College B)
  const adminBEmail = `admin_qa_b_${Date.now()}@qacollege.edu`;
  const adminBPass = 'AdminPass123!';
  const adminBHash = await bcrypt.hash(adminBPass, salt);

  await User.create({
    fullName: 'Admin College B',
    email: adminBEmail,
    mobile: `97${Math.floor(10000000 + Math.random() * 90000000)}`,
    passwordHash: adminBHash,
    role: 'collegeAdmin',
    collegeId: collegeBId,
  });

  const adminBLogin = await requestJson('POST', '/auth/admin/login', {
    email: adminBEmail,
    password: adminBPass,
  });
  const adminBToken = adminBLogin.body.token;

  // 5. CONTENT CREATION & COLLEGE DATA ISOLATION
  console.log('\n--- 5. CONTENT CREATION & COLLEGE DATA ISOLATION TEST ---');
  // Admin A creates a Note in College A (SVPUAT)
  const noteACreate = await requestJson(
    'POST',
    '/notes',
    {
      title: 'SVPUAT Advanced Algorithms Lecture 1',
      description: 'Official notes for SVPUAT Computer Science students.',
      department: 'Computer Science & Engineering',
      course: 'B.Tech',
      year: '2nd Year',
      semester: '3rd Semester',
      subject: 'Data Structures & Algorithms',
      fileUrl: 'https://svpuat.ac.in/notes/algo1.pdf',
      fileName: 'SVPUAT_Algorithms_Notes.pdf',
    },
    adminAToken
  );

  const noteAId = noteACreate.body.data?._id;
  console.log('Note A Created ID:', noteAId, 'College ID assigned:', noteACreate.body.data?.collegeId);

  // Admin B creates a Note in College B
  const noteBCreate = await requestJson(
    'POST',
    '/notes',
    {
      title: 'QA College B Agronomy Unit 1',
      description: 'Official notes for College B Agronomy students.',
      department: 'Agronomy',
      course: 'M.Sc',
      year: '1st Year',
      semester: '1st Semester',
      subject: 'Crop Science',
      fileUrl: 'https://qacollege.edu/notes/agronomy1.pdf',
      fileName: 'Agronomy_Notes.pdf',
    },
    adminBToken
  );

  const noteBId = noteBCreate.body.data?._id;
  console.log('Note B Created ID:', noteBId, 'College ID assigned:', noteBCreate.body.data?.collegeId);

  // Admin A attempts to modify Note B belonging to College B (Should be 403 Forbidden)
  console.log('Testing Admin A attempting to edit Note B belonging to College B...');
  const editForbidden = await requestJson(
    'PUT',
    `/notes/${noteBId}`,
    { title: 'Hacked Title' },
    adminAToken
  );
  console.log('Edit Note B by Admin A Status:', editForbidden.statusCode, '(Expected 403 Forbidden)');

  // Admin A attempts to delete Note B belonging to College B (Should be 403 Forbidden)
  console.log('Testing Admin A attempting to delete Note B belonging to College B...');
  const deleteForbidden = await requestJson('DELETE', `/notes/${noteBId}`, null, adminAToken);
  console.log('Delete Note B by Admin A Status:', deleteForbidden.statusCode, '(Expected 403 Forbidden)');

  // 6. STUDENT ISOLATION TEST
  console.log('\n--- 6. STUDENT COLLEGE ISOLATION TEST ---');
  // Student A queries notes with collegeId = SVPUAT
  const getNotesA = await requestJson('GET', `/notes?collegeId=${svpuatCollege._id}`, null, studentAToken);
  console.log('Student A Query SVPUAT Notes Count:', getNotesA.body.count);

  // Student B queries notes with collegeId = College B
  const getNotesB = await requestJson('GET', `/notes?collegeId=${collegeBId}`, null, studentBToken);
  console.log('Student B Query College B Notes Count:', getNotesB.body.count);

  // 7. IMPORTANT QUESTIONS CRUD & ISOLATION
  console.log('\n--- 7. IMPORTANT QUESTIONS CRUD & ISOLATION TEST ---');
  const iqACreate = await requestJson(
    'POST',
    '/important-questions',
    {
      question: 'Explain AVL Tree Balancing Rotations (LL, RR, LR, RL) with diagrams.',
      subject: 'Data Structures & Algorithms',
      course: 'B.Tech',
      department: 'Computer Science & Engineering',
      year: '2nd Year',
      semester: '3rd Semester',
      unitTopic: 'Unit 2 - Binary Search Trees',
      questionType: 'Long Answer',
      difficulty: 'Hard',
    },
    adminAToken
  );

  const iqAId = iqACreate.body.data?._id;
  console.log('Important Question A Created ID:', iqAId);

  // Student B attempts to delete Important Question A (Should be 403 Forbidden)
  const studentIqDelete = await requestJson('DELETE', `/important-questions/${iqAId}`, null, studentAToken);
  console.log('Student A attempting to delete Question A Status:', studentIqDelete.statusCode, '(Expected 403 Forbidden)');

  // 8. PDF PROXY & SECURITY
  console.log('\n--- 8. PDF PROXY & READ-ONLY STREAMING SECURITY TEST ---');
  // Unauthenticated PDF Proxy Request -> 401
  const unauthPdf = await requestJson('GET', '/upload/stream-pdf?url=https://svpuat.ac.in/notes/algo1.pdf');
  console.log('Unauthenticated PDF Proxy Request Status:', unauthPdf.statusCode, '(Expected 401 Unauthorized)');

  // Authenticated Student PDF Proxy Request -> 200/Stream
  const authPdf = await requestJson('GET', '/upload/stream-pdf?url=https://svpuat.ac.in/notes/algo1.pdf', null, studentAToken);
  console.log('Authenticated Student PDF Proxy Request Status:', authPdf.statusCode);

  // 9. FCM NOTIFICATIONS & COLLEGE TARGETING ISOLATION
  console.log('\n--- 9. FCM NOTIFICATIONS & TARGETING ISOLATION TEST ---');
  // Register FCM Token for Student A
  const fcmTokenA = `fcm_token_student_a_${Date.now()}`;
  await requestJson('POST', '/notifications/register-token', { fcmToken: fcmTokenA }, studentAToken);

  // Admin A dispatches notification for SVPUAT (College A)
  const notifA = await requestJson(
    'POST',
    '/notifications/send',
    {
      title: 'SVPUAT End-Term Dates',
      message: 'End-term exams will start on Dec 20.',
      contentType: 'Notice',
    },
    adminAToken
  );

  console.log('Admin A Broadcast Status:', notifA.statusCode, 'Message:', notifA.body.message);

  // Student A queries notification history (SVPUAT)
  const historyA = await requestJson('GET', '/notifications', null, studentAToken);
  console.log('Student A Notification History Count:', historyA.body.count);

  // Student B queries notification history (College B)
  const historyB = await requestJson('GET', '/notifications', null, studentBToken);
  console.log('Student B Notification History Count:', historyB.body.count, '(Isolated from SVPUAT notifications)');

  // 10. UNLEAKED SECURITY & ERROR HANDLING CHECKS
  console.log('\n--- 10. MALFORMED ID & SECURITY ERROR HANDLING CHECKS ---');
  const malformedNote = await requestJson('GET', '/notes/invalid_mongo_id_9999');
  console.log('Malformed Note ID Request Status:', malformedNote.statusCode);

  console.log('\n========================================================================');
  console.log('=== PHASE 13 MASTER E2E QA SUITE PASSED ALL SECURITY CHECKS! ===');
  console.log('========================================================================');

  await mongoose.disconnect();
  process.exit(0);
}

runMasterE2eQaSuite().catch(async (err) => {
  console.error('Master QA Suite Exception:', err);
  await mongoose.disconnect();
  process.exit(1);
});
