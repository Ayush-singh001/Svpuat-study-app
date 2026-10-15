const College = require('../models/College');

// @desc    Get all active constituent colleges for public selection (excludes SVPUAT university record)
// @route   GET /api/colleges
// @access  Public
const getColleges = async (req, res) => {
  try {
    const { includeInactive } = req.query;

    const query = { code: { $ne: 'SVPUAT' } };
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
    return res.status(500).json({
      success: false,
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
    const { name, shortName, location, state, code, logoUrl, description, departments } = req.body;

    if (!name || !location || !code) {
      return res.status(400).json({
        success: false,
        message: 'College name, location, and code are required',
      });
    }

    const cleanCode = code.trim().toUpperCase();

    // Check duplicate code
    const existing = await College.findOne({ code: cleanCode, isActive: true });
    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'An active college with this code already exists',
      });
    }

    const deptList = Array.isArray(departments)
      ? departments.map((d) => (typeof d === 'string' ? { name: d.trim(), isActive: true } : d))
      : [
          { name: 'Computer Science & Engineering', isActive: true },
          { name: 'Agronomy', isActive: true },
          { name: 'Biotechnology', isActive: true },
        ];

    const college = await College.create({
      name: name.trim(),
      shortName: shortName ? shortName.trim() : name.trim(),
      location: location.trim(),
      state: state ? state.trim() : 'Uttar Pradesh',
      code: cleanCode,
      logoUrl: logoUrl || '',
      description: description || '',
      isActive: true,
      departments: deptList,
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

// @desc    Soft Delete / Deactivate college
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

    college.isActive = false;
    await college.save();

    return res.status(200).json({
      success: true,
      message: 'College deactivated successfully',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error deleting college',
    });
  }
};

// @desc    Get active departments for a specific college
// @route   GET /api/colleges/:id/departments
// @access  Public
const getDepartments = async (req, res) => {
  try {
    const college = await College.findById(req.params.id);
    if (!college) {
      return res.status(404).json({
        success: false,
        message: 'College not found',
      });
    }

    const activeDepts = (college.departments || [])
      .filter((d) => d.isActive !== false)
      .map((d) => d.name);

    return res.status(200).json({
      success: true,
      count: activeDepts.length,
      data: activeDepts,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error fetching departments',
    });
  }
};

// @desc    Add department to a college
// @route   POST /api/colleges/:id/departments
// @access  Private (Super Admin Only)
const addDepartment = async (req, res) => {
  try {
    const { name } = req.body;
    if (!name || !name.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Department name is required',
      });
    }

    const college = await College.findById(req.params.id);
    if (!college) {
      return res.status(404).json({
        success: false,
        message: 'College not found',
      });
    }

    const cleanName = name.trim();
    if (!college.departments) college.departments = [];

    const exists = college.departments.some(
      (d) => d.name.toLowerCase() === cleanName.toLowerCase() && d.isActive !== false
    );

    if (exists) {
      return res.status(400).json({
        success: false,
        message: 'Department already exists for this college',
      });
    }

    college.departments.push({ name: cleanName, isActive: true });
    await college.save();

    const activeDepts = college.departments.filter((d) => d.isActive !== false).map((d) => d.name);

    return res.status(201).json({
      success: true,
      message: `Department "${cleanName}" added successfully to ${college.name}`,
      data: activeDepts,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error adding department',
    });
  }
};

// @desc    Deactivate department from a college
// @route   DELETE /api/colleges/:id/departments/:deptName
// @access  Private (Super Admin Only)
const deleteDepartment = async (req, res) => {
  try {
    const { id, deptName } = req.params;
    const college = await College.findById(id);
    if (!college) {
      return res.status(404).json({
        success: false,
        message: 'College not found',
      });
    }

    const decodedName = decodeURIComponent(deptName).trim();
    if (college.departments) {
      college.departments = college.departments.map((d) => {
        if (d.name.toLowerCase() === decodedName.toLowerCase()) {
          d.isActive = false;
        }
        return d;
      });
      await college.save();
    }

    const activeDepts = (college.departments || [])
      .filter((d) => d.isActive !== false)
      .map((d) => d.name);

    return res.status(200).json({
      success: true,
      message: `Department "${decodedName}" deactivated successfully`,
      data: activeDepts,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error deleting department',
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
  getDepartments,
  addDepartment,
  deleteDepartment,
};
