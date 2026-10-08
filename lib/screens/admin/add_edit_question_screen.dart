import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/important_question_model.dart';
import '../../services/mock_state_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddEditQuestionScreen extends StatefulWidget {
  final ImportantQuestion? existingQuestion;

  const AddEditQuestionScreen({
    super.key,
    this.existingQuestion,
  });

  @override
  State<AddEditQuestionScreen> createState() => _AddEditQuestionScreenState();
}

class _AddEditQuestionScreenState extends State<AddEditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _questionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _unitTopicController = TextEditingController();

  String _selectedCourse = AppConstants.courses.first;
  String _selectedDepartment = AppConstants.departments.first;
  String _selectedYear = AppConstants.years[1];
  String _selectedSemester = AppConstants.semesters[2];
  String _selectedType = 'Long Answer';
  String _selectedDifficulty = 'Medium';

  bool _isSaving = false;

  final List<String> _types = ['Short Answer', 'Long Answer', 'Numerical', 'Theory', 'MCQ'];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    if (widget.existingQuestion != null) {
      final q = widget.existingQuestion!;
      _questionController.text = q.question;
      _subjectController.text = q.subject;
      _unitTopicController.text = q.unitTopic;
      if (q.course != null && AppConstants.courses.contains(q.course)) {
        _selectedCourse = q.course!;
      }
      if (q.department != null && AppConstants.departments.contains(q.department)) {
        _selectedDepartment = q.department!;
      }
      if (q.year != null && AppConstants.years.contains(q.year)) {
        _selectedYear = q.year!;
      }
      if (q.semester != null && AppConstants.semesters.contains(q.semester)) {
        _selectedSemester = q.semester!;
      }
      if (_types.contains(q.questionType)) {
        _selectedType = q.questionType;
      }
      if (_difficulties.contains(q.difficulty)) {
        _selectedDifficulty = q.difficulty;
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _subjectController.dispose();
    _unitTopicController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final state = MockStateService();
    final isEdit = widget.existingQuestion != null;

    final questionObj = ImportantQuestion(
      id: isEdit ? widget.existingQuestion!.id : 'iq_${DateTime.now().millisecondsSinceEpoch}',
      question: _questionController.text.trim(),
      subject: _subjectController.text.trim(),
      unitTopic: _unitTopicController.text.trim().isEmpty ? 'General Topic' : _unitTopicController.text.trim(),
      course: _selectedCourse,
      department: _selectedDepartment,
      year: _selectedYear,
      semester: _selectedSemester,
      questionType: _selectedType,
      difficulty: _selectedDifficulty,
      collegeId: AppConstants.svpuatCollegeId,
      createdAt: isEdit ? widget.existingQuestion!.createdAt : DateTime.now(),
    );

    if (isEdit) {
      await state.updateImportantQuestionReal(questionObj);
    } else {
      await state.addImportantQuestionReal(questionObj);
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdit ? 'Question updated successfully!' : 'Important question published!'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingQuestion != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Question' : 'Add Important Question'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Text Input
              CustomTextField(
                controller: _questionController,
                label: 'Question Statement',
                hint: 'e.g. Explain Dijkstra\'s Shortest Path Algorithm with a trace example.',
                prefixIcon: Icons.help_outline_rounded,
                maxLines: 4,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter question text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Subject Name
              CustomTextField(
                controller: _subjectController,
                label: 'Subject Name',
                hint: 'e.g. Data Structures & Algorithms',
                prefixIcon: Icons.menu_book_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Unit / Topic
              CustomTextField(
                controller: _unitTopicController,
                label: 'Unit / Topic Tag',
                hint: 'e.g. Unit 4 - Graphs & Shortest Path',
                prefixIcon: Icons.topic_outlined,
              ),
              const SizedBox(height: 16),

              // Type & Difficulty Row
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Question Type',
                      value: _selectedType,
                      items: _types,
                      onChanged: (val) => setState(() => _selectedType = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Difficulty Level',
                      value: _selectedDifficulty,
                      items: _difficulties,
                      onChanged: (val) => setState(() => _selectedDifficulty = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Course & Department
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Course',
                      value: _selectedCourse,
                      items: AppConstants.courses,
                      onChanged: (val) => setState(() => _selectedCourse = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Department',
                      value: _selectedDepartment,
                      items: AppConstants.departments,
                      onChanged: (val) => setState(() => _selectedDepartment = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Year & Semester
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Year',
                      value: _selectedYear,
                      items: AppConstants.years,
                      onChanged: (val) => setState(() => _selectedYear = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Semester',
                      value: _selectedSemester,
                      items: AppConstants.semesters,
                      onChanged: (val) => setState(() => _selectedSemester = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Save Button
              CustomButton(
                text: isEdit ? 'Update Question' : 'Publish Question',
                isLoading: _isSaving,
                icon: isEdit ? Icons.save : Icons.publish_rounded,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
