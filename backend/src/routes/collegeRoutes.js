const express = require('express');
const router = express.Router();
const {
  getColleges,
  getCollegeById,
  createCollege,
  updateCollege,
  toggleCollegeActive,
  deleteCollege,
} = require('../controllers/collegeController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

router
  .route('/')
  .get(getColleges)
  .post(protect, authorize('superAdmin'), createCollege);

router
  .route('/:id')
  .get(getCollegeById)
  .put(protect, authorize('superAdmin'), updateCollege)
  .delete(protect, authorize('superAdmin'), deleteCollege);

router.put('/:id/toggle-active', protect, authorize('superAdmin'), toggleCollegeActive);

module.exports = router;
