const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

let isConfigured = false;

try {
  const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');
  let serviceAccount = null;

  // 1. Check FIREBASE_SERVICE_ACCOUNT_JSON environment variable (for Render/Cloud Deployment)
  const envServiceAccountJson =
    process.env.FIREBASE_SERVICE_ACCOUNT_JSON || process.env.FIREBASE_SERVICE_ACCOUNT;

  if (envServiceAccountJson && envServiceAccountJson.trim().length > 0) {
    try {
      serviceAccount = JSON.parse(envServiceAccountJson.trim());
    } catch (_) {
      try {
        // Base64 decoded fallback attempt
        const decoded = Buffer.from(envServiceAccountJson.trim(), 'base64').toString('utf8');
        serviceAccount = JSON.parse(decoded);
      } catch (err) {
        console.warn('Firebase Admin SDK: FIREBASE_SERVICE_ACCOUNT_JSON environment variable contains invalid JSON format.');
      }
    }
  } else if (fs.existsSync(serviceAccountPath)) {
    // 2. Local development fallback to backend/src/config/serviceAccountKey.json
    serviceAccount = require(serviceAccountPath);
  }

  if (serviceAccount && !admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    isConfigured = true;
    console.log('Firebase Admin SDK initialized successfully.');
  } else if (!serviceAccount) {
    console.warn('Firebase Admin SDK: Service account credentials not found. Configure FIREBASE_SERVICE_ACCOUNT_JSON env var or serviceAccountKey.json.');
  }
} catch (error) {
  console.warn('Firebase Admin SDK Initialization Warning: Unable to parse or load Firebase service account credentials.');
}

module.exports = {
  admin,
  isConfigured: () => isConfigured || admin.apps.length > 0,
};
