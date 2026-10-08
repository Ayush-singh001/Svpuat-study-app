import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/mock_state_service.dart';
import '../../widgets/content_card.dart';
import '../../widgets/ui_helpers.dart';

class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final stateService = MockStateService();

    final allSyllabus = stateService.getContentsByCollege(
      AppConstants.svpuatCollegeId,
      type: AppConstants.typeSyllabus,
    );

    final filteredSyllabus = allSyllabus.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.title.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q) ||
          (s.course?.toLowerCase().contains(q) ?? false) ||
          (s.department?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SVPUAT Course Syllabus'),
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
                hintText: 'Search syllabus by course or department...',
                prefixIcon: Icon(Icons.search, color: AppColors.textLight, size: 20),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filteredSyllabus.isEmpty
                ? EmptyStateView(
                    title: 'No Syllabus Found',
                    message: _searchQuery.isEmpty
                        ? 'No syllabus documents uploaded for SVPUAT.'
                        : 'No syllabus matches "$_searchQuery".',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredSyllabus.length,
                    itemBuilder: (context, index) {
                      final item = filteredSyllabus[index];
                      return ContentCard(
                        content: item,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening ${item.title}...'),
                              backgroundColor: AppColors.secondary,
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
