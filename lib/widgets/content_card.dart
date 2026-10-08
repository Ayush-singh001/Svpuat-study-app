import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/content_model.dart';
import '../screens/student/pdf_viewer_screen.dart';

class ContentCard extends StatelessWidget {
  final StudyContent content;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ContentCard({
    super.key,
    required this.content,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Notes':
        return Icons.auto_stories_rounded;
      case 'Question Paper':
        return Icons.assignment_rounded;
      case 'Syllabus':
        return Icons.menu_book_rounded;
      case 'Notice':
        return Icons.campaign_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Notes':
        return AppColors.primary;
      case 'Question Paper':
        return AppColors.accent;
      case 'Syllabus':
        return AppColors.secondary;
      case 'Notice':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  void _openDocument(BuildContext context) {
    if (content.fileUrl != null && content.fileUrl!.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(
            title: content.title,
            pdfUrl: content.fileUrl!,
          ),
        ),
      );
    } else {
      _showToast(context, 'No document attached.');
    }
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _getColorForType(content.type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getColorForType(content.type);
    final iconData = _getIconForType(content.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap ?? () => _openDocument(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Type Badge, Subject/Department & Actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: themeColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconData, color: themeColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: themeColor.withAlpha(18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                content.type,
                                style: TextStyle(
                                  color: themeColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (content.subject != null && content.subject!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '• ${content.subject}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ] else if (content.department != null && content.department!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '• ${content.department}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          content.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                      onPressed: onEdit,
                      tooltip: 'Edit',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),

              // Description
              Text(
                content.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Metadata Footer
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        '${content.createdAt.day}/${content.createdAt.month}/${content.createdAt.year}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                      ),
                      if (content.semester != null && content.semester!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${content.semester}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ],
                  ),
                  InkWell(
                    onTap: () => _openDocument(context),
                    child: Row(
                      children: [
                        Icon(Icons.menu_book_rounded, size: 16, color: themeColor),
                        const SizedBox(width: 4),
                        Text(
                          'Read PDF',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
