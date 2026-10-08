const express = require('express');
const router = express.Router();
const upload = require('../middleware/uploadMiddleware');
const { uploadFile, deleteFile, streamPdfProxy } = require('../controllers/uploadController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

router.post(
  '/',
  protect,
  authorize('collegeAdmin', 'superAdmin'),
  upload.single('file'),
  uploadFile
);

router.delete(
  '/',
  protect,
  authorize('collegeAdmin', 'superAdmin'),
  deleteFile
);

// Protected JWT PDF Streaming Proxy for In-App Viewing
router.get('/stream-pdf', protect, streamPdfProxy);

module.exports = router;
