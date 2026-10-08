const ImportantQuestion = require('../models/ImportantQuestion');
const College = require('../models/College');

// @desc    Get important questions (filtered by department, course, year, semester, subject, unitTopic, collegeId)
// @route   GET /api/important-questions
// @access  Public / Private
const getImportantQuestions = async (req, res) => {
  try {
    const {
      department,
      course,
      year,
      semester,
      subject,
      unitTopic,
      questionType,
      difficulty,
      collegeId,
      search,
    } = req.query;

    const query = {};

    if (collegeId) {
      query.collegeId = collegeId;
    } else {
      const svpuat = await College.findOne({ code: 'SVPUAT' });
      if (svpuat) query.collegeId = svpuat._id;
    }

    if (department) query.department = department;
    if (course) query.course = course;
    if (year) query.year = year;
    if (semester) query.semester = semester;
    if (questionType) query.questionType = questionType;
    if (difficulty) query.difficulty = difficulty;
    if (unitTopic) query.unitTopic = { $regex: unitTopic, $options: 'i' };
    if (subject) query.subject = { $regex: subject, $options: 'i' };

    if (search) {
      query.$or = [
        { question: { $regex: search, $options: 'i' } },
        { unitTopic: { $regex: search, $options: 'i' } },
        { subject: { $regex: search, $options: 'i' } },
      ];
    }

    const questions = await ImportantQuestion.find(query).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: questions.length,
      data: questions,
    });
  } catch (error) {
    return res.status(200).json({
      success: true,
      count: 0,
      data: [],
      error: error.message,
    });
  }
};

// @desc    Create important question
// @route   POST /api/important-questions
// @access  Private (College Admin / Super Admin)
const createImportantQuestion = async (req, res) => {
  try {
    const {
      question,
      subject,
      department,
      course,
      year,
      semester,
      unitTopic,
      questionType,
      difficulty,
    } = req.body;

    if (!question || !subject) {
      return res.status(400).json({
        success: false,
        message: 'Question text and subject are required',
      });
    }

    const newQuestion = await ImportantQuestion.create({
      question,
      subject,
      department: department || '',
      course: course || '',
      year: year || '',
      semester: semester || '',
      unitTopic: unitTopic || 'General Topic',
      questionType: questionType || 'Long Answer',
      difficulty: difficulty || 'Medium',
      collegeId: req.user.collegeId,
      uploadedBy: req.user._id,
    });

    return res.status(201).json({
      success: true,
      data: newQuestion,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error creating important question',
    });
  }
};

// @desc    Update important question
// @route   PUT /api/important-questions/:id
// @access  Private (College Admin / Super Admin)
const updateImportantQuestion = async (req, res) => {
  try {
    let questionObj = await ImportantQuestion.findById(req.params.id);
    if (!questionObj) {
      return res
        .status(404)
        .json({ success: false, message: 'Important question not found' });
    }

    // College Data Isolation Check
    if (
      req.user.role !== 'superAdmin' &&
      questionObj.collegeId.toString() !== req.user.collegeId.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to modify important questions of another college',
      });
    }

    questionObj = await ImportantQuestion.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true,
      }
    );

    return res.status(200).json({
      success: true,
      data: questionObj,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error updating important question',
    });
  }
};

// @desc    Delete important question
// @route   DELETE /api/important-questions/:id
// @access  Private (College Admin / Super Admin)
const deleteImportantQuestion = async (req, res) => {
  try {
    const questionObj = await ImportantQuestion.findById(req.params.id);
    if (!questionObj) {
      return res
        .status(404)
        .json({ success: false, message: 'Important question not found' });
    }

    if (
      req.user.role !== 'superAdmin' &&
      questionObj.collegeId.toString() !== req.user.collegeId.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete important questions of another college',
      });
    }

    await questionObj.deleteOne();

    return res.status(200).json({
      success: true,
      message: 'Important question deleted successfully',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error deleting important question',
    });
  }
};

module.exports = {
  getImportantQuestions,
  createImportantQuestion,
  updateImportantQuestion,
  deleteImportantQuestion,
};
