import '../models/content_model.dart';
import 'api_service.dart';

class QuestionPaperService {
  final ApiService _api = ApiService();

  Future<List<StudyContent>> getQuestionPapers({
    String? course,
    String? department,
    String? year,
    String? semester,
    String? subject,
    String? examType,
    String? collegeId,
  }) async {
    final queryParams = <String, String>{};
    if (course != null && course.isNotEmpty) queryParams['course'] = course;
    if (department != null && department.isNotEmpty) queryParams['department'] = department;
    if (year != null && year.isNotEmpty) queryParams['year'] = year;
    if (semester != null && semester.isNotEmpty) queryParams['semester'] = semester;
    if (subject != null && subject.isNotEmpty) queryParams['subject'] = subject;
    if (examType != null && examType.isNotEmpty) queryParams['examType'] = examType;
    if (collegeId != null && collegeId.isNotEmpty) queryParams['collegeId'] = collegeId;

    final response = await _api.get('/question-papers', queryParams: queryParams);

    final List data = response['data'] ?? [];
    return data.map((json) {
      json['type'] = 'Question Paper';
      return StudyContent.fromJson(json);
    }).toList();
  }

  Future<StudyContent> createQuestionPaper(StudyContent paper) async {
    final response = await _api.post('/question-papers', {
      'title': paper.title,
      'subject': paper.subject,
      'department': paper.department,
      'course': paper.course,
      'year': paper.year,
      'semester': paper.semester,
      'examType': paper.examType,
      'paperYear': paper.paperYear,
      'fileUrl': paper.fileUrl,
    });

    final json = response['data'];
    json['type'] = 'Question Paper';
    return StudyContent.fromJson(json);
  }

  Future<StudyContent> updateQuestionPaper(StudyContent paper) async {
    final response = await _api.put('/question-papers/${paper.id}', {
      'title': paper.title,
      'subject': paper.subject,
      'department': paper.department,
      'course': paper.course,
      'year': paper.year,
      'semester': paper.semester,
      'examType': paper.examType,
      'paperYear': paper.paperYear,
      'fileUrl': paper.fileUrl,
    });

    final json = response['data'];
    json['type'] = 'Question Paper';
    return StudyContent.fromJson(json);
  }

  Future<void> deleteQuestionPaper(String id) async {
    await _api.delete('/question-papers/$id');
  }
}
