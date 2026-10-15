const dotenv = require('dotenv');
const path = require('path');
dotenv.config({ path: path.join(__dirname, '.env') });

const http = require('http');

function getJson(path) {
  return new Promise((resolve, reject) => {
    const req = http.request(
      {
        hostname: 'localhost',
        port: 5000,
        path: path,
        method: 'GET',
        headers: { 'Content-Type': 'application/json' },
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => resolve(JSON.parse(data)));
      }
    );
    req.on('error', reject);
    req.end();
  });
}

async function testApi() {
  const cotId = '6ac7eb6c5f31bfb677fb47df';
  const url = `/api/subjects?collegeId=${cotId}&course=B.Tech&department=Computer%20Science%20%26%20Engineering&year=2nd%20Year&semester=3rd%20Semester`;
  console.log(`Querying: ${url}`);
  const res = await getJson(url);
  console.log('Response:', JSON.stringify(res, null, 2));
  process.exit(0);
}

testApi().catch(console.error);
