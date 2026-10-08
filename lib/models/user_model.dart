class AppUser {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String studentId; // Roll Number / Student ID
  final String role; // 'student', 'collegeAdmin', 'superAdmin'
  final String collegeId;
  final String collegeName;
  final String? course;
  final String? department;
  final String? year;
  final String? semester;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.mobile = '',
    this.studentId = '',
    required this.role,
    required this.collegeId,
    required this.collegeName,
    this.course,
    this.department,
    this.year,
    this.semester,
  });

  String get fullName => name;
  bool get isStudent => role == 'student' || role == 'Student';
  bool get isCollegeAdmin => role == 'collegeAdmin' || role == 'College Admin';
  bool get isSuperAdmin => role == 'superAdmin' || role == 'Super Admin';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['fullName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      studentId: json['studentId'] ?? json['rollNumber'] ?? '',
      role: json['role'] ?? 'student',
      collegeId: json['collegeId'] ?? 'col_svpuat',
      collegeName: json['collegeName'] ??
          'Sardar Vallabhbhai Patel University of Agriculture & Technology',
      course: json['course'],
      department: json['department'],
      year: json['year'],
      semester: json['semester'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': name,
      'name': name,
      'email': email,
      'mobile': mobile,
      'studentId': studentId,
      'role': role,
      'collegeId': collegeId,
      'collegeName': collegeName,
      'course': course,
      'department': department,
      'year': year,
      'semester': semester,
    };
  }
}
