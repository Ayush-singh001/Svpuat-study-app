const mongoose = require('mongoose');
const Note = require('../models/Note');
const QuestionPaper = require('../models/QuestionPaper');
const Syllabus = require('../models/Syllabus');
const ImportantQuestion = require('../models/ImportantQuestion');
const College = require('../models/College');

// @desc    Get distinct subject names from materials and questions
// @route   GET /api/subjects
// @access  Public / Private (Admin & Student)
const getSubjects = async (req, res) => {
  try {
    const { collegeId, course, department, year, semester } = req.query;

    const filter = { isDeleted: { $ne: true } };

    const svpuat = await College.findOne({ code: 'SVPUAT' });
    const svpuatId = svpuat ? svpuat._id : null;

    if (collegeId && collegeId !== 'col_svpuat') {
      if (!mongoose.Types.ObjectId.isValid(collegeId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid college ID format provided',
        });
      }
      const targetCollegeId = new mongoose.Types.ObjectId(collegeId);
      if (svpuatId && !targetCollegeId.equals(svpuatId)) {
        filter.$or = [
          { collegeId: targetCollegeId },
          { collegeId: svpuatId },
        ];
      } else {
        filter.collegeId = targetCollegeId;
      }
    } else if (svpuatId) {
      filter.collegeId = svpuatId;
    }

    if (course && course.trim()) filter.course = course.trim();
    if (year && year.trim()) filter.year = year.trim();
    if (semester && semester.trim()) filter.semester = semester.trim();
    if (department && department.trim()) {
      filter.department = { $regex: department.trim(), $options: 'i' };
    }

    // Query distinct subject names across materials and questions
    let [noteSubjects, paperSubjects, syllabusSubjects, questionSubjects] = await Promise.all([
      Note.distinct('subject', filter),
      QuestionPaper.distinct('subject', filter),
      Syllabus.distinct('subject', filter),
      ImportantQuestion.distinct('subject', filter),
    ]);

    let allRaw = [...noteSubjects, ...paperSubjects, ...syllabusSubjects, ...questionSubjects];

    // Fallback: If no subjects found for specific department, query subjects for college/course/year/semester
    if (allRaw.length === 0 && filter.department) {
      const fallbackFilter = { ...filter };
      delete fallbackFilter.department;

      const [fNotes, fPapers, fSyllabus, fQuestions] = await Promise.all([
        Note.distinct('subject', fallbackFilter),
        QuestionPaper.distinct('subject', fallbackFilter),
        Syllabus.distinct('subject', fallbackFilter),
        ImportantQuestion.distinct('subject', fallbackFilter),
      ]);
      allRaw = [...fNotes, ...fPapers, ...fSyllabus, ...fQuestions];
    }

    const uniqueMap = new Map();

    for (const raw of allRaw) {
      if (!raw || typeof raw !== 'string') continue;
      const clean = raw.trim().replace(/\s+/g, ' ');
      if (clean.length < 2) continue;
      const lower = clean.toLowerCase();
      if (!uniqueMap.has(lower)) {
        uniqueMap.set(lower, clean);
      }
    }

    const sortedSubjects = Array.from(uniqueMap.values()).sort((a, b) => a.localeCompare(b));

    return res.status(200).json({
      success: true,
      count: sortedSubjects.length,
      data: sortedSubjects,
    });
  } catch (error) {
    console.error('getSubjects Controller Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error retrieving subjects',
    });
  }
};

module.exports = {
  getSubjects,
};
