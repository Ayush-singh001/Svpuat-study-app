import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/mock_state_service.dart';
import '../../widgets/content_card.dart';
import '../../widgets/question_card.dart';
import '../../widgets/ui_helpers.dart';
import '../auth/login_screen.dart';
import 'add_edit_question_screen.dart';
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
                    _confirmDelete(context, content.id, content.title);
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

  void _confirmDelete(BuildContext context, String contentId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Material'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              MockStateService().deleteContent(contentId);
              Navigator.of(ctx).pop();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Material deleted successfully'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
