const mongoose = require('mongoose');
const Note = require('../models/Note');
const Subject = require('../models/Subject');
const College = require('../models/College');

// @desc    Get notes (filtered by department, course, year, semester, subject, collegeId)
// @route   GET /api/notes
// @access  Public / Private
const getNotes = async (req, res) => {
  try {
    const { department, course, year, semester, subject, collegeId } = req.query;

    const query = { isDeleted: { $ne: true } };

    if (collegeId && collegeId !== 'col_svpuat') {
      if (!mongoose.Types.ObjectId.isValid(collegeId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid college ID format provided',
        });
      }
      query.collegeId = collegeId;
    } else {
      const svpuat = await College.findOne({ code: 'SVPUAT' });
      if (!svpuat) {
        return res.status(500).json({
          success: false,
          message: 'Primary SVPUAT University record not found in database',
        });
      }
      query.collegeId = svpuat._id;
    }

    if (course) query.course = course;
    if (year) query.year = year;
    if (semester) query.semester = semester;

    if (department && department.trim()) {
      query.department = { $regex: department.trim(), $options: 'i' };
    }

    if (subject && subject.trim()) {
      query.subject = { $regex: subject.trim(), $options: 'i' };
    }

    const notes = await Note.find(query).sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      count: notes.length,
      data: notes,
    });
  } catch (error) {
    console.error('getNotes Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Server error retrieving notes',
    });
  }
};

// @desc    Create new note with automatic subject creation/reuse
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

    if (!subject || !subject.trim() || subject.trim().length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Subject selection (min 2 chars) is required to publish notes',
      });
    }

    // Resolve Target College ID
    let targetCollegeId = req.user.collegeId;
    if (!targetCollegeId) {
      const svpuat = await College.findOne({ code: 'SVPUAT' });
      if (!svpuat) {
        return res.status(500).json({
          success: false,
          message: 'Primary SVPUAT University record not found in database',
        });
      }
      targetCollegeId = svpuat._id;
    }

    const cleanSubject = subject.trim().replace(/\s+/g, ' ');
    const cleanCourse = course || 'B.Tech';
    const cleanDept = department || 'Computer Science & Engineering';
    const cleanYear = year || '2nd Year';
    const cleanSemester = semester || '3rd Semester';

    // Automatic Subject Reuse / Creation Check
    const existingSubject = await Subject.findOne({
      name: { $regex: new RegExp(`^${cleanSubject}$`, 'i') },
      collegeId: targetCollegeId,
      course: cleanCourse,
      semester: cleanSemester,
      isDeleted: { $ne: true },
    });

    if (!existingSubject) {
      // Create new Subject document in MongoDB Atlas automatically
      await Subject.create({
        name: cleanSubject,
        code: '',
        department: cleanDept,
        course: cleanCourse,
        year: cleanYear,
        semester: cleanSemester,
        collegeId: targetCollegeId,
        createdBy: req.user._id,
        isDeleted: false,
      });
    }

    // Create Note Document in MongoDB Atlas
    const note = await Note.create({
      title: title.trim(),
      description: description.trim(),
      department: cleanDept,
      course: cleanCourse,
      year: cleanYear,
      semester: cleanSemester,
      subject: cleanSubject,
      fileUrl: fileUrl || '',
      publicId: publicId || '',
      fileName: fileName || '',
      fileSize: fileSize || '',
      collegeId: targetCollegeId,
      uploadedBy: req.user._id,
      isDeleted: false,
    });

    return res.status(201).json({
      success: true,
      data: note,
    });
  } catch (error) {
    console.error('createNote Error:', error);
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
    let note = await Note.findOne({ _id: req.params.id, isDeleted: { $ne: true } });
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

    if (req.body.subject) {
      req.body.subject = req.body.subject.trim().replace(/\s+/g, ' ');
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
    const note = await Note.findOne({ _id: req.params.id, isDeleted: { $ne: true } });
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

    note.isDeleted = true;
    note.deletedAt = new Date();
    note.deletedBy = req.user._id;
    await note.save();

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
