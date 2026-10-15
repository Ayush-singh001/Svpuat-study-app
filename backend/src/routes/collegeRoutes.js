const express = require('express');
const router = express.Router();
const {
  getColleges,
  getCollegeById,
  createCollege,
  updateCollege,
  toggleCollegeActive,
  deleteCollege,
  getDepartments,
  addDepartment,
  deleteDepartment,
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

// Department Management Routes
router
  .route('/:id/departments')
  .get(getDepartments)
  .post(protect, authorize('superAdmin'), addDepartment);

router.delete('/:id/departments/:deptName', protect, authorize('superAdmin'), deleteDepartment);

module.exports = router;
