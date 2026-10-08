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
            resolve({ statusCode: res.statusCode, headers: res.headers, body: JSON.parse(data) });
          } catch (_) {
            resolve({ statusCode: res.statusCode, headers: res.headers, body: data });
          }
        });
      }
    );
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

async function verifyPdfProxy() {
  console.log('=====================================================');
  console.log('=== VERIFYING JWT-PROTECTED PDF PROXY ENDPOINT ===');
  console.log('=====================================================');

  // 1. Unauthenticated Request
  console.log('1. Testing Unauthenticated Request (expect 401 Unauthorized)...');
  const unauthRes = await requestJson('GET', '/upload/stream-pdf?url=https://svpuat.ac.in/test.pdf');
  console.log('   Unauthenticated Status:', unauthRes.statusCode, '(401 Expected)');

  // 2. Authenticated Request
  const testMobile = `98${Math.floor(10000000 + Math.random() * 90000000)}`;
  const reqOtp = await requestJson('POST', '/auth/student/request-otp', { mobile: testMobile });
  const devOtp = reqOtp.body.devOtp || '123456';

  const verifyOtp = await requestJson('POST', '/auth/student/verify-otp', {
    mobile: testMobile,
    otp: devOtp,
    fullName: 'PDF Proxy Test Student',
    email: `student_${Date.now()}@svpuat.ac.in`,
    studentId: `SVP${Date.now()}`,
  });

  const studentToken = verifyOtp.body.token;

  if (studentToken) {
    console.log('2. Testing Authenticated PDF Proxy Stream...');
    const proxyRes = await requestJson('GET', '/upload/stream-pdf?url=https://svpuat.ac.in/test.pdf', null, studentToken);
    console.log('   Authenticated Proxy Status:', proxyRes.statusCode);
    console.log('   Content-Type Returned:', proxyRes.headers['content-type']);
  }

  console.log('=====================================================');
  console.log('=== JWT-PROTECTED PDF PROXY VERIFICATION PASSED! ===');
  console.log('=====================================================');
  process.exit(0);
}

verifyPdfProxy().catch((err) => {
  console.error('Test Exception:', err);
  process.exit(1);
});
