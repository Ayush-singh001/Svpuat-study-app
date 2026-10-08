import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/content_model.dart';
import '../../services/mock_state_service.dart';
import '../../widgets/content_card.dart';
import '../../widgets/ui_helpers.dart';
import '../auth/login_screen.dart';
import 'notices_screen.dart';
import 'notifications_screen.dart';
import 'pdf_viewer_screen.dart';
import 'profile_screen.dart';
import 'study_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateService = MockStateService();
    final currentUser = stateService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text(AppConstants.svpuatCode),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, size: 24),
            tooltip: 'Notification History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          if (currentUser == null)
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.account_circle_outlined, size: 26),
              tooltip: 'Profile',
              onPressed: () {
                setState(() {
                  _currentIndex = 3;
                });
              },
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          const StudyScreen(),
          const NoticesScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Study',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_rounded),
            label: 'Notices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final stateService = MockStateService();
    final user = stateService.currentUser;
    final allContents = stateService.getContentsByCollege(AppConstants.svpuatCollegeId);

    // Filtered Content based on search query
    final filteredContents = allContents.where((content) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return content.title.toLowerCase().contains(q) ||
          content.description.toLowerCase().contains(q) ||
          (content.subject?.toLowerCase().contains(q) ?? false);
    }).toList();

    // Latest notices subset for Home section
    final latestNotices = allContents
        .where((c) => c.type == AppConstants.typeNotice)
        .take(3)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SVPUAT Welcome Hero Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withAlpha(30),
                      child: Text(
                        user != null && user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user != null
                                ? 'Welcome, ${user.name}!'
                                : 'Welcome to SVPUAT Hub',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user != null
                                ? '${user.course} • ${user.department}'
                                : AppConstants.svpuatFullName,
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Interactive Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search SVPUAT notes, papers, or subjects...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textLight, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textLight, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // "Study Materials" Section
          const SectionHeader(
            title: 'Study Materials',
            subtitle: 'Access organized notes, question papers & syllabus',
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStudyCategoryCard(
                  title: 'Notes',
                  subtitle: 'Lecture Units',
                  icon: Icons.auto_stories_rounded,
                  color: AppColors.primary,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStudyCategoryCard(
                  title: 'Question Papers',
                  subtitle: 'Mid & End Term',
                  icon: Icons.assignment_rounded,
                  color: AppColors.accent,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStudyCategoryCard(
                  title: 'Syllabus',
                  subtitle: 'ICAR & University',
                  icon: Icons.menu_book_rounded,
                  color: AppColors.secondary,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // "Latest Notices" Section
          SectionHeader(
            title: 'Latest Notices',
            subtitle: 'Official announcements from university departments',
            trailing: TextButton(
              onPressed: () => setState(() => _currentIndex = 2),
              child: const Text('View All >'),
            ),
          ),
          const SizedBox(height: 10),

          if (latestNotices.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No notices posted yet.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ),
            )
          else
            ...latestNotices.map((notice) => _buildNoticeQuickCard(context, notice)),

          const SizedBox(height: 28),

          // "Recent Uploads" Feed Section
          SectionHeader(
            title: 'Recent Uploads',
            subtitle: 'Recently published academic resources',
            trailing: Text(
              '${filteredContents.length} items',
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
          ),
          const SizedBox(height: 12),

          if (filteredContents.isEmpty)
            const EmptyStateView(
              message: 'No study materials match your search criteria.',
            )
          else
            ...filteredContents.map(
              (content) => ContentCard(
                content: content,
                onTap: () => _showContentModal(context, content),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudyCategoryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeQuickCard(BuildContext context, StudyContent notice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.errorBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.campaign_rounded, color: AppColors.error, size: 22),
        ),
        title: Text(
          notice.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          notice.description,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
        onTap: () {
          _showContentModal(context, notice);
        },
      ),
    );
  }

  void _showContentModal(BuildContext context, StudyContent content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      content.type,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content.description,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 20),
              if (content.fileUrl != null && content.fileUrl!.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PdfViewerScreen(
                            title: content.title,
                            pdfUrl: content.fileUrl!,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_rounded),
                    label: const Text('Read PDF Document'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
