import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/content_model.dart';
import '../../services/mock_state_service.dart';
import '../../widgets/content_card.dart';
import '../../widgets/ui_helpers.dart';
import 'important_questions_screen.dart';
import 'pdf_viewer_screen.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  String _selectedContentType = AppConstants.typeNotes; // 'Notes', 'Question Paper', 'Syllabus', 'Important Questions'
  String _selectedCourse = AppConstants.courses.first;
  String _selectedDepartment = AppConstants.departments.first;
  String _selectedYear = AppConstants.years[1];
  String _selectedSemester = AppConstants.semesters[2];
  String? _selectedSubject;

  @override
  Widget build(BuildContext context) {
    final stateService = MockStateService();

    final key = '${_selectedCourse}_$_selectedSemester';
    final availableSubjects = AppConstants.subjectsByCourseAndSemester[key] ?? [
      'Core Subject 1',
      'Core Subject 2',
      'Elective Subject',
      'Practical Lab',
    ];

    if (_selectedSubject == null || !availableSubjects.contains(_selectedSubject)) {
      _selectedSubject = availableSubjects.first;
    }

    final filteredContents = stateService.getContentsByCollege(
      AppConstants.svpuatCollegeId,
      type: _selectedContentType,
      course: _selectedCourse,
      department: _selectedDepartment,
      year: _selectedYear,
      semester: _selectedSemester,
      subject: _selectedSubject,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Study Materials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz_outlined),
            tooltip: 'Important Questions',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ImportantQuestionsScreen(
                    initialSubject: _selectedSubject,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Category Bar: [ Notes ] [ Question Papers ] [ Syllabus ] [ Questions ]
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.border.withAlpha(100),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildSegmentTab(AppConstants.typeNotes),
                  _buildSegmentTab(AppConstants.typeQuestionPaper),
                  _buildSegmentTab(AppConstants.typeSyllabus),
                  _buildSegmentTab('Questions'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Academic Hierarchy Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallDropdown(
                        label: 'Course',
                        value: _selectedCourse,
                        items: AppConstants.courses,
                        onChanged: (val) => setState(() {
                          _selectedCourse = val!;
                          _selectedSubject = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSmallDropdown(
                        label: 'Department',
                        value: _selectedDepartment,
                        items: AppConstants.departments,
                        onChanged: (val) => setState(() => _selectedDepartment = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallDropdown(
                        label: 'Year',
                        value: _selectedYear,
                        items: AppConstants.years,
                        onChanged: (val) => setState(() => _selectedYear = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSmallDropdown(
                        label: 'Semester',
                        value: _selectedSemester,
                        items: AppConstants.semesters,
                        onChanged: (val) => setState(() {
                          _selectedSemester = val!;
                          _selectedSubject = null;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subject Horizontal Selector Chips
                const Text(
                  'Select Subject:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: availableSubjects.map((subj) {
                      final isSelected = _selectedSubject == subj;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: isSelected,
                          label: Text(subj),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedSubject = subj;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Materials List / Empty State
          Expanded(
            child: _selectedContentType == 'Questions'
                ? const ImportantQuestionsView()
                : filteredContents.isEmpty
                    ? EmptyStateView(
                        title: 'No $_selectedContentType Found',
                        message:
                            'No materials currently uploaded for $_selectedSubject in $_selectedSemester.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredContents.length,
                        itemBuilder: (context, index) {
                          final item = filteredContents[index];
                          return ContentCard(
                            content: item,
                            onTap: () => _showDetailsModal(context, item),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(String type) {
    final isSelected = _selectedContentType == type;
    String displayLabel = type;
    if (type == AppConstants.typeQuestionPaper) displayLabel = 'Papers';
    if (type == 'Questions') displayLabel = 'Questions';

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedContentType = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              displayLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallDropdown({
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
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              items: items
                  .map((i) => DropdownMenuItem(
                        value: i,
                        child: Text(i, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _showDetailsModal(BuildContext context, StudyContent item) {
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
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              if (item.fileUrl != null && item.fileUrl!.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PdfViewerScreen(
                            title: item.title,
                            pdfUrl: item.fileUrl!,
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

class ImportantQuestionsView extends StatefulWidget {
  const ImportantQuestionsView({super.key});

  @override
  State<ImportantQuestionsView> createState() => _ImportantQuestionsViewState();
}

class _ImportantQuestionsViewState extends State<ImportantQuestionsView> {
  @override
  Widget build(BuildContext context) {
    final state = MockStateService();
    final questions = state.importantQuestions;

    if (questions.isEmpty) {
      return const EmptyStateView(
        title: 'No Important Questions',
        message: 'No important questions uploaded for this selection.',
        icon: Icons.quiz_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final q = questions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        q.unitTopic,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        q.difficulty,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  q.question,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
