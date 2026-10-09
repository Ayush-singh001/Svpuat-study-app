const Subject = require('../models/Subject');
const College = require('../models/College');

// @desc    Get subjects (filtered by collegeId, course, department, year, semester)
// @route   GET /api/subjects
// @access  Public / Private
const getSubjects = async (req, res) => {
  try {
    const { collegeId, course, department, year, semester } = req.query;

    const query = { isDeleted: { $ne: true } };

    if (collegeId) {
      query.collegeId = collegeId;
    } else {
      const svpuat = await College.findOne({ code: 'SVPUAT' });
      if (svpuat) query.collegeId = svpuat._id;
    }

    if (course) query.course = course;
    if (department) query.department = department;
    if (year) query.year = year;
    if (semester) query.semester = semester;

    const subjects = await Subject.find(query).sort({ name: 1 });

    return res.status(200).json({
      success: true,
      count: subjects.length,
      data: subjects,
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

// @desc    Create new subject
// @route   POST /api/subjects
// @access  Private (College Admin Only)
const createSubject = async (req, res) => {
  try {
    const { name, code, department, course, year, semester } = req.body;

    if (!name || !name.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Subject name is required',
      });
    }

    if (!req.user.collegeId) {
      return res.status(400).json({
        success: false,
        message: 'College ID is required to create a subject',
      });
    }

    const cleanName = name.trim();

    // Check duplicate subject in same college, course & semester
    const existing = await Subject.findOne({
      name: { $regex: new RegExp(`^${cleanName}$`, 'i') },
      collegeId: req.user.collegeId,
      course: course || 'B.Tech',
      semester: semester || '3rd Semester',
      isDeleted: { $ne: true },
    });

    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'A subject with this name already exists for this course and semester',
      });
    }

    const subject = await Subject.create({
      name: cleanName,
      code: code ? code.trim() : '',
      department: department || 'Computer Science & Engineering',
      course: course || 'B.Tech',
      year: year || '2nd Year',
      semester: semester || '3rd Semester',
      collegeId: req.user.collegeId,
      createdBy: req.user._id,
      isDeleted: false,
    });

    return res.status(201).json({
      success: true,
      data: subject,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error creating subject',
    });
  }
};

// @desc    Update subject
// @route   PUT /api/subjects/:id
// @access  Private (College Admin Only)
const updateSubject = async (req, res) => {
  try {
    let subject = await Subject.findOne({ _id: req.params.id, isDeleted: { $ne: true } });

    if (!subject) {
      return res.status(404).json({
        success: false,
        message: 'Subject not found',
      });
    }

    // College Data Isolation Check
    if (subject.collegeId.toString() !== req.user.collegeId.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to modify subjects of another college',
      });
    }

    subject = await Subject.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    return res.status(200).json({
      success: true,
      data: subject,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error updating subject',
    });
  }
};

// @desc    Soft Delete subject
// @route   DELETE /api/subjects/:id
// @access  Private (College Admin Only)
const deleteSubject = async (req, res) => {
  try {
    const subject = await Subject.findOne({ _id: req.params.id, isDeleted: { $ne: true } });

    if (!subject) {
      return res.status(404).json({
        success: false,
        message: 'Subject not found',
      });
    }

    // College Data Isolation Check
    if (subject.collegeId.toString() !== req.user.collegeId.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete subjects of another college',
      });
    }

    subject.isDeleted = true;
    await subject.save();

    return res.status(200).json({
      success: true,
      message: 'Subject deleted successfully',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error deleting subject',
    });
  }
};

module.exports = {
  getSubjects,
  createSubject,
  updateSubject,
  deleteSubject,
};
