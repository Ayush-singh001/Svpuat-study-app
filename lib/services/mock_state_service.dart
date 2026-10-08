import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/college_model.dart';
import '../models/content_model.dart';
import '../models/important_question_model.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'college_service.dart';
import 'important_question_service.dart';
import 'notes_service.dart';
import 'notice_service.dart';
import 'question_paper_service.dart';
import 'syllabus_service.dart';

class MockStateService extends ChangeNotifier {
  static final MockStateService _instance = MockStateService._internal();
  factory MockStateService() => _instance;
  MockStateService._internal() {
    _initialize();
  }

  final AuthService _authService = AuthService();
  final CollegeService _collegeService = CollegeService();
  final NotesService _notesService = NotesService();
  final QuestionPaperService _paperService = QuestionPaperService();
  final SyllabusService _syllabusService = SyllabusService();
  final NoticeService _noticeService = NoticeService();
  final ImportantQuestionService _importantQuestionService = ImportantQuestionService();

  AppUser? _currentUser;
  College? _selectedCollege;
  final List<College> _colleges = [];
  final List<StudyContent> _contents = [];
  final List<ImportantQuestion> _importantQuestions = [];

  // Getters
  AppUser? get currentUser => _currentUser;
  College? get selectedCollege => _selectedCollege;
  List<College> get colleges => List.unmodifiable(_colleges);
  List<ImportantQuestion> get importantQuestions => List.unmodifiable(_importantQuestions);
  bool get isLoggedIn => _currentUser != null;

  void setCurrentUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> initSession() async {
    await ApiService().init();
    try {
      final user = await _authService.getMe();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _initialize() async {
    await initSession();
    await fetchRealColleges();

    _loadSampleContents();
    _loadSampleQuestions();
    notifyListeners();
  }

  Future<List<College>> fetchRealColleges() async {
    try {
      final realColleges = await _collegeService.getColleges();
      if (realColleges.isNotEmpty) {
        _colleges.clear();
        _colleges.addAll(realColleges);
        _selectedCollege ??= _colleges.first;
        notifyListeners();
        return _colleges;
      }
    } catch (_) {}

    if (_colleges.isEmpty) {
      for (var colMap in AppConstants.initialColleges) {
        _colleges.add(College(
          id: colMap['id']!,
          name: colMap['name']!,
          code: colMap['code']!,
          location: colMap['location']!,
          description: colMap['description']!,
        ));
      }
      if (_colleges.isNotEmpty) {
        _selectedCollege = _colleges.first;
      }
    }
    return _colleges;
  }

  void _loadSampleContents() {
    if (_contents.isNotEmpty) return;
    _contents.addAll([
      StudyContent(
        id: 'svp_101',
        title: 'Data Structures & Algorithms Unit 1 - Trees & Graphs',
        description:
            'Comprehensive lecture notes covering Binary Trees, AVL Trees, B-Trees, Graph Traversals (BFS, DFS), and Shortest Path Algorithms.',
        type: AppConstants.typeNotes,
        collegeId: AppConstants.svpuatCollegeId,
        course: 'B.Tech',
        department: 'Computer Science & Engineering',
        year: '2nd Year',
        semester: '3rd Semester',
        subject: 'Data Structures & Algorithms',
        fileUrl: '',
        fileName: 'SVPUAT_DSA_Unit1_Notes.pdf',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        uploadedBy: 'Dr. R.K. Singh (CSE Dept)',
      ),
      StudyContent(
        id: 'svp_102',
        title: 'Database Management Systems - Relational Algebra & SQL',
        description:
            'Complete class notes on ER Modeling, Normalization (1NF to 3NF, BCNF), and advanced SQL queries with examples.',
        type: AppConstants.typeNotes,
        collegeId: AppConstants.svpuatCollegeId,
        course: 'B.Tech',
        department: 'Computer Science & Engineering',
        year: '2nd Year',
        semester: '3rd Semester',
        subject: 'Database Management Systems',
        fileUrl: '',
        fileName: 'SVPUAT_DBMS_Notes.pdf',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        uploadedBy: 'Prof. Anil Kumar',
      ),
      StudyContent(
        id: 'svp_201',
        title: 'Mid-Term Exam 2024 - Database Management Systems',
        description:
            'Official SVPUAT Mid-Term Question Paper for 3rd Semester B.Tech CS.',
        type: AppConstants.typeQuestionPaper,
        collegeId: AppConstants.svpuatCollegeId,
        course: 'B.Tech',
        department: 'Computer Science & Engineering',
        year: '2nd Year',
        semester: '3rd Semester',
        subject: 'Database Management Systems',
        examType: 'Mid-Term Exam',
        paperYear: '2024',
        fileUrl: '',
        fileName: 'SVPUAT_DBMS_Mid2024_Paper.pdf',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        uploadedBy: 'SVPUAT Examination Cell',
      ),
      StudyContent(
        id: 'svp_301',
        title: 'B.Tech CS Engineering Complete Curriculum & Syllabus (2024-2028)',
        description:
            'Official approved course scheme, credit structure, and detailed unit-wise syllabus for B.Tech CSE.',
        type: AppConstants.typeSyllabus,
        collegeId: AppConstants.svpuatCollegeId,
        course: 'B.Tech',
        department: 'Computer Science & Engineering',
        year: 'All Years',
        semester: 'All Semesters',
        fileUrl: '',
        fileName: 'SVPUAT_BTech_CS_Syllabus.pdf',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        uploadedBy: 'Dean Academics',
      ),
      StudyContent(
        id: 'svp_401',
        title: 'Mid-Term Examination Schedule Announcement - Odd Semester 2024',
        description:
            'Mid-Term exams for all B.Tech and B.Sc courses will commence from Nov 18. Students must bring their university ID cards.',
        type: AppConstants.typeNotice,
        collegeId: AppConstants.svpuatCollegeId,
        department: 'All Departments',
        semester: 'All Semesters',
        fileUrl: '',
        fileName: 'SVPUAT_Exam_Notice_Nov2024.pdf',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        uploadedBy: 'Office of Registrar',
      ),
    ]);
  }

  void _loadSampleQuestions() {
    if (_importantQuestions.isNotEmpty) return;
    _importantQuestions.addAll([
      ImportantQuestion(
        id: 'iq_101',
        question:
            'Explain Dijkstra\'s Shortest Path Algorithm with a step-by-step trace on a weighted directed graph of 5 vertices.',
        subject: 'Data Structures & Algorithms',
        course: 'B.Tech',
        department: 'Computer Science & Engineering',
        year: '2nd Year',
        semester: '3rd Semester',
        unitTopic: 'Unit 4 - Graphs & Shortest Path',
        questionType: 'Long Answer',
        difficulty: 'Hard',
        collegeId: AppConstants.svpuatCollegeId,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ImportantQuestion(
        id: 'iq_102',
        question:
            'What is BCNF (Boyce-Codd Normal Form)? How does it differ from 3NF? Give a concrete relation schema example.',
        subject: 'Database Management Systems',
        course: 'B.Tech',
        department: 'Computer Science & Engineering',
        year: '2nd Year',
        semester: '3rd Semester',
        unitTopic: 'Unit 3 - Normalization & Relational Design',
        questionType: 'Theory',
        difficulty: 'Medium',
        collegeId: AppConstants.svpuatCollegeId,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      ImportantQuestion(
        id: 'iq_103',
        question:
            'Differentiate between Preorder, Inorder, and Postorder Binary Tree Traversals. Write recursive functions for Inorder traversal in C/C++.',
        subject: 'Data Structures & Algorithms',
        course: 'B.Tech',
        department: 'Computer Science & Engineering',
        year: '2nd Year',
        semester: '3rd Semester',
        unitTopic: 'Unit 2 - Trees & Binary Search Trees',
        questionType: 'Short Answer',
        difficulty: 'Easy',
        collegeId: AppConstants.svpuatCollegeId,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ]);
  }

  // Real Auth Integration
  Future<bool> loginReal({
    required String identifier,
    required String password,
    required String role,
  }) async {
    try {
      final user = await _authService.login(
        identifier: identifier,
        password: password,
      );
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return login(identifier, password, role);
    }
  }

  bool login(String identifier, String password, String role) {
    if (identifier.isEmpty || password.isEmpty) return false;

    _currentUser = AppUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: identifier.contains('@')
          ? identifier.split('@').first.toUpperCase()
          : 'Student $identifier',
      email: identifier.contains('@') ? identifier : '$identifier@svpuat.ac.in',
      mobile: '9876543210',
      studentId: identifier.contains('@') ? 'SVP202401' : identifier,
      role: role,
      collegeId: AppConstants.svpuatCollegeId,
      collegeName: AppConstants.svpuatFullName,
      course: 'B.Tech',
      department: 'Computer Science & Engineering',
      year: '2nd Year',
      semester: '3rd Semester',
    );

    notifyListeners();
    return true;
  }

  Future<bool> registerReal({
    required String name,
    required String email,
    required String mobile,
    required String studentId,
    required String password,
    required String course,
    required String department,
    required String year,
    required String semester,
  }) async {
    try {
      final user = await _authService.register(
        fullName: name,
        email: email,
        mobile: mobile,
        studentId: studentId,
        password: password,
        course: course,
        department: department,
        year: year,
        semester: semester,
      );
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return register(
        name: name,
        email: email,
        mobile: mobile,
        studentId: studentId,
        password: password,
        course: course,
        department: department,
        year: year,
        semester: semester,
      );
    }
  }

  bool register({
    required String name,
    required String email,
    required String mobile,
    required String studentId,
    required String password,
    required String course,
    required String department,
    required String year,
    required String semester,
  }) {
    _currentUser = AppUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      mobile: mobile,
      studentId: studentId,
      role: AppConstants.roleStudent,
      collegeId: AppConstants.svpuatCollegeId,
      collegeName: AppConstants.svpuatFullName,
      course: course,
      department: department,
      year: year,
      semester: semester,
    );

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  void selectCollege(College college) {
    _selectedCollege = college;
    notifyListeners();
  }

  Future<void> addCollegeReal(College college) async {
    try {
      final created = await _collegeService.createCollege(
        name: college.name,
        code: college.code,
        location: college.location,
        description: college.description,
      );
      _colleges.add(created);
    } catch (_) {
      addCollege(college);
    }
    notifyListeners();
  }

  void addCollege(College college) {
    _colleges.add(college);
    notifyListeners();
  }

  void editCollege(College updatedCollege) {
    final index = _colleges.indexWhere((c) => c.id == updatedCollege.id);
    if (index != -1) {
      _colleges[index] = updatedCollege;
      notifyListeners();
    }
  }

  Future<void> deleteCollegeReal(String collegeId) async {
    try {
      await _collegeService.deleteCollege(collegeId);
    } catch (_) {}
    deleteCollege(collegeId);
  }

  void deleteCollege(String collegeId) {
    _colleges.removeWhere((c) => c.id == collegeId);
    _contents.removeWhere((c) => c.collegeId == collegeId);
    _importantQuestions.removeWhere((q) => q.collegeId == collegeId);
    notifyListeners();
  }

  // Important Questions Real API & Local Fallback
  Future<List<ImportantQuestion>> fetchRealImportantQuestions({
    String? course,
    String? department,
    String? year,
    String? semester,
    String? subject,
    String? search,
  }) async {
    try {
      final questions = await _importantQuestionService.getImportantQuestions(
        course: course,
        department: department,
        year: year,
        semester: semester,
        subject: subject,
        search: search,
      );
      if (questions.isNotEmpty) return questions;
    } catch (_) {}

    return getImportantQuestionsLocal(
      course: course,
      department: department,
      year: year,
      semester: semester,
      subject: subject,
      search: search,
    );
  }

  List<ImportantQuestion> getImportantQuestionsLocal({
    String? course,
    String? department,
    String? year,
    String? semester,
    String? subject,
    String? search,
  }) {
    return _importantQuestions.where((q) {
      bool matches = true;
      if (course != null && course.isNotEmpty && q.course != null) {
        matches = matches && (q.course == course || q.course == 'All Courses');
      }
      if (department != null && department.isNotEmpty && q.department != null) {
        matches = matches && (q.department == department || q.department == 'All Departments');
      }
      if (year != null && year.isNotEmpty && q.year != null) {
        matches = matches && (q.year == year || q.year == 'All Years');
      }
      if (semester != null && semester.isNotEmpty && q.semester != null) {
        matches = matches && (q.semester == semester || q.semester == 'All Semesters');
      }
      if (subject != null && subject.isNotEmpty) {
        matches = matches && q.subject.toLowerCase().contains(subject.toLowerCase());
      }
      if (search != null && search.isNotEmpty) {
        final query = search.toLowerCase();
        matches = matches &&
            (q.question.toLowerCase().contains(query) ||
                q.unitTopic.toLowerCase().contains(query) ||
                q.subject.toLowerCase().contains(query));
      }
      return matches;
    }).toList();
  }

  Future<void> addImportantQuestionReal(ImportantQuestion q) async {
    try {
      final created = await _importantQuestionService.createImportantQuestion(q);
      _importantQuestions.insert(0, created);
    } catch (_) {
      _importantQuestions.insert(0, q);
    }
    notifyListeners();
  }

  Future<void> updateImportantQuestionReal(ImportantQuestion q) async {
    try {
      final updated = await _importantQuestionService.updateImportantQuestion(q);
      final index = _importantQuestions.indexWhere((item) => item.id == updated.id);
      if (index != -1) _importantQuestions[index] = updated;
    } catch (_) {
      final index = _importantQuestions.indexWhere((item) => item.id == q.id);
      if (index != -1) _importantQuestions[index] = q;
    }
    notifyListeners();
  }

  Future<void> deleteImportantQuestionReal(String id) async {
    try {
      await _importantQuestionService.deleteImportantQuestion(id);
    } catch (_) {}
    _importantQuestions.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Content Filtering
  List<StudyContent> getContentsByCollege(
    String collegeId, {
    String? type,
    String? course,
    String? department,
    String? year,
    String? semester,
    String? subject,
  }) {
    return _contents.where((c) {
      bool matches = c.collegeId == collegeId;
      if (type != null && type.isNotEmpty) {
        matches = matches && c.type == type;
      }
      if (course != null && course.isNotEmpty && c.course != null) {
        matches = matches && (c.course == course || c.course == 'All Courses');
      }
      if (department != null && department.isNotEmpty && c.department != null) {
        matches = matches &&
            (c.department == department || c.department == 'All Departments');
      }
      if (year != null && year.isNotEmpty && c.year != null) {
        matches = matches && (c.year == year || c.year == 'All Years');
      }
      if (semester != null && semester.isNotEmpty && c.semester != null) {
        matches = matches && (c.semester == semester || c.semester == 'All Semesters');
      }
      if (subject != null && subject.isNotEmpty && c.subject != null) {
        matches = matches && c.subject!.toLowerCase().contains(subject.toLowerCase());
      }
      return matches;
    }).toList();
  }

  // Fetch real content from API with async capability
  Future<List<StudyContent>> fetchRealNotes({
    String? course,
    String? department,
    String? year,
    String? semester,
    String? subject,
  }) async {
    try {
      final notes = await _notesService.getNotes(
        course: course,
        department: department,
        year: year,
        semester: semester,
        subject: subject,
      );
      return notes;
    } catch (_) {
      return getContentsByCollege(
        AppConstants.svpuatCollegeId,
        type: AppConstants.typeNotes,
        course: course,
        department: department,
        year: year,
        semester: semester,
        subject: subject,
      );
    }
  }

  Future<List<StudyContent>> fetchRealQuestionPapers({
    String? course,
    String? department,
    String? year,
    String? semester,
    String? subject,
    String? examType,
  }) async {
    try {
      final papers = await _paperService.getQuestionPapers(
        course: course,
        department: department,
        year: year,
        semester: semester,
        subject: subject,
        examType: examType,
      );
      return papers;
    } catch (_) {
      return getContentsByCollege(
        AppConstants.svpuatCollegeId,
        type: AppConstants.typeQuestionPaper,
        course: course,
        department: department,
        year: year,
        semester: semester,
        subject: subject,
      );
    }
  }

  Future<List<StudyContent>> fetchRealSyllabus({
    String? course,
    String? department,
    String? year,
    String? semester,
  }) async {
    try {
      final list = await _syllabusService.getSyllabus(
        course: course,
        department: department,
        year: year,
        semester: semester,
      );
      return list;
    } catch (_) {
      return getContentsByCollege(
        AppConstants.svpuatCollegeId,
        type: AppConstants.typeSyllabus,
        course: course,
        department: department,
        year: year,
        semester: semester,
      );
    }
  }

  Future<List<StudyContent>> fetchRealNotices({String? department}) async {
    try {
      final list = await _noticeService.getNotices(department: department);
      return list;
    } catch (_) {
      return getContentsByCollege(
        AppConstants.svpuatCollegeId,
        type: AppConstants.typeNotice,
        department: department,
      );
    }
  }

  // Real API Add Content
  Future<void> addContentReal(StudyContent content) async {
    try {
      if (content.type == AppConstants.typeNotes) {
        final newNote = await _notesService.createNote(content);
        _contents.insert(0, newNote);
      } else if (content.type == AppConstants.typeQuestionPaper) {
        final newPaper = await _paperService.createQuestionPaper(content);
        _contents.insert(0, newPaper);
      } else if (content.type == AppConstants.typeSyllabus) {
        final newSyllabus = await _syllabusService.createSyllabus(content);
        _contents.insert(0, newSyllabus);
      } else if (content.type == AppConstants.typeNotice) {
        final newNotice = await _noticeService.createNotice(content);
        _contents.insert(0, newNotice);
      }
    } catch (_) {
      addContent(content);
    }
    notifyListeners();
  }

  void addContent(StudyContent content) {
    _contents.insert(0, content);
    notifyListeners();
  }

  void updateContent(StudyContent content) {
    final index = _contents.indexWhere((c) => c.id == content.id);
    if (index != -1) {
      _contents[index] = content;
      notifyListeners();
    }
  }

  Future<void> deleteContentReal(String contentId, String type) async {
    try {
      if (type == AppConstants.typeNotes) {
        await _notesService.deleteNote(contentId);
      } else if (type == AppConstants.typeQuestionPaper) {
        await _paperService.deleteQuestionPaper(contentId);
      } else if (type == AppConstants.typeSyllabus) {
        await _syllabusService.deleteSyllabus(contentId);
      } else if (type == AppConstants.typeNotice) {
        await _noticeService.deleteNotice(contentId);
      }
    } catch (_) {}
    deleteContent(contentId);
  }

  void deleteContent(String contentId) {
    _contents.removeWhere((c) => c.id == contentId);
    notifyListeners();
  }
}
