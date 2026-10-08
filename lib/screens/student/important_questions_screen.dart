import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/important_question_model.dart';
import '../../services/mock_state_service.dart';
import '../../widgets/question_card.dart';
import '../../widgets/ui_helpers.dart';

class ImportantQuestionsScreen extends StatefulWidget {
  final String? initialSubject;

  const ImportantQuestionsScreen({
    super.key,
    this.initialSubject,
  });

  @override
  State<ImportantQuestionsScreen> createState() => _ImportantQuestionsScreenState();
}

class _ImportantQuestionsScreenState extends State<ImportantQuestionsScreen> {
  final _searchController = TextEditingController();

  String? _selectedCourse;
  String? _selectedDepartment;
  String? _selectedYear;
  String? _selectedSemester;
  String? _selectedSubject;

  bool _isLoading = false;
  List<ImportantQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialSubject != null) {
      _selectedSubject = widget.initialSubject;
    }
    _loadQuestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    final state = MockStateService();
    final result = await state.fetchRealImportantQuestions(
      course: _selectedCourse,
      department: _selectedDepartment,
      year: _selectedYear,
      semester: _selectedSemester,
      subject: _selectedSubject,
      search: _searchController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _questions = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Important Questions'),
      ),
      body: Column(
        children: [
          // Filter Header Box
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _loadQuestions(),
                  decoration: InputDecoration(
                    hintText: 'Search questions, units, or topics...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textLight),
                            onPressed: () {
                              _searchController.clear();
                              _loadQuestions();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Department & Subject Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Depts', _selectedDepartment, (val) {
                        setState(() => _selectedDepartment = val);
                        _loadQuestions();
                      }, AppConstants.departments),
                      const SizedBox(width: 8),
                      _buildFilterChip('All Semesters', _selectedSemester, (val) {
                        setState(() => _selectedSemester = val);
                        _loadQuestions();
                      }, AppConstants.semesters),
                      const SizedBox(width: 8),
                      _buildFilterChip('All Subjects', _selectedSubject, (val) {
                        setState(() => _selectedSubject = val);
                        _loadQuestions();
                      }, AppConstants.subjectsByCourseAndSemester.values.expand((element) => element).toSet().toList()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main Question List View
          Expanded(
            child: _isLoading
                ? const LoadingStateView(message: 'Loading important questions...')
                : _questions.isEmpty
                    ? const EmptyStateView(
                        title: 'No Questions Found',
                        message: 'No important questions match your filter criteria.',
                        icon: Icons.quiz_outlined,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          final question = _questions[index];
                          return QuestionCard(question: question);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String? currentValue,
    ValueChanged<String?> onSelected,
    List<String> options,
  ) {
    return PopupMenuButton<String>(
      onSelected: (val) {
        onSelected(val == 'ALL' ? null : val);
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            value: 'ALL',
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...options.map(
            (opt) => PopupMenuItem<String>(
              value: opt,
              child: Text(opt),
            ),
          ),
        ];
      },
      child: Chip(
        label: Text(
          currentValue ?? label,
          style: TextStyle(
            color: currentValue != null ? AppColors.primary : AppColors.textSecondary,
            fontWeight: currentValue != null ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
        backgroundColor: currentValue != null ? AppColors.primary.withAlpha(20) : Colors.grey.shade100,
        avatar: Icon(
          Icons.arrow_drop_down,
          color: currentValue != null ? AppColors.primary : AppColors.textLight,
          size: 18,
        ),
      ),
    );
  }
}
