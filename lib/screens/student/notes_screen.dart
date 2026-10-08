import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/mock_state_service.dart';
import '../../widgets/content_card.dart';
import '../../widgets/ui_helpers.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final stateService = MockStateService();

    final allNotes = stateService.getContentsByCollege(
      AppConstants.svpuatCollegeId,
      type: AppConstants.typeNotes,
    );

    final filteredNotes = allNotes.where((note) {
      final q = _searchQuery.toLowerCase();
      return note.title.toLowerCase().contains(q) ||
          note.description.toLowerCase().contains(q) ||
          (note.subject?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SVPUAT Subject Notes'),
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
                hintText: 'Search SVPUAT notes by subject or topic...',
                prefixIcon: Icon(Icons.search, color: AppColors.textLight, size: 20),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filteredNotes.isEmpty
                ? EmptyStateView(
                    title: 'No Notes Found',
                    message: _searchQuery.isEmpty
                        ? 'No subject notes uploaded for SVPUAT yet.'
                        : 'No notes match "$_searchQuery".',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return ContentCard(
                        content: note,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening ${note.title}...'),
                              backgroundColor: AppColors.primary,
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
