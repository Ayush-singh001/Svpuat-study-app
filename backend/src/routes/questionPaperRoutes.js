const express = require('express');
const router = express.Router();
const {
  getQuestionPapers,
  createQuestionPaper,
  updateQuestionPaper,
  deleteQuestionPaper,
} = require('../controllers/questionPaperController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

router
  .route('/')
  .get(getQuestionPapers)
  .post(protect, authorize('collegeAdmin', 'superAdmin'), createQuestionPaper);

router
  .route('/:id')
  .put(protect, authorize('collegeAdmin', 'superAdmin'), updateQuestionPaper)
  .delete(
    protect,
    authorize('collegeAdmin', 'superAdmin'),
    deleteQuestionPaper
  );

module.exports = router;
