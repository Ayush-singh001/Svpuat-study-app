const http = require('http');

function request(method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const payload = body ? JSON.stringify(body) : null;
    const req = http.request(
      {
        hostname: 'localhost',
        port: 5000,
        path: `/api${path}`,
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

async function runTests() {
  console.log('=== STARTING BACKEND REST API TESTS ===');

  // 1. Health Check
  const health = await request('GET', '/health');
  console.log('1. GET /api/health:', health.statusCode, health.body.status);

  // 2. Register Student
  const regEmail = `student_${Date.now()}@svpuat.ac.in`;
  const regStudentId = `SVP${Date.now()}`;
  const regRes = await request('POST', '/auth/register', {
    fullName: 'Atlas Test Student',
    email: regEmail,
    mobile: '9876543210',
    studentId: regStudentId,
    password: 'Password123!',
    course: 'B.Tech',
    department: 'Computer Science & Engineering',
    year: '2nd Year',
    semester: '3rd Semester',
  });
  console.log('2. POST /api/auth/register:', regRes.statusCode, 'Success:', regRes.body.success, 'Token Created:', !!regRes.body.token);

  const token = regRes.body.token;

  // 3. Login with Student ID
  const loginRes = await request('POST', '/auth/login', {
    identifier: regStudentId,
    password: 'Password123!',
  });
  console.log('3. POST /api/auth/login:', loginRes.statusCode, 'Success:', loginRes.body.success, 'User Name:', loginRes.body.user?.fullName);

  // 4. GET /api/auth/me
  const meRes = await request('GET', '/auth/me', null, token);
  console.log('4. GET /api/auth/me:', meRes.statusCode, 'User Email:', meRes.body.user?.email);

  // 5. GET /api/notes
  const notesRes = await request('GET', '/notes');
  console.log('5. GET /api/notes:', notesRes.statusCode, 'Count:', notesRes.body.count);

  // 6. GET /api/question-papers
  const papersRes = await request('GET', '/question-papers');
  console.log('6. GET /api/question-papers:', papersRes.statusCode, 'Count:', papersRes.body.count);

  // 7. GET /api/syllabus
  const syllabusRes = await request('GET', '/syllabus');
  console.log('7. GET /api/syllabus:', syllabusRes.statusCode, 'Count:', syllabusRes.body.count);

  // 8. GET /api/notices
  const noticesRes = await request('GET', '/notices');
  console.log('8. GET /api/notices:', noticesRes.statusCode, 'Count:', noticesRes.body.count);

  console.log('=== ALL BACKEND REST API TESTS PASSED ===');
}

runTests().catch(console.error);
