import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/content_model.dart';
import '../../services/mock_state_service.dart';
import '../../widgets/content_card.dart';
import '../../widgets/ui_helpers.dart';
import 'pdf_viewer_screen.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final stateService = MockStateService();

    final allNotices = stateService.getContentsByCollege(
      AppConstants.svpuatCollegeId,
      type: AppConstants.typeNotice,
    );

    final filteredNotices = allNotices.where((notice) {
      final q = _searchQuery.toLowerCase();
      return notice.title.toLowerCase().contains(q) ||
          notice.description.toLowerCase().contains(q) ||
          (notice.department?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SVPUAT Notices & Circulars'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search SVPUAT notices or announcements...',
                prefixIcon: Icon(Icons.search, color: AppColors.textLight, size: 20),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filteredNotices.isEmpty
                ? EmptyStateView(
                    title: 'No Notices Posted',
                    message: _searchQuery.isEmpty
                        ? 'No official notices currently posted for SVPUAT.'
                        : 'No notices match "$_searchQuery".',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNotices.length,
                    itemBuilder: (context, index) {
                      final notice = filteredNotices[index];
                      return ContentCard(
                        content: notice,
                        onTap: () {
                          _showNoticeDialog(context, notice);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showNoticeDialog(BuildContext context, StudyContent notice) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.campaign, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Notice Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.schedule, size: 13, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(
                  '${notice.createdAt.day}/${notice.createdAt.month}/${notice.createdAt.year}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${notice.uploadedBy}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notice.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (notice.fileName != null && notice.fileName!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: AppColors.error, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        notice.fileName ?? 'Attachment',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          if (notice.fileUrl != null && notice.fileUrl!.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PdfViewerScreen(
                      title: notice.title,
                      pdfUrl: notice.fileUrl!,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.menu_book_rounded, size: 16),
              label: const Text('Read PDF'),
            ),
        ],
      ),
    );
  }
}
