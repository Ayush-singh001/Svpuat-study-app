const express = require('express');
const router = express.Router();
const {
  getNotes,
  createNote,
  updateNote,
  deleteNote,
} = require('../controllers/noteController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

router
  .route('/')
  .get(getNotes)
  .post(protect, authorize('collegeAdmin', 'superAdmin'), createNote);

router
  .route('/:id')
  .put(protect, authorize('collegeAdmin', 'superAdmin'), updateNote)
  .delete(protect, authorize('collegeAdmin', 'superAdmin'), deleteNote);

module.exports = router;
