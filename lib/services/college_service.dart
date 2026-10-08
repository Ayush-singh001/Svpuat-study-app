import '../models/college_model.dart';
import 'api_service.dart';

class CollegeService {
  final ApiService _api = ApiService();

  Future<List<College>> getColleges({bool includeInactive = false}) async {
    final response = await _api.get(
      '/colleges',
      queryParams: includeInactive ? {'includeInactive': 'true'} : null,
    );

    final List data = response['data'] ?? [];
    return data.map((json) => College.fromJson(json)).toList();
  }

  Future<College> getCollegeById(String id) async {
    final response = await _api.get('/colleges/$id');
    return College.fromJson(response['data']);
  }

  Future<College> createCollege({
    required String name,
    required String code,
    required String location,
    String? shortName,
    String? state,
    String? logoUrl,
    String? description,
  }) async {
    final response = await _api.post('/colleges', {
      'name': name,
      'code': code,
      'location': location,
      'shortName': shortName ?? name,
      'state': state ?? 'Uttar Pradesh',
      'logoUrl': logoUrl ?? '',
      'description': description ?? '',
    });

    return College.fromJson(response['data']);
  }

  Future<College> updateCollege(College college) async {
    final response = await _api.put('/colleges/${college.id}', {
      'name': college.name,
      'code': college.code,
      'location': college.location,
      'description': college.description,
    });

    return College.fromJson(response['data']);
  }

  Future<void> toggleCollegeActive(String collegeId) async {
    await _api.put('/colleges/$collegeId/toggle-active', {});
  }

  Future<void> deleteCollege(String collegeId) async {
    await _api.delete('/colleges/$collegeId');
  }
}
