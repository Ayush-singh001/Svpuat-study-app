const dotenv = require('dotenv');
const path = require('path');
dotenv.config({ path: path.join(__dirname, '.env') });

const http = require('http');

function requestJson(method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const payload = body ? JSON.stringify(body) : null;
    const req = http.request(
      {
        hostname: 'localhost',
        port: 5000,
        path: path,
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

async function checkAdminLogin() {
  const adminLogin = await requestJson('POST', '/api/auth/admin/login', {
    email: 'ayushsinghsainthwar002@gmail.com',
    password: 'Riya@2007',
  });
  console.log('Super Admin User Data:', JSON.stringify(adminLogin.body.user, null, 2));

  const collegeAdminLogin = await requestJson('POST', '/api/auth/admin/login', {
    email: 'ayushsinghsainthwar@gmail.com',
    password: 'Riya@2007',
  });
  console.log('College Admin User Data:', JSON.stringify(collegeAdminLogin.body.user, null, 2));
}

checkAdminLogin().catch(console.error);
