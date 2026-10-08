const Note = require('../models/Note');
const College = require('../models/College');

// @desc    Get notes (filtered by department, course, year, semester, subject, collegeId)
// @route   GET /api/notes
// @access  Public / Private
const getNotes = async (req, res) => {
  try {
    const { department, course, year, semester, subject, collegeId } = req.query;

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
    if (subject) query.subject = { $regex: subject, $options: 'i' };

    const notes = await Note.find(query).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: notes.length,
      data: notes,
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

// @desc    Create new note
// @route   POST /api/notes
// @access  Private (College Admin / Super Admin)
const createNote = async (req, res) => {
  try {
    const {
      title,
      description,
      department,
      course,
      year,
      semester,
      subject,
      fileUrl,
      publicId,
      fileName,
      fileSize,
    } = req.body;

    if (!title || !description) {
      return res.status(400).json({
        success: false,
        message: 'Title and description are required',
      });
    }

    const note = await Note.create({
      title,
      description,
      department: department || '',
      course: course || '',
      year: year || '',
      semester: semester || '',
      subject: subject || '',
      fileUrl: fileUrl || '',
      publicId: publicId || '',
      fileName: fileName || '',
      fileSize: fileSize || '',
      collegeId: req.user.collegeId,
      uploadedBy: req.user._id,
    });

    return res.status(201).json({
      success: true,
      data: note,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error creating note',
    });
  }
};

// @desc    Update note
// @route   PUT /api/notes/:id
// @access  Private (College Admin / Super Admin)
const updateNote = async (req, res) => {
  try {
    let note = await Note.findById(req.params.id);
    if (!note) {
      return res
        .status(404)
        .json({ success: false, message: 'Note not found' });
    }

    if (
      req.user.role !== 'superAdmin' &&
      note.collegeId.toString() !== req.user.collegeId.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to modify notes of another college',
      });
    }

    note = await Note.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    return res.status(200).json({
      success: true,
      data: note,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error updating note',
    });
  }
};

// @desc    Delete note
// @route   DELETE /api/notes/:id
// @access  Private (College Admin / Super Admin)
const deleteNote = async (req, res) => {
  try {
    const note = await Note.findById(req.params.id);
    if (!note) {
      return res
        .status(404)
        .json({ success: false, message: 'Note not found' });
    }

    if (
      req.user.role !== 'superAdmin' &&
      note.collegeId.toString() !== req.user.collegeId.toString()
    ) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete notes of another college',
      });
    }

    await note.deleteOne();

    return res.status(200).json({
      success: true,
      message: 'Note deleted successfully',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error deleting note',
    });
  }
};

module.exports = {
  getNotes,
  createNote,
  updateNote,
  deleteNote,
};
