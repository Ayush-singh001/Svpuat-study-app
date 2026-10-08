import '../models/important_question_model.dart';
import 'api_service.dart';

class ImportantQuestionService {
  final ApiService _api = ApiService();

  Future<List<ImportantQuestion>> getImportantQuestions({
    String? course,
    String? department,
    String? year,
    String? semester,
    String? subject,
    String? search,
    String? collegeId,
  }) async {
    final queryParams = <String, String>{};
    if (course != null && course.isNotEmpty) queryParams['course'] = course;
    if (department != null && department.isNotEmpty) queryParams['department'] = department;
    if (year != null && year.isNotEmpty) queryParams['year'] = year;
    if (semester != null && semester.isNotEmpty) queryParams['semester'] = semester;
    if (subject != null && subject.isNotEmpty) queryParams['subject'] = subject;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (collegeId != null && collegeId.isNotEmpty) queryParams['collegeId'] = collegeId;

    final response = await _api.get('/important-questions', queryParams: queryParams);

    final List data = response['data'] ?? [];
    return data.map((json) => ImportantQuestion.fromJson(json)).toList();
  }

  Future<ImportantQuestion> createImportantQuestion(ImportantQuestion q) async {
    final response = await _api.post('/important-questions', {
      'question': q.question,
      'subject': q.subject,
      'department': q.department,
      'course': q.course,
      'year': q.year,
      'semester': q.semester,
      'unitTopic': q.unitTopic,
      'questionType': q.questionType,
      'difficulty': q.difficulty,
    });

    return ImportantQuestion.fromJson(response['data']);
  }

  Future<ImportantQuestion> updateImportantQuestion(ImportantQuestion q) async {
    final response = await _api.put('/important-questions/${q.id}', {
      'question': q.question,
      'subject': q.subject,
      'department': q.department,
      'course': q.course,
      'year': q.year,
      'semester': q.semester,
      'unitTopic': q.unitTopic,
      'questionType': q.questionType,
      'difficulty': q.difficulty,
    });

    return ImportantQuestion.fromJson(response['data']);
  }

  Future<void> deleteImportantQuestion(String id) async {
    await _api.delete('/important-questions/$id');
  }
}
