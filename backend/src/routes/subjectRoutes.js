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
  .post(protect, authorize('collegeAdmin', 'superAdmin'), createSubject);

router
  .route('/:id')
  .put(protect, authorize('collegeAdmin', 'superAdmin'), updateSubject)
  .delete(protect, authorize('collegeAdmin', 'superAdmin'), deleteSubject);

module.exports = router;
