const express = require('express');
const router = express.Router();
const {
  getNotices,
  createNotice,
  updateNotice,
  deleteNotice,
} = require('../controllers/noticeController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

router
  .route('/')
  .get(getNotices)
  .post(protect, authorize('collegeAdmin', 'superAdmin'), createNotice);

router
  .route('/:id')
  .put(protect, authorize('collegeAdmin', 'superAdmin'), updateNotice)
  .delete(protect, authorize('collegeAdmin', 'superAdmin'), deleteNotice);

module.exports = router;
