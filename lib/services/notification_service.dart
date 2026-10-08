import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _api = ApiService();

  Future<void> registerFcmToken(String fcmToken) async {
    try {
      await _api.post('/notifications/register-token', {
        'fcmToken': fcmToken,
      });
    } catch (_) {}
  }

  Future<List<AppNotification>> getNotifications() async {
    final response = await _api.get('/notifications');
    final List data = response['data'] ?? [];
    return data.map((json) => AppNotification.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> sendNotification({
    required String title,
    required String message,
    String contentType = 'General',
    String? contentId,
    String? department,
  }) async {
    final response = await _api.post('/notifications/send', {
      'title': title,
      'message': message,
      'contentType': contentType,
      'contentId': contentId ?? '',
      'department': department ?? 'All Departments',
    });

    return response;
  }
}
