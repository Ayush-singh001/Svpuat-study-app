import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/content_model.dart';
import '../../services/mock_state_service.dart';
import '../../services/upload_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class UploadContentScreen extends StatefulWidget {
  final String collegeId;
  final StudyContent? existingContent;

  const UploadContentScreen({
    super.key,
    required this.collegeId,
    this.existingContent,
  });

  @override
  State<UploadContentScreen> createState() => _UploadContentScreenState();
}

class _UploadContentScreenState extends State<UploadContentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uploadService = UploadService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _paperYearController = TextEditingController();

  String _selectedType = AppConstants.typeNotes;
  String _selectedCourse = AppConstants.courses.first;
  String _selectedDepartment = AppConstants.departments.first;
  String _selectedYear = AppConstants.years[1];
  String _selectedSemester = AppConstants.semesters[2];
  String _selectedExamType = AppConstants.examTypes.first;

  PlatformFile? _pickedFile;
  String? _uploadedFileUrl;
  String? _uploadedPublicId;
  String? _uploadedFileName;
  String? _uploadedFileSize;

  bool _isUploading = false;
  bool _isSaving = false;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    if (widget.existingContent != null) {
      final c = widget.existingContent!;
      _titleController.text = c.title;
      _descriptionController.text = c.description;
      _subjectController.text = c.subject ?? '';
      _paperYearController.text = c.paperYear ?? '';
      _selectedType = c.type;
      if (c.course != null && AppConstants.courses.contains(c.course)) {
        _selectedCourse = c.course!;
      }
      if (c.department != null && AppConstants.departments.contains(c.department)) {
        _selectedDepartment = c.department!;
      }
      if (c.year != null && AppConstants.years.contains(c.year)) {
        _selectedYear = c.year!;
      }
      if (c.semester != null && AppConstants.semesters.contains(c.semester)) {
        _selectedSemester = c.semester!;
      }
      if (c.examType != null && AppConstants.examTypes.contains(c.examType)) {
        _selectedExamType = c.examType!;
      }
      _uploadedFileUrl = c.fileUrl;
      _uploadedPublicId = c.publicId;
      _uploadedFileName = c.fileName;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _paperYearController.dispose();
    super.dispose();
  }

  Future<void> _handlePickAndUploadFile() async {
    final picked = await _uploadService.pickPdfFile();
    if (picked == null) return;

    setState(() {
      _pickedFile = picked;
      _isUploading = true;
      _uploadError = null;
    });

    final uploadRes = await _uploadService.uploadFile(picked);

    if (!mounted) return;

    setState(() {
      _isUploading = false;
    });

    if (uploadRes.success) {
      setState(() {
        _uploadedFileUrl = uploadRes.fileUrl;
        _uploadedPublicId = uploadRes.publicId;
        _uploadedFileName = uploadRes.fileName;
        _uploadedFileSize = uploadRes.fileSize;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File uploaded to Cloudinary successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      setState(() {
        _uploadError = uploadRes.message;
      });
    }
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final state = MockStateService();
    final isEdit = widget.existingContent != null;

    final content = StudyContent(
      id: isEdit ? widget.existingContent!.id : 'svp_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      collegeId: widget.collegeId,
      course: _selectedCourse,
      department: _selectedDepartment,
      year: _selectedYear,
      semester: _selectedSemester,
      subject: _subjectController.text.trim().isEmpty ? 'General' : _subjectController.text.trim(),
      examType: _selectedType == AppConstants.typeQuestionPaper ? _selectedExamType : null,
      paperYear: _selectedType == AppConstants.typeQuestionPaper ? _paperYearController.text.trim() : null,
      fileUrl: _uploadedFileUrl ?? 'https://svpuat.ac.in/files/document.pdf',
      publicId: _uploadedPublicId ?? '',
      fileName: _uploadedFileName ?? (_pickedFile?.name ?? 'svpuat_document.pdf'),
      fileSize: _uploadedFileSize ?? '',
      createdAt: isEdit ? widget.existingContent!.createdAt : DateTime.now(),
      uploadedBy: state.currentUser?.name ?? 'SVPUAT Admin',
    );

    await state.addContentReal(content);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdit ? 'Material updated successfully!' : '$_selectedType published for SVPUAT!'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingContent != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Material' : 'Upload SVPUAT Material'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Selector
              const Text(
                'Material Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined, color: AppColors.textLight),
                ),
                items: [
                  AppConstants.typeNotes,
                  AppConstants.typeQuestionPaper,
                  AppConstants.typeSyllabus,
                  AppConstants.typeNotice,
                ].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'e.g. Data Structures Notes Unit 1',
                prefixIcon: Icons.title_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Subject Name
              CustomTextField(
                controller: _subjectController,
                label: 'Subject Name',
                hint: 'e.g. Database Management Systems',
                prefixIcon: Icons.menu_book_rounded,
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
              const SizedBox(height: 16),

              // Question Paper Specific Fields
              if (_selectedType == AppConstants.typeQuestionPaper) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Exam Type',
                        value: _selectedExamType,
                        items: AppConstants.examTypes,
                        onChanged: (val) => setState(() => _selectedExamType = val!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        controller: _paperYearController,
                        label: 'Exam Year',
                        hint: 'e.g. 2024',
                        prefixIcon: Icons.calendar_month,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Description / Instructions',
                hint: 'Brief details about this study material...',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // File Attachment Box & Real Cloudinary Upload Action
              const Text(
                'Attach Document / PDF File',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),

              if (_uploadError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _uploadError!,
                          style: const TextStyle(fontSize: 12, color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              InkWell(
                onTap: _isUploading ? null : _handlePickAndUploadFile,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _uploadedFileUrl != null
                          ? AppColors.success
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_isUploading)
                        const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          _uploadedFileUrl != null
                              ? Icons.check_circle_rounded
                              : Icons.cloud_upload_outlined,
                          color: _uploadedFileUrl != null
                              ? AppColors.success
                              : AppColors.primary,
                          size: 28,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isUploading
                                  ? 'Uploading file to Cloudinary...'
                                  : (_uploadedFileName ?? (_pickedFile?.name ?? 'Tap to select PDF/Doc file')),
                              style: TextStyle(
                                color: _uploadedFileUrl != null
                                    ? AppColors.success
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_uploadedFileSize != null)
                              Text(
                                'Size: $_uploadedFileSize',
                                style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                              ),
                          ],
                        ),
                      ),
                      if (!_isUploading)
                        Text(
                          _uploadedFileUrl != null ? 'Change' : 'Browse',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Save / Publish Button
              CustomButton(
                text: isEdit ? 'Update Material' : 'Publish to SVPUAT Hub',
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
