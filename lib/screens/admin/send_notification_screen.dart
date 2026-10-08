import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/notification_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedContentType = 'General';
  String _selectedDepartment = 'All Departments';
  bool _isSending = false;

  final List<String> _contentTypes = [
    'General',
    'Notice',
    'Notes',
    'Question Paper',
    'Syllabus',
    'Important Question',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
    });

    try {
      final res = await NotificationService().sendNotification(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        contentType: _selectedContentType,
        department: _selectedDepartment,
      );

      if (!mounted) return;

      setState(() {
        _isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Notification sent successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Push Notification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Header Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withAlpha(30)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.send_rounded, color: AppColors.primary, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SVPUAT Push Broadcast',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Notifications are isolated to students of your college ID only.',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Notification Title',
                hint: 'e.g. New Mathematics Notes Uploaded',
                prefixIcon: Icons.title_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter notification title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Message
              CustomTextField(
                controller: _messageController,
                label: 'Notification Message',
                hint: 'e.g. Unit 3 Calculus notes are now available for 2nd Year CSE.',
                prefixIcon: Icons.message_outlined,
                maxLines: 3,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter notification message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Content Type & Target Department
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Related Content',
                      value: _selectedContentType,
                      items: _contentTypes,
                      onChanged: (val) => setState(() => _selectedContentType = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Target Dept',
                      value: _selectedDepartment,
                      items: ['All Departments', ...AppConstants.departments],
                      onChanged: (val) => setState(() => _selectedDepartment = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Send Button
              CustomButton(
                text: 'Publish Push Notification',
                isLoading: _isSending,
                icon: Icons.send_rounded,
                onPressed: _handleSendNotification,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
