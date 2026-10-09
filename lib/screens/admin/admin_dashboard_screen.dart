import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../../services/mock_state_service.dart';
import '../../widgets/content_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/question_card.dart';
import '../../widgets/ui_helpers.dart';
import '../auth/login_screen.dart';
import 'add_edit_question_screen.dart';
import 'manage_subjects_screen.dart';
import 'send_notification_screen.dart';
import 'upload_content_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchRealData();
  }

  Future<void> _fetchRealData() async {
    final state = MockStateService();
    await Future.wait([
      state.fetchRealNotes(),
      state.fetchRealQuestionPapers(),
      state.fetchRealSyllabus(),
      state.fetchRealNotices(),
      state.fetchRealImportantQuestions(),
    ]);
    if (mounted) {
      setState(() {});
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool isSubmitting = false;
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    String? dialogError;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.lock_reset_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Change Password', style: TextStyle(fontSize: 16)),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (dialogError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.errorBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            dialogError!,
                            style: const TextStyle(color: AppColors.error, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      CustomTextField(
                        controller: currentPassController,
                        label: 'Current Password',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        obscureText: obscureCurrent,
                        onToggleVisibility: () {
                          setDialogState(() => obscureCurrent = !obscureCurrent);
                        },
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter current password';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: newPassController,
                        label: 'New Password (min 8 chars)',
                        hint: '••••••••',
                        prefixIcon: Icons.key_rounded,
                        isPassword: true,
                        obscureText: obscureNew,
                        onToggleVisibility: () {
                          setDialogState(() => obscureNew = !obscureNew);
                        },
                        validator: (val) {
                          if (val == null || val.length < 8) {
                            return 'Min 8 characters required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: confirmPassController,
                        label: 'Confirm New Password',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_reset_rounded,
                        isPassword: true,
                        obscureText: obscureConfirm,
                        onToggleVisibility: () {
                          setDialogState(() => obscureConfirm = !obscureConfirm);
                        },
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Confirm new password';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          if (newPassController.text != confirmPassController.text) {
                            setDialogState(() {
                              dialogError = 'New password and confirmation do not match';
                            });
                            return;
                          }

                          setDialogState(() {
                            isSubmitting = true;
                            dialogError = null;
                          });

                          try {
                            final message = await AuthService().changePassword(
                              currentPassword: currentPassController.text,
                              newPassword: newPassController.text,
                            );

                            if (!context.mounted) return;
                            Navigator.of(ctx).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() {
                              isSubmitting = false;
                              dialogError = e.toString().replaceAll('Exception: ', '');
                            });
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Update Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stateService = MockStateService();
    final user = stateService.currentUser;

    final allContents = stateService.getContentsByCollege(AppConstants.svpuatCollegeId);
    final questions = stateService.importantQuestions;

    final filteredContents = _selectedFilter == 'All'
        ? allContents
        : allContents.where((c) => c.type == _selectedFilter).toList();

    final notesCount = allContents.where((c) => c.type == AppConstants.typeNotes).length;
    final papersCount = allContents.where((c) => c.type == AppConstants.typeQuestionPaper).length;
    final questionsCount = questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SVPUAT Admin Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Send Push Notification',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SendNotificationScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.lock_reset_rounded),
            tooltip: 'Change Password',
            onPressed: () => _showChangePasswordDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () {
              stateService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Banner Card
            Card(
              color: AppColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'SVPUAT Admin',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            AppConstants.svpuatFullName,
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Real Metrics Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    title: 'Notes',
                    count: '$notesCount',
                    color: AppColors.primary,
                    icon: Icons.auto_stories_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricItem(
                    title: 'Papers',
                    count: '$papersCount',
                    color: AppColors.accent,
                    icon: Icons.assignment_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricItem(
                    title: 'Questions',
                    count: '$questionsCount',
                    color: AppColors.secondary,
                    icon: Icons.quiz_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Subject Management Quick Module Card
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.book_rounded, color: AppColors.primary, size: 28),
                ),
                title: const Text(
                  'Manage Course Subjects',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Add, edit, or remove subjects permanently in MongoDB Atlas'),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ManageSubjectsScreen()),
                  );
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 24),

            // Important Questions Management Section Header & Add Button
            SectionHeader(
              title: 'Important Questions Management',
              trailing: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddEditQuestionScreen(),
                    ),
                  );
                  setState(() {});
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 36),
                ),
              ),
            ),
            const SizedBox(height: 10),

            if (questions.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No important questions added yet.', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                ),
              )
            else
              ...questions.take(3).map(
                    (q) => QuestionCard(
                      question: q,
                      onEdit: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddEditQuestionScreen(existingQuestion: q),
                          ),
                        );
                        setState(() {});
                      },
                      onDelete: () {
                        stateService.deleteImportantQuestionReal(q.id);
                        setState(() {});
                      },
                    ),
                  ),

            const SizedBox(height: 24),

            // Academic Materials Section Header & Add Button
            SectionHeader(
              title: 'Academic Content Management',
              trailing: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UploadContentScreen(
                        collegeId: AppConstants.svpuatCollegeId,
                      ),
                    ),
                  );
                  setState(() {});
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Material'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 36),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Notes', 'Question Paper', 'Syllabus', 'Notice'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filter),
                      selectedColor: AppColors.primary.withAlpha(30),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Filtered Items
            if (filteredContents.isEmpty)
              const EmptyStateView(
                title: 'No Content Available',
                message: 'No academic materials found in this category.',
              )
            else
              ...filteredContents.map(
                (content) => ContentCard(
                  content: content,
                  onEdit: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UploadContentScreen(
                          collegeId: AppConstants.svpuatCollegeId,
                          existingContent: content,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                  onDelete: () {
                    _confirmDelete(context, content.id, content.title, content.type);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String contentId, String title, String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Content?'),
        content: Text('Are you sure you want to delete "$title"? Students will no longer be able to access it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await MockStateService().deleteContentReal(contentId, type);
                if (context.mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Content deleted successfully'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Delete failed: ${e.toString().replaceAll("Exception: ", "")}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
