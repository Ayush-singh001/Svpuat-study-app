import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  // Register Student with Password
  Future<AppUser> registerStudent({
    required String fullName,
    required String email,
    required String mobile,
    required String studentId,
    required String password,
    required String confirmPassword,
    String? course,
    String? department,
    String? year,
    String? semester,
    String? collegeId,
  }) async {
    final payload = <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'studentId': studentId,
      'password': password,
      'confirmPassword': confirmPassword,
    };

    if (course != null) payload['course'] = course;
    if (department != null) payload['department'] = department;
    if (year != null) payload['year'] = year;
    if (semester != null) payload['semester'] = semester;
    if (collegeId != null) payload['collegeId'] = collegeId;

    final response = await _api.post('/auth/student/register', payload);

    if (response['token'] != null) {
      await _api.setAuthToken(response['token']);
    }

    return AppUser.fromJson(response['user']);
  }

  // Student Login using Student ID OR Email + Password
  Future<AppUser> loginStudent({
    required String identifier,
    required String password,
  }) async {
    final response = await _api.post('/auth/student/login', {
      'identifier': identifier,
      'password': password,
    });

    if (response['token'] != null) {
      await _api.setAuthToken(response['token']);
    }

    return AppUser.fromJson(response['user']);
  }

  // Admin Login (Email + Password for College Admin / Super Admin)
  Future<AppUser> adminLogin({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/auth/admin/login', {
      'email': email,
      'password': password,
    });

    if (response['token'] != null) {
      await _api.setAuthToken(response['token']);
    }

    return AppUser.fromJson(response['user']);
  }

  // Super Admin: Create College Admin Account
  Future<AppUser> createCollegeAdmin({
    required String fullName,
    required String email,
    required String mobile,
    required String collegeId,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _api.post('/auth/admin/user', {
      'fullName': fullName,
      'email': email,
      'mobile': mobile,
      'collegeId': collegeId,
      'password': password,
      'confirmPassword': confirmPassword,
    });

    return AppUser.fromJson(response['data']);
  }

  // Request Password Reset Link
  Future<String> requestForgotPassword(String email) async {
    final response = await _api.post('/auth/forgot-password', {
      'email': email,
    });
    return response['message'] ?? 'If the account exists, a password reset link has been sent.';
  }

  // Reset Password Using Token
  Future<String> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _api.post('/auth/reset-password', {
      'token': token,
      'password': password,
      'confirmPassword': confirmPassword,
    });
    return response['message'] ?? 'Password reset successfully. You can now log in.';
  }

  // Change Password for Authenticated Admin / Student
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _api.put('/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    return response['message'] ?? 'Password updated successfully';
  }

  // Alias for backward compatibility
  Future<AppUser> login({
    required String identifier,
    required String password,
  }) async {
    return loginStudent(identifier: identifier, password: password);
  }

  // Alias for backward compatibility
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String mobile,
    required String studentId,
    required String password,
    required String course,
    required String department,
    required String year,
    required String semester,
    String? collegeId,
  }) async {
    return registerStudent(
      fullName: fullName,
      email: email,
      mobile: mobile,
      studentId: studentId,
      password: password,
      confirmPassword: password,
      course: course,
      department: department,
      year: year,
      semester: semester,
      collegeId: collegeId,
    );
  }

  // Admin Password Reset Help
  Future<String> forgotPassword(String email) async {
    return requestForgotPassword(email);
  }

  // Get Current Authenticated Profile
  Future<AppUser?> getMe() async {
    if (_api.authToken == null) return null;
    try {
      final response = await _api.get('/auth/me');
      return AppUser.fromJson(response['user']);
    } catch (_) {
      await _api.setAuthToken(null);
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', {});
    } catch (_) {}
    await _api.setAuthToken(null);
  }
}
