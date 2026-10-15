import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/college_model.dart';
import '../../models/content_model.dart';
import '../../services/college_service.dart';
import '../../services/mock_state_service.dart';
import '../../services/notes_service.dart';
import '../../services/notice_service.dart';
import '../../services/question_paper_service.dart';
import '../../services/subject_service.dart';
import '../../services/syllabus_service.dart';
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
  final SubjectService _subjectService = SubjectService();
  final CollegeService _collegeService = CollegeService();
  final NotesService _notesService = NotesService();
  final QuestionPaperService _paperService = QuestionPaperService();
  final SyllabusService _syllabusService = SyllabusService();
  final NoticeService _noticeService = NoticeService();

  String _selectedContentType = AppConstants.typeNotes; // 'Notes', 'Question Paper', 'Syllabus', 'Questions'

  // Six Linked Filter Dropdown States (Exact Order: Course, College, Department, Year, Semester, Subject)
  String _selectedCourse = AppConstants.courses.first;
  String _selectedCollegeId = AppConstants.svpuatCollegeId;
  String _selectedDepartment = AppConstants.departments.first;
  String _selectedYear = AppConstants.years[1];
  String _selectedSemester = AppConstants.semesters[2];
  String? _selectedSubject;

  List<College> _colleges = [];
  List<String> _dynamicDepartments = AppConstants.departments;
  List<String> _dynamicSubjects = [];
  List<StudyContent> _fetchedMaterials = [];

  bool _isLoadingColleges = false;
  bool _isLoadingSubjects = false;
  bool _isLoadingMaterials = false;
  String? _subjectError;
  String? _materialsError;

  @override
  void initState() {
    super.initState();
    final user = MockStateService().currentUser;
    if (user != null) {
      if (user.course != null && user.course!.isNotEmpty && AppConstants.courses.contains(user.course)) {
        _selectedCourse = user.course!;
      }
      if (user.collegeId.isNotEmpty) {
        _selectedCollegeId = user.collegeId;
      }
      if (user.department != null && user.department!.isNotEmpty && AppConstants.departments.contains(user.department)) {
        _selectedDepartment = user.department!;
      }
      if (user.year != null && user.year!.isNotEmpty && AppConstants.years.contains(user.year)) {
        _selectedYear = user.year!;
      }
      if (user.semester != null && user.semester!.isNotEmpty && AppConstants.semesters.contains(user.semester)) {
        _selectedSemester = user.semester!;
      }
    }
    _loadColleges();
  }

  Future<void> _loadColleges() async {
    setState(() {
      _isLoadingColleges = true;
    });

    try {
      final list = await _collegeService.getColleges();
      if (mounted) {
        setState(() {
          _colleges = list;
          final user = MockStateService().currentUser;
          if (user?.collegeId != null && user!.collegeId.isNotEmpty && _colleges.any((c) => c.id == user.collegeId)) {
            _selectedCollegeId = user.collegeId;
          } else if (_colleges.isNotEmpty) {
            final svpuatCol = _colleges.firstWhere(
              (c) => c.code == 'SVPUAT' || c.name.contains('Sardar Vallabhbhai Patel'),
              orElse: () => _colleges.first,
            );
            _selectedCollegeId = svpuatCol.id;
          }
          _isLoadingColleges = false;
        });
        _loadDepartmentsForSelectedCollege();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingColleges = false;
        });
        _loadDynamicSubjects();
      }
    }
  }

  Future<void> _loadDepartmentsForSelectedCollege() async {
    try {
      final depts = await _collegeService.getDepartments(_selectedCollegeId);
      if (mounted) {
        setState(() {
          if (depts.isNotEmpty) {
            _dynamicDepartments = depts;
            if (!_dynamicDepartments.contains(_selectedDepartment)) {
              _selectedDepartment = _dynamicDepartments.first;
            }
          }
        });
        _loadDynamicSubjects();
      }
    } catch (_) {
      _loadDynamicSubjects();
    }
  }

  Future<void> _loadDynamicSubjects() async {
    setState(() {
      _isLoadingSubjects = true;
      _subjectError = null;
    });

    try {
      final items = await _subjectService.getSubjects(
        course: _selectedCourse,
        department: _selectedDepartment,
        year: _selectedYear,
        semester: _selectedSemester,
        collegeId: _selectedCollegeId,
      );

      final dbNames = items.map((s) => s.name).where((name) => name.isNotEmpty).toList();

      if (mounted) {
        setState(() {
          _dynamicSubjects = dbNames;
          if (_selectedSubject == null || !_dynamicSubjects.contains(_selectedSubject)) {
            _selectedSubject = _dynamicSubjects.isNotEmpty ? _dynamicSubjects.first : null;
          }
          _isLoadingSubjects = false;
        });
        _loadMaterialsForCategory();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSubjects = false;
          _subjectError = 'Error loading subjects: ${e.toString().replaceAll("Exception: ", "")}';
        });
      }
    }
  }

  Future<void> _loadMaterialsForCategory() async {
    if (_selectedSubject == null || _selectedSubject!.isEmpty) {
      setState(() {
        _fetchedMaterials = [];
        _isLoadingMaterials = false;
      });
      return;
    }

    setState(() {
      _isLoadingMaterials = true;
      _materialsError = null;
    });

    try {
      List<StudyContent> results = [];
      if (_selectedContentType == AppConstants.typeNotes) {
        results = await _notesService.getNotes(
          course: _selectedCourse,
          department: _selectedDepartment,
          year: _selectedYear,
          semester: _selectedSemester,
          subject: _selectedSubject,
          collegeId: _selectedCollegeId,
        );
      } else if (_selectedContentType == AppConstants.typeQuestionPaper) {
        results = await _paperService.getQuestionPapers(
          course: _selectedCourse,
          department: _selectedDepartment,
          year: _selectedYear,
          semester: _selectedSemester,
          subject: _selectedSubject,
          collegeId: _selectedCollegeId,
        );
      } else if (_selectedContentType == AppConstants.typeSyllabus) {
        results = await _syllabusService.getSyllabus(
          course: _selectedCourse,
          department: _selectedDepartment,
          year: _selectedYear,
          semester: _selectedSemester,
          collegeId: _selectedCollegeId,
        );
      } else if (_selectedContentType == AppConstants.typeNotice) {
        results = await _noticeService.getNotices(
          department: _selectedDepartment,
          collegeId: _selectedCollegeId,
        );
      }

      if (mounted) {
        setState(() {
          _fetchedMaterials = results;
          _isLoadingMaterials = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMaterials = false;
          _materialsError = 'Error loading materials: ${e.toString().replaceAll("Exception: ", "")}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredContents = _fetchedMaterials
        .where((c) => c.fileUrl != null && c.fileUrl!.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Study Materials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Content',
            onPressed: () {
              _loadDynamicSubjects();
            },
          ),
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
          // Category Segment Bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

          // Six Linked Academic Filter Bar
          Container(
            padding: const EdgeInsets.all(14),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Course & College
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallDropdown(
                        label: '1. Course',
                        value: _selectedCourse,
                        items: AppConstants.courses,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedCourse = val;
                              _selectedSubject = null;
                              _fetchedMaterials = [];
                              _loadDynamicSubjects();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _isLoadingColleges
                          ? Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Row(
                                children: [
                                  SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                                  SizedBox(width: 8),
                                  Text('Colleges...', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                                ],
                              ),
                            )
                          : _colleges.isEmpty
                              ? _buildSmallDropdown(
                                  label: '2. College',
                                  value: AppConstants.svpuatFullName,
                                  items: [AppConstants.svpuatFullName],
                                  onChanged: (_) {},
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '2. College',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLight),
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
                                          value: _colleges.any((c) => c.id == _selectedCollegeId) ? _selectedCollegeId : _colleges.first.id,
                                          isExpanded: true,
                                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                                          items: _colleges.map((col) {
                                            return DropdownMenuItem<String>(
                                              value: col.id,
                                              child: Text(col.name, overflow: TextOverflow.ellipsis),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                _selectedCollegeId = val;
                                                _selectedSubject = null;
                                                _fetchedMaterials = [];
                                                _loadDepartmentsForSelectedCollege();
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Row 2: Department & Year
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallDropdown(
                        label: '3. Department',
                        value: _dynamicDepartments.contains(_selectedDepartment) ? _selectedDepartment : _dynamicDepartments.first,
                        items: _dynamicDepartments,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedDepartment = val;
                              _selectedSubject = null;
                              _fetchedMaterials = [];
                              _loadDynamicSubjects();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildSmallDropdown(
                        label: '4. Year',
                        value: _selectedYear,
                        items: AppConstants.years,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedYear = val;
                              _selectedSubject = null;
                              _fetchedMaterials = [];
                              _loadDynamicSubjects();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Row 3: Semester & Subject
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallDropdown(
                        label: '5. Semester',
                        value: _selectedSemester,
                        items: AppConstants.semesters,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedSemester = val;
                              _selectedSubject = null;
                              _fetchedMaterials = [];
                              _loadDynamicSubjects();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '6. Subject',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLight),
                          ),
                          const SizedBox(height: 4),
                          if (_isLoadingSubjects)
                            Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Row(
                                children: [
                                  SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                                  SizedBox(width: 8),
                                  Text('Loading...', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                                ],
                              ),
                            )
                          else if (_subjectError != null)
                            Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.errorBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.error.withAlpha(80)),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(_subjectError!, style: const TextStyle(fontSize: 10, color: AppColors.error), overflow: TextOverflow.ellipsis),
                              ),
                            )
                          else if (_dynamicSubjects.isEmpty)
                            Container(
                              height: 38,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text('No subjects available', style: TextStyle(fontSize: 11, color: AppColors.textLight, fontStyle: FontStyle.italic)),
                              ),
                            )
                          else
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
                                  value: _dynamicSubjects.contains(_selectedSubject) ? _selectedSubject : _dynamicSubjects.first,
                                  isExpanded: true,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                                  items: _dynamicSubjects.map((subj) {
                                    return DropdownMenuItem<String>(
                                      value: subj,
                                      child: Text(subj, overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedSubject = val;
                                      });
                                      _loadMaterialsForCategory();
                                    }
                                  },
                                ),
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
          const Divider(height: 1),

          // Main Materials List View
          Expanded(
            child: _selectedContentType == 'Questions'
                ? const ImportantQuestionsView()
                : _isLoadingMaterials
                    ? const LoadingStateView(message: 'Loading study materials...')
                    : _materialsError != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
                                  const SizedBox(height: 12),
                                  Text(_materialsError!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _loadMaterialsForCategory,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry Loading Materials'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : filteredContents.isEmpty
                            ? EmptyStateView(
                                title: 'No $_selectedContentType Found',
                                message: _selectedSubject != null
                                    ? 'No materials currently uploaded for $_selectedSubject in $_selectedSemester.'
                                    : 'No subjects or materials available for $_selectedSemester.',
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
          _loadMaterialsForCategory();
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
              value: items.contains(value) ? value : (items.isNotEmpty ? items.first : ''),
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
              if (item.unit != null && item.unit!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.unit!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
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
