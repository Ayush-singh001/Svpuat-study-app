class ImportantQuestion {
  final String id;
  final String question;
  final String subject;
  final String? department;
  final String? course;
  final String? year;
  final String? semester;
  final String unitTopic;
  final String questionType; // 'Short Answer', 'Long Answer', 'Numerical', 'Theory', 'MCQ'
  final String difficulty; // 'Easy', 'Medium', 'Hard'
  final String collegeId;
  final DateTime createdAt;

  ImportantQuestion({
    required this.id,
    required this.question,
    required this.subject,
    this.department,
    this.course,
    this.year,
    this.semester,
    this.unitTopic = 'General Topic',
    this.questionType = 'Long Answer',
    this.difficulty = 'Medium',
    required this.collegeId,
    required this.createdAt,
  });

  factory ImportantQuestion.fromJson(Map<String, dynamic> json) {
    return ImportantQuestion(
      id: json['id'] ?? json['_id'] ?? '',
      question: json['question'] ?? '',
      subject: json['subject'] ?? '',
      department: json['department'],
      course: json['course'],
      year: json['year'],
      semester: json['semester'],
      unitTopic: json['unitTopic'] ?? 'General Topic',
      questionType: json['questionType'] ?? 'Long Answer',
      difficulty: json['difficulty'] ?? 'Medium',
      collegeId: json['collegeId'] ?? 'col_svpuat',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'subject': subject,
      'department': department,
      'course': course,
      'year': year,
      'semester': semester,
      'unitTopic': unitTopic,
      'questionType': questionType,
      'difficulty': difficulty,
      'collegeId': collegeId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
