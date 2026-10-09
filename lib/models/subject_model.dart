class SubjectItem {
  final String id;
  final String name;
  final String code;
  final String department;
  final String course;
  final String year;
  final String semester;
  final String collegeId;

  SubjectItem({
    required this.id,
    required this.name,
    this.code = '',
    this.department = 'Computer Science & Engineering',
    this.course = 'B.Tech',
    this.year = '2nd Year',
    this.semester = '3rd Semester',
    required this.collegeId,
  });

  factory SubjectItem.fromJson(Map<String, dynamic> json) {
    return SubjectItem(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      department: json['department'] ?? 'Computer Science & Engineering',
      course: json['course'] ?? 'B.Tech',
      year: json['year'] ?? '2nd Year',
      semester: json['semester'] ?? '3rd Semester',
      collegeId: json['collegeId'] is Map
          ? (json['collegeId']['_id'] ?? json['collegeId']['id'] ?? '')
          : (json['collegeId'] ?? 'col_svpuat'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'department': department,
      'course': course,
      'year': year,
      'semester': semester,
      'collegeId': collegeId,
    };
  }
}
