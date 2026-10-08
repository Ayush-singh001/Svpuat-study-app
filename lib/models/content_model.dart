class StudyContent {
  final String id;
  final String title;
  final String description;
  final String type; // 'Notes', 'Question Paper', 'Syllabus', 'Notice'
  final String collegeId;
  final String? course;
  final String? department;
  final String? year;
  final String? semester;
  final String? subject;
  final String? examType; // 'Mid-Term Exam', 'End-Term Exam', etc.
  final String? paperYear; // e.g., '2024'
  final String? fileUrl;
  final String? publicId;
  final String? fileName;
  final String? fileSize;
  final DateTime createdAt;
  final String uploadedBy;

  StudyContent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.collegeId,
    this.course,
    this.department,
    this.year,
    this.semester,
    this.subject,
    this.examType,
    this.paperYear,
    this.fileUrl,
    this.publicId,
    this.fileName,
    this.fileSize,
    required this.createdAt,
    required this.uploadedBy,
  });

  factory StudyContent.fromJson(Map<String, dynamic> json) {
    return StudyContent(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'Notes',
      collegeId: json['collegeId'] ?? 'col_svpuat',
      course: json['course'],
      department: json['department'],
      year: json['year'],
      semester: json['semester'],
      subject: json['subject'],
      examType: json['examType'],
      paperYear: json['paperYear'],
      fileUrl: json['fileUrl'],
      publicId: json['publicId'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      uploadedBy: json['uploadedBy'] ?? 'Admin',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'collegeId': collegeId,
      'course': course,
      'department': department,
      'year': year,
      'semester': semester,
      'subject': subject,
      'examType': examType,
      'paperYear': paperYear,
      'fileUrl': fileUrl,
      'publicId': publicId,
      'fileName': fileName,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
      'uploadedBy': uploadedBy,
    };
  }
}
