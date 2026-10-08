class AppNotification {
  final String id;
  final String title;
  final String message;
  final String contentType; // 'Notice', 'Notes', 'Question Paper', 'Syllabus', 'Important Question', 'General'
  final String? contentId;
  final String? department;
  final String collegeId;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.contentType = 'General',
    this.contentId,
    this.department,
    required this.collegeId,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      contentType: json['contentType'] ?? 'General',
      contentId: json['contentId'],
      department: json['department'],
      collegeId: json['collegeId'] ?? 'col_svpuat',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'contentType': contentType,
      'contentId': contentId,
      'department': department,
      'collegeId': collegeId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
