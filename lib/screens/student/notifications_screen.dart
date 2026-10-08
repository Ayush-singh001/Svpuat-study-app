import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../widgets/ui_helpers.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final list = await _notificationService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingStateView(message: 'Loading notification history...')
          : _notifications.isEmpty
              ? const EmptyStateView(
                  title: 'No Notifications Yet',
                  message: 'You have no recent notifications from SVPUAT.',
                  icon: Icons.notifications_none_rounded,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              item.message,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withAlpha(20),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.contentType,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
