const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

let isConfigured = false;

try {
  const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');
  let serviceAccount = null;

  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    try {
      serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    } catch (_) {
      serviceAccount = JSON.parse(
        Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT, 'base64').toString('utf8')
      );
    }
  } else if (fs.existsSync(serviceAccountPath)) {
    serviceAccount = require(serviceAccountPath);
  }

  if (serviceAccount && !admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    isConfigured = true;
    console.log('Firebase Admin SDK initialized successfully.');
  }
} catch (error) {
  console.warn('Firebase Admin SDK Initialization Warning:', error.message);
}

module.exports = {
  admin,
  isConfigured: () => isConfigured || admin.apps.length > 0,
};
