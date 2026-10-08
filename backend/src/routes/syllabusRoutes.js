const express = require('express');
const router = express.Router();
const {
  getSyllabus,
  createSyllabus,
  updateSyllabus,
  deleteSyllabus,
} = require('../controllers/syllabusController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

router
  .route('/')
  .get(getSyllabus)
  .post(protect, authorize('collegeAdmin', 'superAdmin'), createSyllabus);

router
  .route('/:id')
  .put(protect, authorize('collegeAdmin', 'superAdmin'), updateSyllabus)
  .delete(protect, authorize('collegeAdmin', 'superAdmin'), deleteSyllabus);

module.exports = router;
