import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/important_question_model.dart';

class QuestionCard extends StatelessWidget {
  final ImportantQuestion question;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const QuestionCard({
    super.key,
    required this.question,
    this.onEdit,
    this.onDelete,
  });

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.accent;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final diffColor = _getDifficultyColor(question.difficulty);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Topic/Unit Tag, Question Type & Actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          question.unitTopic,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withAlpha(18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          question.questionType,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: diffColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          question.difficulty,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: diffColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Question Text
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),

            // Footer: Subject Name & Department/Semester
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.menu_book_rounded, size: 14, color: AppColors.textLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${question.subject} • ${question.semester ?? 'All Semesters'}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
