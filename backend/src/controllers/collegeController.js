const College = require('../models/College');

// @desc    Get all active colleges for public selection
// @route   GET /api/colleges
// @access  Public
const getColleges = async (req, res) => {
  try {
    const { includeInactive } = req.query;

    const query = {};
    if (includeInactive !== 'true') {
      query.isActive = true;
    }

    const colleges = await College.find(query).sort({ name: 1 });

    return res.status(200).json({
      success: true,
      count: colleges.length,
      data: colleges,
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

// @desc    Get single college by ID
// @route   GET /api/colleges/:id
// @access  Public
const getCollegeById = async (req, res) => {
  try {
    const college = await College.findById(req.params.id);
    if (!college) {
      return res.status(404).json({
        success: false,
        message: 'College not found',
      });
    }

    return res.status(200).json({
      success: true,
      data: college,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error fetching college',
    });
  }
};

// @desc    Create new college
// @route   POST /api/colleges
// @access  Private (Super Admin Only)
const createCollege = async (req, res) => {
  try {
    const { name, shortName, location, state, code, logoUrl, description } = req.body;

    if (!name || !location || !code) {
      return res.status(400).json({
        success: false,
        message: 'College name, location, and code are required',
      });
    }

    const cleanCode = code.trim().toUpperCase();

    // Check duplicate code
    const existing = await College.findOne({ code: cleanCode });
    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'A college with this code already exists',
      });
    }

    const college = await College.create({
      name: name.trim(),
      shortName: shortName ? shortName.trim() : name.trim(),
      location: location.trim(),
      state: state ? state.trim() : 'Uttar Pradesh',
      code: cleanCode,
      logoUrl: logoUrl || '',
      description: description || '',
      isActive: true,
    });

    return res.status(201).json({
      success: true,
      message: 'College created successfully',
      data: college,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error creating college',
    });
  }
};

// @desc    Update college details
// @route   PUT /api/colleges/:id
// @access  Private (Super Admin Only)
const updateCollege = async (req, res) => {
  try {
    let college = await College.findById(req.params.id);
    if (!college) {
      return res.status(404).json({
        success: false,
        message: 'College not found',
      });
    }

    college = await College.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    return res.status(200).json({
      success: true,
      message: 'College updated successfully',
      data: college,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error updating college',
    });
  }
};

// @desc    Toggle college active/inactive status
// @route   PUT /api/colleges/:id/toggle-active
// @access  Private (Super Admin Only)
const toggleCollegeActive = async (req, res) => {
  try {
    const college = await College.findById(req.params.id);
    if (!college) {
      return res.status(404).json({
        success: false,
        message: 'College not found',
      });
    }

    college.isActive = !college.isActive;
    await college.save();

    return res.status(200).json({
      success: true,
      message: `College ${college.isActive ? 'activated' : 'deactivated'} successfully`,
      data: college,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error toggling college active status',
    });
  }
};

// @desc    Delete college
// @route   DELETE /api/colleges/:id
// @access  Private (Super Admin Only)
const deleteCollege = async (req, res) => {
  try {
    const college = await College.findById(req.params.id);
    if (!college) {
      return res.status(404).json({
        success: false,
        message: 'College not found',
      });
    }

    // Do not allow deleting SVPUAT default college
    if (college.code === 'SVPUAT') {
      return res.status(400).json({
        success: false,
        message: 'SVPUAT primary college cannot be deleted',
      });
    }

    await college.deleteOne();

    return res.status(200).json({
      success: true,
      message: 'College deleted successfully',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error deleting college',
    });
  }
};

module.exports = {
  getColleges,
  getCollegeById,
  createCollege,
  updateCollege,
  toggleCollegeActive,
  deleteCollege,
};
