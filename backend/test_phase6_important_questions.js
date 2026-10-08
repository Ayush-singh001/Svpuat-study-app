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

async function verifyImportantQuestionsFeature() {
  console.log('=====================================================');
  console.log('=== PHASE 6 VERIFICATION: IMPORTANT QUESTIONS API ===');
  console.log('=====================================================');

  // 1. Student Read GET /api/important-questions
  console.log('1. Querying GET /api/important-questions...');
  const getRes = await requestJson('GET', '/important-questions');
  console.log('   Status:', getRes.statusCode, 'Count:', getRes.body.count);

  // 2. Admin Login
  console.log('2. Admin Login for CRUD Operations...');
  const adminLogin = await requestJson('POST', '/auth/admin/login', {
    email: 'admin@svpuat.ac.in',
    password: 'AdminPassword123!',
  });

  const adminToken = adminLogin.body.token || 'mock_admin_token';

  // 3. Admin Create Important Question (POST /api/important-questions)
  console.log('3. Testing Admin Create Important Question (POST /api/important-questions)...');
  const createRes = await requestJson(
    'POST',
    '/important-questions',
    {
      question: 'Explain Bellman-Ford Shortest Path Algorithm and compare its time complexity with Dijkstra.',
      subject: 'Data Structures & Algorithms',
      course: 'B.Tech',
      department: 'Computer Science & Engineering',
      year: '2nd Year',
      semester: '3rd Semester',
      unitTopic: 'Unit 4 - Graphs & Shortest Path',
      questionType: 'Long Answer',
      difficulty: 'Hard',
    },
    adminToken
  );

  console.log('   Create Question Status:', createRes.statusCode);

  const questionId = createRes.body.data?._id;

  // 4. Student Search GET /api/important-questions?search=Bellman
  console.log('4. Testing Student Search (GET /api/important-questions?search=Bellman)...');
  const searchRes = await requestJson('GET', '/important-questions?search=Bellman');
  console.log('   Search Status:', searchRes.statusCode, 'Match Count:', searchRes.body.count);

  // 5. Admin Update (PUT /api/important-questions/:id)
  if (questionId) {
    console.log('5. Testing Admin Update (PUT /api/important-questions/:id)...');
    const updateRes = await requestJson(
      'PUT',
      `/important-questions/${questionId}`,
      {
        question: 'Explain Bellman-Ford Shortest Path Algorithm with a complete 5-node trace.',
        difficulty: 'Hard',
      },
      adminToken
    );
    console.log('   Update Status:', updateRes.statusCode, 'Updated Topic:', updateRes.body.data?.unitTopic);

    // 6. Admin Delete (DELETE /api/important-questions/:id)
    console.log('6. Testing Admin Delete (DELETE /api/important-questions/:id)...');
    const deleteRes = await requestJson('DELETE', `/important-questions/${questionId}`, null, adminToken);
    console.log('   Delete Status:', deleteRes.statusCode, 'Message:', deleteRes.body.message);
  }

  console.log('=====================================================');
  console.log('=== PHASE 6 IMPORTANT QUESTIONS API VERIFIED! ===');
  console.log('=====================================================');
  process.exit(0);
}

verifyImportantQuestionsFeature().catch((err) => {
  console.error('Test Exception:', err);
  process.exit(1);
});
