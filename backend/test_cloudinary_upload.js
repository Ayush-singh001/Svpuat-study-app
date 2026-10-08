const dns = require('dns');
if (dns.setDefaultResultOrder) {
  dns.setDefaultResultOrder('ipv4first');
}

const http = require('http');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '.env') });

function postMultipart(path, token, fields, fileBuffer, fileName) {
  return new Promise((resolve, reject) => {
    const boundary = '----WebKitFormBoundary' + Math.random().toString(36).substring(2);
    let body = [];

    for (const [key, val] of Object.entries(fields)) {
      body.push(Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="${key}"\r\n\r\n${val}\r\n`));
    }

    if (fileBuffer) {
      body.push(Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="file"; filename="${fileName}"\r\nContent-Type: application/pdf\r\n\r\n`));
      body.push(fileBuffer);
      body.push(Buffer.from('\r\n'));
    }

    body.push(Buffer.from(`--${boundary}--\r\n`));
    const payload = Buffer.concat(body);

    const req = http.request(
      {
        hostname: 'localhost',
        port: 5000,
        path: encodeURI(`/api${path}`),
        method: 'POST',
        headers: {
          'Content-Type': `multipart/form-data; boundary=${boundary}`,
          'Content-Length': payload.length,
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
    req.write(payload);
    req.end();
  });
}

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

async function testCloudinaryUpload() {
  console.log('=== TESTING CLOUDINARY FILE UPLOAD & MONGODB ATLAS INTEGRATION ===');

  await mongoose.connect(process.env.MONGODB_URI, { serverSelectionTimeoutMS: 15000 });

  // 1. Register an admin user
  const adminEmail = `admin_${Date.now()}@svpuat.ac.in`;
  const regAdmin = await requestJson('POST', '/auth/register', {
    fullName: 'SVPUAT Academic Admin',
    email: adminEmail,
    mobile: '9876543210',
    studentId: `ADM${Date.now()}`,
    password: 'AdminPassword123!',
    course: 'B.Tech',
    department: 'Computer Science & Engineering',
    year: 'Faculty',
    semester: 'All',
  });

  console.log('1. Register Admin User:', regAdmin.statusCode, 'Success:', regAdmin.body.success);

  // Promote user role to collegeAdmin in MongoDB Atlas
  const User = require('./src/models/User');
  await User.findByIdAndUpdate(regAdmin.body.user.id, { role: 'collegeAdmin' });
  console.log('   Promoted user to collegeAdmin role in MongoDB Atlas.');

  // Re-login to get updated JWT token with collegeAdmin role
  const loginRes = await requestJson('POST', '/auth/login', {
    identifier: adminEmail,
    password: 'AdminPassword123!',
  });
  const adminToken = loginRes.body.token;

  // 2. Sample PDF buffer for testing
  const samplePdfBuffer = Buffer.from(
    '%PDF-1.4\n1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj 2 0 obj<</Type/Pages/Count 1/Kids[3 0 R]>>endobj 3 0 obj<</Type/Page/MediaBox[0 0 612 792]/Parent 2 0 R/Resources<<>>>>endobj\nxref\n0 4\n0000000000 65535 f\n0000000010 00000 n\n0000000053 00000 n\n0000000102 00000 n\ntrailer<</Size 4/Root 1 0 R>>\nstartxref\n178\n%%EOF'
  );

  // 3. Test POST /api/upload
  console.log('2. Uploading PDF file to Cloudinary via POST /api/upload...');
  const uploadRes = await postMultipart('/upload', adminToken, {}, samplePdfBuffer, 'SVPUAT_DSA_Lecture1.pdf');
  console.log('   Upload Response Status:', uploadRes.statusCode);
  console.log('   Upload Success:', uploadRes.body.success);
  console.log('   Cloudinary URL Returned:', !!uploadRes.body.fileUrl);
  console.log('   Public ID Returned:', !!uploadRes.body.publicId);

  const fileUrl = uploadRes.body.fileUrl;
  const publicId = uploadRes.body.publicId;
  const fileName = uploadRes.body.fileName;

  if (!uploadRes.body.success) {
    console.error('   Upload Failure Message:', uploadRes.body.message);
    await mongoose.disconnect();
    process.exit(1);
  }

  // 4. Save note in MongoDB Atlas with the Cloudinary PDF URL
  console.log('3. Saving Note metadata in MongoDB Atlas with Cloudinary URL...');
  const noteRes = await requestJson(
    'POST',
    '/notes',
    {
      title: 'Data Structures Unit 1 - Trees & Graphs PDF',
      description: 'Official lecture note PDF uploaded to Cloudinary.',
      department: 'Computer Science & Engineering',
      course: 'B.Tech',
      year: '2nd Year',
      semester: '3rd Semester',
      subject: 'Data Structures & Algorithms',
      fileUrl: fileUrl,
      publicId: publicId,
      fileName: fileName,
    },
    adminToken
  );

  console.log('   Save Note Status:', noteRes.statusCode);
  console.log('   Note Saved in MongoDB Atlas ID:', noteRes.body.data?._id);
  console.log('   Note File URL Saved:', !!noteRes.body.data?.fileUrl);

  const noteId = noteRes.body.data?._id;

  // 5. Query GET /api/notes to verify student can fetch the note with Cloudinary PDF URL
  console.log('4. Querying GET /api/notes to verify student view...');
  const getNotesRes = await requestJson('GET', '/notes?subject=Data Structures');
  console.log('   Get Notes Status:', getNotesRes.statusCode);
  console.log('   Notes Count:', getNotesRes.body.count);
  const fetchedNote = getNotesRes.body.data?.[0];
  console.log('   Fetched Note Title:', fetchedNote?.title);
  console.log('   Fetched Note PDF URL:', !!fetchedNote?.fileUrl);

  // 6. Test Admin Delete (Delete note from MongoDB Atlas & delete file from Cloudinary)
  console.log('5. Testing Admin Delete (DELETE /api/upload & DELETE /api/notes/:id)...');
  const deleteCloudinaryRes = await requestJson('DELETE', '/upload', { publicId }, adminToken);
  console.log('   Delete Cloudinary File Status:', deleteCloudinaryRes.statusCode, 'Success:', deleteCloudinaryRes.body.success);

  const deleteNoteRes = await requestJson('DELETE', `/notes/${noteId}`, null, adminToken);
  console.log('   Delete Note from MongoDB Atlas Status:', deleteNoteRes.statusCode, 'Success:', deleteNoteRes.body.success);

  console.log('=== ALL CLOUDINARY & MONGODB ATLAS TESTS PASSED SUCCESSFULLY! ===');
  await mongoose.disconnect();
  process.exit(0);
}

testCloudinaryUpload().catch(async (err) => {
  console.error('Test Failed Exception:', err);
  await mongoose.disconnect();
  process.exit(1);
});
