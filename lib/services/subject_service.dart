import '../models/subject_model.dart';
import 'api_service.dart';

class SubjectService {
  final ApiService _api = ApiService();

  Future<List<SubjectItem>> getSubjects({
    String? course,
    String? department,
    String? year,
    String? semester,
    String? collegeId,
  }) async {
    final queryParams = <String, String>{};
    if (course != null) queryParams['course'] = course;
    if (department != null) queryParams['department'] = department;
    if (year != null) queryParams['year'] = year;
    if (semester != null) queryParams['semester'] = semester;
    if (collegeId != null) queryParams['collegeId'] = collegeId;

    final response = await _api.get('/subjects', queryParams: queryParams);
    final List data = response['data'] ?? [];
    return data.map((json) => SubjectItem.fromJson(json)).toList();
  }

  Future<SubjectItem> createSubject({
    required String name,
    String? code,
    String? department,
    String? course,
    String? year,
    String? semester,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
    };
    if (code != null) payload['code'] = code;
    if (department != null) payload['department'] = department;
    if (course != null) payload['course'] = course;
    if (year != null) payload['year'] = year;
    if (semester != null) payload['semester'] = semester;

    final response = await _api.post('/subjects', payload);
    return SubjectItem.fromJson(response['data']);
  }

  Future<SubjectItem> updateSubject({
    required String id,
    required String name,
    String? code,
    String? department,
    String? course,
    String? year,
    String? semester,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
    };
    if (code != null) payload['code'] = code;
    if (department != null) payload['department'] = department;
    if (course != null) payload['course'] = course;
    if (year != null) payload['year'] = year;
    if (semester != null) payload['semester'] = semester;

    final response = await _api.put('/subjects/$id', payload);
    return SubjectItem.fromJson(response['data']);
  }

  Future<bool> deleteSubject(String id) async {
    final response = await _api.delete('/subjects/$id');
    return response['success'] == true;
  }
}
