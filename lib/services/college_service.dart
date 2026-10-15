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

  // Department Management
  Future<List<String>> getDepartments(String collegeId) async {
    if (collegeId.isEmpty || collegeId == 'col_svpuat') {
      return [
        'Computer Science & Engineering',
        'Agronomy',
        'Biotechnology',
        'Horticulture',
        'Soil Science',
      ];
    }
    try {
      final response = await _api.get('/colleges/$collegeId/departments');
      final List data = response['data'] ?? [];
      return data.map((d) => d.toString()).toList();
    } catch (_) {
      return [
        'Computer Science & Engineering',
        'Agronomy',
        'Biotechnology',
      ];
    }
  }

  Future<List<String>> addDepartment({required String collegeId, required String name}) async {
    final response = await _api.post('/colleges/$collegeId/departments', {
      'name': name,
    });
    final List data = response['data'] ?? [];
    return data.map((d) => d.toString()).toList();
  }

  Future<List<String>> deleteDepartment({required String collegeId, required String name}) async {
    final encodedName = Uri.encodeComponent(name);
    final response = await _api.delete('/colleges/$collegeId/departments/$encodedName');
    final List data = response['data'] ?? [];
    return data.map((d) => d.toString()).toList();
  }
}
