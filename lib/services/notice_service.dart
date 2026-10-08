import '../models/content_model.dart';
import 'api_service.dart';

class NoticeService {
  final ApiService _api = ApiService();

  Future<List<StudyContent>> getNotices({
    String? department,
    String? collegeId,
  }) async {
    final queryParams = <String, String>{};
    if (department != null && department.isNotEmpty) queryParams['department'] = department;
    if (collegeId != null && collegeId.isNotEmpty) queryParams['collegeId'] = collegeId;

    final response = await _api.get('/notices', queryParams: queryParams);

    final List data = response['data'] ?? [];
    return data.map((json) {
      json['type'] = 'Notice';
      return StudyContent.fromJson(json);
    }).toList();
  }

  Future<StudyContent> createNotice(StudyContent notice) async {
    final response = await _api.post('/notices', {
      'title': notice.title,
      'description': notice.description,
      'attachmentUrl': notice.fileUrl,
      'department': notice.department,
    });

    final json = response['data'];
    json['type'] = 'Notice';
    return StudyContent.fromJson(json);
  }

  Future<StudyContent> updateNotice(StudyContent notice) async {
    final response = await _api.put('/notices/${notice.id}', {
      'title': notice.title,
      'description': notice.description,
      'attachmentUrl': notice.fileUrl,
      'department': notice.department,
    });

    final json = response['data'];
    json['type'] = 'Notice';
    return StudyContent.fromJson(json);
  }

  Future<void> deleteNotice(String id) async {
    await _api.delete('/notices/$id');
  }
}
