import '../models/content_model.dart';
import 'api_service.dart';

class NotesService {
  final ApiService _api = ApiService();

  Future<List<StudyContent>> getNotes({
    String? course,
    String? department,
    String? year,
    String? semester,
    String? subject,
    String? collegeId,
  }) async {
    final queryParams = <String, String>{};
    if (course != null && course.isNotEmpty) queryParams['course'] = course;
    if (department != null && department.isNotEmpty) queryParams['department'] = department;
    if (year != null && year.isNotEmpty) queryParams['year'] = year;
    if (semester != null && semester.isNotEmpty) queryParams['semester'] = semester;
    if (subject != null && subject.isNotEmpty) queryParams['subject'] = subject;
    if (collegeId != null && collegeId.isNotEmpty) queryParams['collegeId'] = collegeId;

    final response = await _api.get('/notes', queryParams: queryParams);

    final List data = response['data'] ?? [];
    return data.map((json) {
      json['type'] = 'Notes';
      return StudyContent.fromJson(json);
    }).toList();
  }

  Future<StudyContent> createNote(StudyContent note) async {
    final response = await _api.post('/notes', {
      'title': note.title,
      'description': note.description,
      'department': note.department,
      'course': note.course,
      'year': note.year,
      'semester': note.semester,
      'subject': note.subject,
      'fileUrl': note.fileUrl,
    });

    final json = response['data'];
    json['type'] = 'Notes';
    return StudyContent.fromJson(json);
  }

  Future<StudyContent> updateNote(StudyContent note) async {
    final response = await _api.put('/notes/${note.id}', {
      'title': note.title,
      'description': note.description,
      'department': note.department,
      'course': note.course,
      'year': note.year,
      'semester': note.semester,
      'subject': note.subject,
      'fileUrl': note.fileUrl,
    });

    final json = response['data'];
    json['type'] = 'Notes';
    return StudyContent.fromJson(json);
  }

  Future<void> deleteNote(String id) async {
    await _api.delete('/notes/$id');
  }
}
