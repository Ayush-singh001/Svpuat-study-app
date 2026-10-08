class AppConstants {
  static const String appName = 'SVPUAT Study Hub';
  static const String appVersion = '1.0.0';
  static const String svpuatFullName =
      'Sardar Vallabhbhai Patel University of Agriculture & Technology';
  static const String svpuatLocation = 'Meerut, Uttar Pradesh';
  static const String svpuatCode = 'SVPUAT';
  static const String svpuatCollegeId = 'col_svpuat';

  // User Roles
  static const String roleStudent = 'Student';
  static const String roleCollegeAdmin = 'College Admin';
  static const String roleSuperAdmin = 'Super Admin';

  // Content Types
  static const String typeNotes = 'Notes';
  static const String typeQuestionPaper = 'Question Paper';
  static const String typeSyllabus = 'Syllabus';
  static const String typeNotice = 'Notice';

  // Exam Types for Question Papers
  static const List<String> examTypes = [
    'Mid-Term Exam',
    'End-Term Exam',
    'Quiz / Class Test',
    'Practical Exam',
  ];

  // Configurable Academic Structure
  static const List<String> courses = [
    'B.Tech',
    'B.Sc (Hons) Agriculture',
    'B.Tech Biotechnology',
    'M.Tech',
    'M.Sc Agriculture',
  ];

  static const List<String> departments = [
    'Computer Science & Engineering',
    'Agricultural Engineering',
    'Biotechnology',
    'Agronomy',
    'Horticulture',
    'Soil Science',
    'Genetics & Plant Breeding',
  ];

  static const List<String> years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  static const List<String> semesters = [
    '1st Semester',
    '2nd Semester',
    '3rd Semester',
    '4th Semester',
    '5th Semester',
    '6th Semester',
    '7th Semester',
    '8th Semester',
  ];

  // Map of Subjects by Course & Semester
  static const Map<String, List<String>> subjectsByCourseAndSemester = {
    'B.Tech_3rd Semester': [
      'Data Structures & Algorithms',
      'Database Management Systems',
      'Discrete Mathematics',
      'Digital Logic Design',
      'Object Oriented Programming in C++',
    ],
    'B.Tech_4th Semester': [
      'Operating Systems',
      'Computer Networks',
      'Theory of Computation',
      'Software Engineering',
      'Computer Architecture',
    ],
    'B.Sc (Hons) Agriculture_3rd Semester': [
      'Crop Production Technology',
      'Soil Fertility & Fertilizer Use',
      'Agricultural Economics',
      'Insect Pest Management',
      'Fundamentals of Plant Pathology',
    ],
    'B.Tech Biotechnology_3rd Semester': [
      'Cell Biology & Genetics',
      'Bioprocess Engineering',
      'Microbiology',
      'Biochemistry',
      'Molecular Biology',
    ],
  };

  // Primary University
  static const List<Map<String, String>> initialColleges = [
    {
      'id': svpuatCollegeId,
      'name': svpuatFullName,
      'code': svpuatCode,
      'location': svpuatLocation,
      'description':
          'Premier Agricultural and Technological State University established in 2000.',
    },
  ];
}
