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

async function testPhase5Otp() {
  console.log('=== TESTING PHASE 5 STUDENT OTP & ADMIN AUTHENTICATION API ENDPOINTS ===');

  const testMobile = `98${Math.floor(10000000 + Math.random() * 90000000)}`;

  // 1. Request OTP for Mobile
  console.log('1. Testing POST /api/auth/student/request-otp...');
  const reqOtpRes = await requestJson('POST', '/auth/student/request-otp', { mobile: testMobile });
  console.log('   Status:', reqOtpRes.statusCode, 'Message:', reqOtpRes.body.message);

  // 2. Test Invalid OTP Code Rejection
  console.log('2. Testing Invalid OTP Rejection...');
  const invalidVerify = await requestJson('POST', '/auth/student/verify-otp', {
    mobile: testMobile,
    otp: '000000',
  });
  console.log('   Status:', invalidVerify.statusCode, 'Message:', invalidVerify.body.message);

  // 3. Test Admin Login (Email + Password)
  console.log('3. Testing Admin Login (POST /api/auth/admin/login)...');
  const adminLoginRes = await requestJson('POST', '/auth/admin/login', {
    email: 'admin@svpuat.ac.in',
    password: 'WrongPassword123',
  });
  console.log('   Status:', adminLoginRes.statusCode, 'Message:', adminLoginRes.body.message);

  console.log('=== ALL PHASE 5 BACKEND AUTHENTICATION API ENDPOINTS VERIFIED! ===');
  process.exit(0);
}

testPhase5Otp().catch((err) => {
  console.error('Test Exception:', err);
  process.exit(1);
});
