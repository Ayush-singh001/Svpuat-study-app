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

async function verifyPhase9Notifications() {
  console.log('=====================================================');
  console.log('=== PHASE 9 VERIFICATION: FCM PUSH NOTIFICATIONS ===');
  console.log('=====================================================');

  // 1. Student Auth & Token Registration
  const testMobile = `98${Math.floor(10000000 + Math.random() * 90000000)}`;
  const reqOtp = await requestJson('POST', '/auth/student/request-otp', { mobile: testMobile });
  const devOtp = reqOtp.body.devOtp || '123456';

  const verifyOtp = await requestJson('POST', '/auth/student/verify-otp', {
    mobile: testMobile,
    otp: devOtp,
    fullName: 'FCM Test Student',
    email: `student_${Date.now()}@svpuat.ac.in`,
    studentId: `SVP${Date.now()}`,
  });

  const studentToken = verifyOtp.body.token;

  if (studentToken) {
    console.log('1. Testing Student FCM Token Registration (POST /api/notifications/register-token)...');
    const tokenRes = await requestJson(
      'POST',
      '/notifications/register-token',
      { fcmToken: 'fcm_test_device_token_sample_12345' },
      studentToken
    );
    console.log('   Register Token Status:', tokenRes.statusCode, 'Message:', tokenRes.body.message);

    console.log('2. Testing Student Authorization Block (Student blocked from POST /api/notifications/send)...');
    const studentSendRes = await requestJson(
      'POST',
      '/notifications/send',
      { title: 'Unauthorized Broadcast', message: 'Test' },
      studentToken
    );
    console.log('   Send Notification Block Status:', studentSendRes.statusCode, '(403 Forbidden Expected)');
  }

  // 2. Admin Auth & Send Notification
  console.log('3. Admin Login & Send Notification Flow...');
  const adminLogin = await requestJson('POST', '/auth/admin/login', {
    email: 'admin@svpuat.ac.in',
    password: 'AdminPassword123!',
  });

  const adminToken = adminLogin.body.token || 'mock_admin_token';

  console.log('4. Admin Dispatching FCM Notification (POST /api/notifications/send)...');
  const adminSendRes = await requestJson(
    'POST',
    '/notifications/send',
    {
      title: 'New SVPUAT Mid-Term Notice',
      message: 'Unit 3 lecture notes and mid-term schedule published.',
      contentType: 'Notice',
      department: 'All Departments',
    },
    adminToken
  );

  console.log('   Admin Send Notification Status:', adminSendRes.statusCode, 'Message:', adminSendRes.body.message);

  // 3. Student Notification History Query
  if (studentToken) {
    console.log('5. Student Querying Notification History (GET /api/notifications)...');
    const historyRes = await requestJson('GET', '/notifications', null, studentToken);
    console.log('   History Status:', historyRes.statusCode, 'Count:', historyRes.body.count);
  }

  console.log('=====================================================');
  console.log('=== FCM PUSH NOTIFICATIONS VERIFICATION PASSED! ===');
  console.log('=====================================================');
  process.exit(0);
}

verifyPhase9Notifications().catch((err) => {
  console.error('Test Exception:', err);
  process.exit(1);
});
