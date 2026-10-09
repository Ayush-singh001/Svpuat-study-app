import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/subject_model.dart';
import '../../services/mock_state_service.dart';
import '../../services/subject_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/ui_helpers.dart';

class ManageSubjectsScreen extends StatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  final SubjectService _subjectService = SubjectService();

  String _selectedCourse = AppConstants.courses.first;
  String _selectedDepartment = AppConstants.departments.first;
  String _selectedYear = AppConstants.years[1];
  String _selectedSemester = AppConstants.semesters[2];

  bool _isLoading = true;
  List<SubjectItem> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = MockStateService().currentUser;
      final list = await _subjectService.getSubjects(
        course: _selectedCourse,
        department: _selectedDepartment,
        year: _selectedYear,
        semester: _selectedSemester,
        collegeId: user?.collegeId,
      );
      if (mounted) {
        setState(() {
          _subjects = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddEditSubjectDialog([SubjectItem? existingSubject]) {
    final nameController = TextEditingController(text: existingSubject?.name ?? '');
    final codeController = TextEditingController(text: existingSubject?.code ?? '');
    final formKey = GlobalKey<FormState>();

    bool isSubmitting = false;
    String? dialogError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isEdit = existingSubject != null;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(isEdit ? Icons.edit_note_rounded : Icons.add_box_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(isEdit ? 'Edit Subject' : 'Add New Subject', style: const TextStyle(fontSize: 16)),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (dialogError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.errorBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dialogError!,
                          style: const TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    CustomTextField(
                      controller: nameController,
                      label: 'Subject Name',
                      hint: 'e.g. Relational Database Systems',
                      prefixIcon: Icons.book_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter subject name';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: codeController,
                      label: 'Subject Code (Optional)',
                      hint: 'e.g. CS302',
                      prefixIcon: Icons.tag_rounded,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;

                        setDialogState(() {
                          isSubmitting = true;
                          dialogError = null;
                        });

                        try {
                          if (isEdit) {
                            await _subjectService.updateSubject(
                              id: existingSubject.id,
                              name: nameController.text.trim(),
                              code: codeController.text.trim(),
                              course: _selectedCourse,
                              department: _selectedDepartment,
                              year: _selectedYear,
                              semester: _selectedSemester,
                            );
                          } else {
                            await _subjectService.createSubject(
                              name: nameController.text.trim(),
                              code: codeController.text.trim(),
                              course: _selectedCourse,
                              department: _selectedDepartment,
                              year: _selectedYear,
                              semester: _selectedSemester,
                            );
                          }

                          if (!context.mounted) return;
                          Navigator.of(ctx).pop();
                          _loadSubjects();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEdit ? 'Subject updated in MongoDB' : 'Subject saved to MongoDB'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        } catch (e) {
                          setDialogState(() {
                            isSubmitting = false;
                            dialogError = e.toString().replaceAll('Exception: ', '');
                          });
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isEdit ? 'Update' : 'Save Subject'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteSubject(SubjectItem subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Subject?'),
        content: Text('Are you sure you want to delete "${subject.name}"? It will be removed from MongoDB.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await _subjectService.deleteSubject(subject.id);
                _loadSubjects();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subject deleted from MongoDB'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Delete failed: ${e.toString().replaceAll("Exception: ", "")}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Subjects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSubjects,
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Subject',
            onPressed: () => _showAddEditSubjectDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallDropdown(
                        label: 'Course',
                        value: _selectedCourse,
                        items: AppConstants.courses,
                        onChanged: (val) {
                          setState(() => _selectedCourse = val!);
                          _loadSubjects();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSmallDropdown(
                        label: 'Department',
                        value: _selectedDepartment,
                        items: AppConstants.departments,
                        onChanged: (val) {
                          setState(() => _selectedDepartment = val!);
                          _loadSubjects();
                        },
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
                        onChanged: (val) {
                          setState(() => _selectedYear = val!);
                          _loadSubjects();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSmallDropdown(
                        label: 'Semester',
                        value: _selectedSemester,
                        items: AppConstants.semesters,
                        onChanged: (val) {
                          setState(() => _selectedSemester = val!);
                          _loadSubjects();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const LoadingStateView(message: 'Loading subjects from MongoDB Atlas...')
                : _subjects.isEmpty
                    ? EmptyStateView(
                        title: 'No Subjects Added',
                        message: 'Tap the + button above to add a subject for $_selectedSemester.',
                        icon: Icons.menu_book_rounded,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _subjects.length,
                        itemBuilder: (context, index) {
                          final item = _subjects[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.book_rounded, color: AppColors.primary, size: 22),
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              subtitle: Text(
                                '${item.code.isNotEmpty ? "${item.code} • " : ""}${item.course} (${item.semester})',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                    onPressed: () => _showAddEditSubjectDialog(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                    onPressed: () => _confirmDeleteSubject(item),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
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
}
