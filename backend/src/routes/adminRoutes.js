const express = require('express');
const router = express.Router();
const { createCollegeAdmin } = require('../controllers/adminController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

router.post('/user', protect, authorize('superAdmin'), createCollegeAdmin);

module.exports = router;
