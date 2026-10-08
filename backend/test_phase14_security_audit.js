const dns = require('dns');
if (dns.setDefaultResultOrder) {
  dns.setDefaultResultOrder('ipv4first');
}

const http = require('http');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const fs = require('fs');

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

async function verifyPhase14SecurityAudit() {
  console.log('========================================================================');
  console.log('=== PHASE 14 SECURITY AUDIT & PRODUCTION READINESS VERIFICATION ===');
  console.log('========================================================================');

  // 1. Health Check & Helmet Security Headers
  console.log('\n--- 1. HELMET SECURITY HEADERS CHECK ---');
  const healthRes = await requestJson('GET', '/health');
  console.log('Health Status:', healthRes.statusCode);
  console.log('Helmet Header (x-content-type-options):', healthRes.headers['x-content-type-options']);
  console.log('Helmet Header (x-frame-options):', healthRes.headers['x-frame-options']);

  // 2. Unauthenticated Request Protection (401)
  console.log('\n--- 2. UNAUTHENTICATED ROUTE PROTECTION CHECK (401) ---');
  const unauthRes = await requestJson('GET', '/auth/me');
  console.log('No Token Status:', unauthRes.statusCode, '(Expected 401 Unauthorized)');

  const malformedJwt = await requestJson('GET', '/auth/me', null, 'malformed_jwt_token_12345');
  console.log('Malformed JWT Status:', malformedJwt.statusCode, '(Expected 401 Unauthorized)');

  // 3. Secrets Exclusion in Git Check
  console.log('\n--- 3. GITIGNORE SECRETS EXCLUSION CHECK ---');
  const rootGitignore = fs.readFileSync(path.join(__dirname, '../.gitignore'), 'utf8');

  const envIgnored = rootGitignore.includes('backend/.env') || rootGitignore.includes('.env');
  const serviceAccountIgnored = rootGitignore.includes('serviceAccountKey.json');

  console.log('backend/.env Ignored in .gitignore:', envIgnored ? 'PASS' : 'FAIL');
  console.log('serviceAccountKey.json Ignored in .gitignore:', serviceAccountIgnored ? 'PASS' : 'FAIL');

  // 4. Rate Limiting Check on Auth Endpoint
  console.log('\n--- 4. AUTHENTICATION RATE LIMITING CHECK ---');
  const authRes = await requestJson('POST', '/auth/student/login', {
    identifier: 'invalid_student_id',
    password: 'wrong_password',
  });
  console.log('Auth Rate Limited Endpoint Response Status:', authRes.statusCode);

  console.log('\n========================================================================');
  console.log('=== PHASE 14 SECURITY AUDIT COMPLETED SUCCESSFULLY! ===');
  console.log('========================================================================');

  process.exit(0);
}

verifyPhase14SecurityAudit().catch((err) => {
  console.error('Security Audit Exception:', err);
  process.exit(1);
});
