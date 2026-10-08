const Notice = require('../models/Notice');
const College = require('../models/College');

// @desc    Get notices
// @route   GET /api/notices
// @access  Public / Private
const getNotices = async (req, res) => {
  try {
    const { collegeId, department } = req.query;

    const query = {};

    if (collegeId) {
      query.collegeId = collegeId;
    } else {
      const svpuat = await College.findOne({ code: 'SVPUAT' });
      if (svpuat) query.collegeId = svpuat._id;
    }

    if (department) query.department = department;

    const notices = await Notice.find(query).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: notices.length,
      data: notices,
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

// @desc    Create notice
// @route   POST /api/notices
// @access  Private (College Admin / Super Admin)
const createNotice = async (req, res) => {
  try {
    const { title, description, attachmentUrl, publicId, fileName, fileSize, department } = req.body;

    if (!title || !description) {
      return res.status(400).json({
        success: false,
        message: 'Title and description are required',
      });
    }

    const notice = await Notice.create({
      title,
      description,
      attachmentUrl: attachmentUrl || '',
      publicId: publicId || '',
      fileName: fileName || '',
      fileSize: fileSize || '',
      department: department || 'All Departments',
      collegeId: req.user.collegeId,
      uploadedBy: req.user._id,
    });

    return res.status(201).json({
      success: true,
      data: notice,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error creating notice',
    });
  }
};

// @desc    Update notice
// @route   PUT /api/notices/:id
// @access  Private (College Admin / Super Admin)
const updateNotice = async (req, res) => {
  try {
    let notice = await Notice.findById(req.params.id);
    if (!notice) {
      return res
        .status(404)
        .json({ success: false, message: 'Notice not found' });
    }

    if (
      req.user.role !== 'superAdmin' &&
      notice.collegeId.toString() !== req.user.collegeId.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to modify notices of another college',
      });
    }

    notice = await Notice.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    return res.status(200).json({
      success: true,
      data: notice,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error updating notice',
    });
  }
};

// @desc    Delete notice
// @route   DELETE /api/notices/:id
// @access  Private (College Admin / Super Admin)
const deleteNotice = async (req, res) => {
  try {
    const notice = await Notice.findById(req.params.id);
    if (!notice) {
      return res
        .status(404)
        .json({ success: false, message: 'Notice not found' });
    }

    if (
      req.user.role !== 'superAdmin' &&
      notice.collegeId.toString() !== req.user.collegeId.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete notices of another college',
      });
    }

    await notice.deleteOne();

    return res.status(200).json({
      success: true,
      message: 'Notice deleted successfully',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error deleting notice',
    });
  }
};

module.exports = {
  getNotices,
  createNotice,
  updateNotice,
  deleteNotice,
};
