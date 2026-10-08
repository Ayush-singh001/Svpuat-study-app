const Syllabus = require('../models/Syllabus');
const College = require('../models/College');

// @desc    Get syllabus
// @route   GET /api/syllabus
// @access  Public / Private
const getSyllabus = async (req, res) => {
  try {
    const { department, course, year, semester, collegeId } = req.query;

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

    const syllabusList = await Syllabus.find(query).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: syllabusList.length,
      data: syllabusList,
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

// @desc    Create syllabus
// @route   POST /api/syllabus
// @access  Private (College Admin / Super Admin)
const createSyllabus = async (req, res) => {
  try {
    const { title, department, course, year, semester, fileUrl, publicId, fileName, fileSize } = req.body;

    if (!title) {
      return res.status(400).json({
        success: false,
        message: 'Title is required',
      });
    }

    const syllabus = await Syllabus.create({
      title,
      department: department || '',
      course: course || '',
      year: year || '',
      semester: semester || '',
      fileUrl: fileUrl || '',
      publicId: publicId || '',
      fileName: fileName || '',
      fileSize: fileSize || '',
      collegeId: req.user.collegeId,
      uploadedBy: req.user._id,
    });

    return res.status(201).json({
      success: true,
      data: syllabus,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error creating syllabus',
    });
  }
};

// @desc    Update syllabus
// @route   PUT /api/syllabus/:id
// @access  Private (College Admin / Super Admin)
const updateSyllabus = async (req, res) => {
  try {
    let syllabus = await Syllabus.findById(req.params.id);
    if (!syllabus) {
      return res
        .status(404)
        .json({ success: false, message: 'Syllabus not found' });
    }

    if (
      req.user.role !== 'superAdmin' &&
      syllabus.collegeId.toString() !== req.user.collegeId.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to modify syllabus of another college',
      });
    }

    syllabus = await Syllabus.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    return res.status(200).json({
      success: true,
      data: syllabus,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error updating syllabus',
    });
  }
};

// @desc    Delete syllabus
// @route   DELETE /api/syllabus/:id
// @access  Private (College Admin / Super Admin)
const deleteSyllabus = async (req, res) => {
  try {
    const syllabus = await Syllabus.findById(req.params.id);
    if (!syllabus) {
      return res
        .status(404)
        .json({ success: false, message: 'Syllabus not found' });
    }

    if (
      req.user.role !== 'superAdmin' &&
      syllabus.collegeId.toString() !== req.user.collegeId.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete syllabus of another college',
      });
    }

    await syllabus.deleteOne();

    return res.status(200).json({
      success: true,
      message: 'Syllabus deleted successfully',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error deleting syllabus',
    });
  }
};

module.exports = {
  getSyllabus,
  createSyllabus,
  updateSyllabus,
  deleteSyllabus,
};
