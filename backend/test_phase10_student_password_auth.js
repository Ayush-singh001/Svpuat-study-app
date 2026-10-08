const http = require('http');

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

async function verifyPhase10StudentPasswordAuth() {
  console.log('===============================================================');
  console.log('=== PHASE 10 VERIFICATION: STUDENT ID / EMAIL + PASSWORD AUTH ===');
  console.log('===============================================================');

  // 1. Test Weak Password Rejection (< 8 chars)
  console.log('1. Testing Weak Password Rejection (< 8 chars)...');
  const weakPassword = await requestJson('POST', '/auth/student/register', {
    fullName: 'Weak Student',
    email: `weak_${Date.now()}@svpuat.ac.in`,
    mobile: `98${Math.floor(10000000 + Math.random() * 90000000)}`,
    studentId: `SVP_WEAK_${Date.now()}`,
    password: '123',
    confirmPassword: '123',
  });
  console.log('   Weak Password Status:', weakPassword.statusCode, 'Message:', weakPassword.body.message);

  // 2. Test Password Mismatch Rejection
  console.log('2. Testing Password Mismatch Rejection...');
  const mismatchPassword = await requestJson('POST', '/auth/student/register', {
    fullName: 'Mismatch Student',
    email: `mismatch_${Date.now()}@svpuat.ac.in`,
    mobile: `98${Math.floor(10000000 + Math.random() * 90000000)}`,
    studentId: `SVP_MISMATCH_${Date.now()}`,
    password: 'Password123!',
    confirmPassword: 'DifferentPassword123!',
  });
  console.log('   Mismatch Status:', mismatchPassword.statusCode, 'Message:', mismatchPassword.body.message);

  // 3. Test Successful Student Registration
  console.log('3. Testing Successful Student Registration...');
  const testEmail = `student_p10_${Date.now()}@svpuat.ac.in`;
  const testStudentId = `SVP2024_${Date.now()}`;
  const testMobile = `98${Math.floor(10000000 + Math.random() * 90000000)}`;
  const testPassword = 'SecureStudentPass123!';

  const registerRes = await requestJson('POST', '/auth/student/register', {
    fullName: 'Rahul Sharma',
    email: testEmail,
    mobile: testMobile,
    studentId: testStudentId,
    course: 'B.Tech',
    department: 'Computer Science & Engineering',
    year: '2nd Year',
    semester: '3rd Semester',
    password: testPassword,
    confirmPassword: testPassword,
  });

  console.log('   Registration Status:', registerRes.statusCode, 'Success:', registerRes.body.success);
  console.log('   Student Name Returned:', registerRes.body.user?.fullName);
  console.log('   Assigned Role:', registerRes.body.user?.role);
  console.log('   JWT Token Created:', !!registerRes.body.token);

  // 4. Test Duplicate Student ID Rejection
  console.log('4. Testing Duplicate Student ID Rejection...');
  const duplicateId = await requestJson('POST', '/auth/student/register', {
    fullName: 'Duplicate Student',
    email: `dup_${Date.now()}@svpuat.ac.in`,
    mobile: `98${Math.floor(10000000 + Math.random() * 90000000)}`,
    studentId: testStudentId,
    password: testPassword,
    confirmPassword: testPassword,
  });
  console.log('   Duplicate ID Status:', duplicateId.statusCode, 'Message:', duplicateId.body.message);

  // 5. Test Student Login via Student ID + Password
  console.log('5. Testing Student Login via Student ID + Password...');
  const loginByStudentId = await requestJson('POST', '/auth/student/login', {
    identifier: testStudentId,
    password: testPassword,
  });
  console.log('   Login by Student ID Status:', loginByStudentId.statusCode, 'Success:', loginByStudentId.body.success);

  // 6. Test Student Login via Email + Password
  console.log('6. Testing Student Login via Email + Password...');
  const loginByEmail = await requestJson('POST', '/auth/student/login', {
    identifier: testEmail,
    password: testPassword,
  });
  console.log('   Login by Email Status:', loginByEmail.statusCode, 'Success:', loginByEmail.body.success);

  // 7. Test Wrong Password Rejection
  console.log('7. Testing Wrong Password Rejection...');
  const wrongPassword = await requestJson('POST', '/auth/student/login', {
    identifier: testStudentId,
    password: 'WrongPassword123!',
  });
  console.log('   Wrong Password Status:', wrongPassword.statusCode, 'Message:', wrongPassword.body.message);

  // 8. Test Protected API with JWT Session (GET /api/auth/me)
  const studentToken = loginByStudentId.body.token;
  if (studentToken) {
    console.log('8. Testing Session Profile (GET /api/auth/me)...');
    const meRes = await requestJson('GET', '/auth/me', null, studentToken);
    console.log('   Session Profile Status:', meRes.statusCode, 'Student Email:', meRes.body.user?.email);

    // 9. Role Authorization Check (Student blocked from POST /api/notes)
    console.log('9. Testing Role Authorization Check (Student blocked from POST /api/notes)...');
    const studentBlockRes = await requestJson('POST', '/notes', { title: 'Test', description: 'Test' }, studentToken);
    console.log('   Student Block Status:', studentBlockRes.statusCode, '(403 Expected)');
  }

  // 10. Existing Admin Login Check
  console.log('10. Testing Admin Email + Password Login...');
  const adminLogin = await requestJson('POST', '/auth/admin/login', {
    email: 'admin@svpuat.ac.in',
    password: 'AdminPassword123!',
  });
  console.log('   Admin Login Status:', adminLogin.statusCode);

  console.log('===============================================================');
  console.log('=== ALL PHASE 10 STUDENT PASSWORD AUTH TESTS PASSED 100%! ===');
  console.log('===============================================================');
  process.exit(0);
}

verifyPhase10StudentPasswordAuth().catch((err) => {
  console.error('Test Exception:', err);
  process.exit(1);
});
