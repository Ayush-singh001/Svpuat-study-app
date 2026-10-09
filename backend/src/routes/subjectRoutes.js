const express = require('express');
const router = express.Router();
const {
  getSubjects,
  createSubject,
  updateSubject,
  deleteSubject,
} = require('../controllers/subjectController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

router
  .route('/')
  .get(getSubjects)
  .post(protect, authorize('collegeAdmin'), createSubject);

router
  .route('/:id')
  .put(protect, authorize('collegeAdmin'), updateSubject)
  .delete(protect, authorize('collegeAdmin'), deleteSubject);

module.exports = router;
