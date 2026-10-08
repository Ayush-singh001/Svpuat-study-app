import '../models/content_model.dart';
import 'api_service.dart';

class SyllabusService {
  final ApiService _api = ApiService();

  Future<List<StudyContent>> getSyllabus({
    String? course,
    String? department,
    String? year,
    String? semester,
    String? collegeId,
  }) async {
    final queryParams = <String, String>{};
    if (course != null && course.isNotEmpty) queryParams['course'] = course;
    if (department != null && department.isNotEmpty) queryParams['department'] = department;
    if (year != null && year.isNotEmpty) queryParams['year'] = year;
    if (semester != null && semester.isNotEmpty) queryParams['semester'] = semester;
    if (collegeId != null && collegeId.isNotEmpty) queryParams['collegeId'] = collegeId;

    final response = await _api.get('/syllabus', queryParams: queryParams);

    final List data = response['data'] ?? [];
    return data.map((json) {
      json['type'] = 'Syllabus';
      return StudyContent.fromJson(json);
    }).toList();
  }

  Future<StudyContent> createSyllabus(StudyContent syllabus) async {
    final response = await _api.post('/syllabus', {
      'title': syllabus.title,
      'department': syllabus.department,
      'course': syllabus.course,
      'year': syllabus.year,
      'semester': syllabus.semester,
      'fileUrl': syllabus.fileUrl,
    });

    final json = response['data'];
    json['type'] = 'Syllabus';
    return StudyContent.fromJson(json);
  }

  Future<StudyContent> updateSyllabus(StudyContent syllabus) async {
    final response = await _api.put('/syllabus/${syllabus.id}', {
      'title': syllabus.title,
      'department': syllabus.department,
      'course': syllabus.course,
      'year': syllabus.year,
      'semester': syllabus.semester,
      'fileUrl': syllabus.fileUrl,
    });

    final json = response['data'];
    json['type'] = 'Syllabus';
    return StudyContent.fromJson(json);
  }

  Future<void> deleteSyllabus(String id) async {
    await _api.delete('/syllabus/$id');
  }
}
