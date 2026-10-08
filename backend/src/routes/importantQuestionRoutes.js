const express = require('express');
const router = express.Router();
const {
  getImportantQuestions,
  createImportantQuestion,
  updateImportantQuestion,
  deleteImportantQuestion,
} = require('../controllers/importantQuestionController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

router
  .route('/')
  .get(getImportantQuestions)
  .post(protect, authorize('collegeAdmin', 'superAdmin'), createImportantQuestion);

router
  .route('/:id')
  .put(protect, authorize('collegeAdmin', 'superAdmin'), updateImportantQuestion)
  .delete(protect, authorize('collegeAdmin', 'superAdmin'), deleteImportantQuestion);

module.exports = router;
