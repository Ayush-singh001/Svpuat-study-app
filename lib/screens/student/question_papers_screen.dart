import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/mock_state_service.dart';
import '../../widgets/content_card.dart';
import '../../widgets/ui_helpers.dart';

class QuestionPapersScreen extends StatefulWidget {
  const QuestionPapersScreen({super.key});

  @override
  State<QuestionPapersScreen> createState() => _QuestionPapersScreenState();
}

class _QuestionPapersScreenState extends State<QuestionPapersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final stateService = MockStateService();

    final allPapers = stateService.getContentsByCollege(
      AppConstants.svpuatCollegeId,
      type: AppConstants.typeQuestionPaper,
    );

    final filteredPapers = allPapers.where((paper) {
      final q = _searchQuery.toLowerCase();
      return paper.title.toLowerCase().contains(q) ||
          paper.description.toLowerCase().contains(q) ||
          (paper.subject?.toLowerCase().contains(q) ?? false) ||
          (paper.examType?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SVPUAT Question Papers'),
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
                hintText: 'Search question papers by subject, year or exam type...',
                prefixIcon: Icon(Icons.search, color: AppColors.textLight, size: 20),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filteredPapers.isEmpty
                ? EmptyStateView(
                    title: 'No Question Papers Found',
                    message: _searchQuery.isEmpty
                        ? 'No question papers uploaded for SVPUAT yet.'
                        : 'No papers match "$_searchQuery".',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPapers.length,
                    itemBuilder: (context, index) {
                      final paper = filteredPapers[index];
                      return ContentCard(
                        content: paper,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Downloading ${paper.title}...'),
                              backgroundColor: AppColors.accent,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
