const QuestionPaper = require('../models/QuestionPaper');
const College = require('../models/College');

// @desc    Get question papers
// @route   GET /api/question-papers
// @access  Public / Private
const getQuestionPapers = async (req, res) => {
  try {
    const {
      department,
      course,
      year,
      semester,
      subject,
      examType,
      collegeId,
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
    if (examType) query.examType = examType;
    if (subject) query.subject = { $regex: subject, $options: 'i' };

    const papers = await QuestionPaper.find(query).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: papers.length,
      data: papers,
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

// @desc    Create question paper
// @route   POST /api/question-papers
// @access  Private (College Admin / Super Admin)
const createQuestionPaper = async (req, res) => {
  try {
    const {
      title,
      subject,
      department,
      course,
      year,
      semester,
      examType,
      paperYear,
      fileUrl,
      publicId,
      fileName,
      fileSize,
    } = req.body;

    if (!title || !subject) {
      return res.status(400).json({
        success: false,
        message: 'Title and subject are required',
      });
    }

    const paper = await QuestionPaper.create({
      title,
      subject,
      department: department || '',
      course: course || '',
      year: year || '',
      semester: semester || '',
      examType: examType || 'Mid-Term Exam',
      paperYear: paperYear || '',
      fileUrl: fileUrl || '',
      publicId: publicId || '',
      fileName: fileName || '',
      fileSize: fileSize || '',
      collegeId: req.user.collegeId,
      uploadedBy: req.user._id,
    });

    return res.status(201).json({
      success: true,
      data: paper,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error creating question paper',
    });
  }
};

// @desc    Update question paper
// @route   PUT /api/question-papers/:id
// @access  Private (College Admin / Super Admin)
const updateQuestionPaper = async (req, res) => {
  try {
    let paper = await QuestionPaper.findById(req.params.id);
    if (!paper) {
      return res
        .status(404)
        .json({ success: false, message: 'Question paper not found' });
    }

    if (
      req.user.role !== 'superAdmin' &&
      paper.collegeId.toString() !== req.user.collegeId.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to modify question papers of another college',
      });
    }

    paper = await QuestionPaper.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    return res.status(200).json({
      success: true,
      data: paper,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error updating question paper',
    });
  }
};

// @desc    Delete question paper
// @route   DELETE /api/question-papers/:id
// @access  Private (College Admin / Super Admin)
const deleteQuestionPaper = async (req, res) => {
  try {
    const paper = await QuestionPaper.findById(req.params.id);
    if (!paper) {
      return res
        .status(404)
        .json({ success: false, message: 'Question paper not found' });
    }

    if (
      req.user.role !== 'superAdmin' &&
      paper.collegeId.toString() !== req.user.collegeId.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete question papers of another college',
      });
    }

    await paper.deleteOne();

    return res.status(200).json({
      success: true,
      message: 'Question paper deleted successfully',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error deleting question paper',
    });
  }
};

module.exports = {
  getQuestionPapers,
  createQuestionPaper,
  updateQuestionPaper,
  deleteQuestionPaper,
};
