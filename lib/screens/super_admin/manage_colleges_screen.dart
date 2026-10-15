import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/college_model.dart';
import '../../services/college_service.dart';
import '../../services/mock_state_service.dart';
import '../../widgets/custom_text_field.dart';

class ManageCollegesScreen extends StatefulWidget {
  const ManageCollegesScreen({super.key});

  @override
  State<ManageCollegesScreen> createState() => _ManageCollegesScreenState();
}

class _ManageCollegesScreenState extends State<ManageCollegesScreen> {
  final CollegeService _collegeService = CollegeService();
  final Map<String, List<String>> _collegeDepartmentsMap = {};
  final Set<String> _loadingDepts = {};

  @override
  void initState() {
    super.initState();
    _loadAllCollegeDepartments();
  }

  Future<void> _loadAllCollegeDepartments() async {
    final colleges = MockStateService().colleges;
    for (var col in colleges) {
      _fetchDepartmentsForCollege(col.id);
    }
  }

  Future<void> _fetchDepartmentsForCollege(String collegeId) async {
    setState(() {
      _loadingDepts.add(collegeId);
    });

    try {
      final depts = await _collegeService.getDepartments(collegeId);
      if (mounted) {
        setState(() {
          _collegeDepartmentsMap[collegeId] = depts;
          _loadingDepts.remove(collegeId);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingDepts.remove(collegeId);
        });
      }
    }
  }

  void _showAddDepartmentDialog(BuildContext context, College college) {
    final deptNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Department to ${college.name}'),
        content: Form(
          key: formKey,
          child: CustomTextField(
            controller: deptNameController,
            label: 'Department Name',
            hint: 'e.g. Agronomy or Horticulture',
            prefixIcon: Icons.domain,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter department name' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final deptName = deptNameController.text.trim();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();

              try {
                final updatedList = await _collegeService.addDepartment(
                  collegeId: college.id,
                  name: deptName,
                );
                if (mounted) {
                  setState(() {
                    _collegeDepartmentsMap[college.id] = updatedList;
                  });
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Department "$deptName" added to ${college.name}'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error adding department: ${e.toString().replaceAll("Exception: ", "")}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Add Department'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDepartment(BuildContext context, College college, String deptName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text('Deactivate department "$deptName" from ${college.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();
              try {
                final updatedList = await _collegeService.deleteDepartment(
                  collegeId: college.id,
                  name: deptName,
                );
                if (mounted) {
                  setState(() {
                    _collegeDepartmentsMap[college.id] = updatedList;
                  });
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Department "$deptName" deactivated.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error deleting department: ${e.toString().replaceAll("Exception: ", "")}'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stateService = MockStateService();
    final colleges = stateService.colleges;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Colleges & Departments'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditCollegeDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add College', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: colleges.length,
        itemBuilder: (context, index) {
          final college = colleges[index];
          final depts = _collegeDepartmentsMap[college.id] ?? [];
          final isDeptLoading = _loadingDepts.contains(college.id);

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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          college.code,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                        onPressed: () => _showAddEditCollegeDialog(context, college: college),
                        tooltip: 'Edit College',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => _confirmDeleteCollege(context, college),
                        tooltip: 'Deactivate College',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    college.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        college.location,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),

                  // Department Management Sub-Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Departments',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddDepartmentDialog(context, college),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Dept', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  if (isDeptLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('Loading departments...', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                        ],
                      ),
                    )
                  else if (depts.isEmpty)
                    const Text('No active departments configured.', style: TextStyle(fontSize: 12, color: AppColors.textLight, fontStyle: FontStyle.italic))
                  else
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: depts.map((d) {
                        return Chip(
                          label: Text(d, style: const TextStyle(fontSize: 11)),
                          backgroundColor: AppColors.background,
                          deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.error),
                          onDeleted: () => _confirmDeleteDepartment(context, college, d),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddEditCollegeDialog(BuildContext context, {College? college}) {
    final nameController = TextEditingController(text: college?.name ?? '');
    final codeController = TextEditingController(text: college?.code ?? '');
    final locationController = TextEditingController(text: college?.location ?? '');
    final descController = TextEditingController(text: college?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(college == null ? 'Add New College' : 'Edit College'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: nameController,
                  label: 'College Name',
                  hint: 'e.g. College of Agriculture',
                  prefixIcon: Icons.account_balance_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: codeController,
                  label: 'College Code / Abbreviation',
                  hint: 'e.g. COA',
                  prefixIcon: Icons.code_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: locationController,
                  label: 'Location / City',
                  hint: 'e.g. Meerut, UP',
                  prefixIcon: Icons.location_on_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: descController,
                  label: 'Description',
                  hint: 'Brief description of college...',
                  prefixIcon: Icons.info_outline,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final state = MockStateService();
              final messenger = ScaffoldMessenger.of(context);

              if (college == null) {
                final newCol = College(
                  id: 'col_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text.trim(),
                  code: codeController.text.trim().toUpperCase(),
                  location: locationController.text.trim(),
                  description: descController.text.trim(),
                );
                await state.addCollegeReal(newCol);
              } else {
                final updatedCol = college.copyWith(
                  name: nameController.text.trim(),
                  code: codeController.text.trim().toUpperCase(),
                  location: locationController.text.trim(),
                  description: descController.text.trim(),
                );
                state.editCollege(updatedCol);
              }

              if (!context.mounted) return;
              Navigator.pop(ctx);
              setState(() {});
              messenger.showSnackBar(
                SnackBar(
                  content: Text(college == null ? 'College added!' : 'College updated!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(college == null ? 'Save' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCollege(BuildContext context, College college) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate College'),
        content: Text('Are you sure you want to deactivate "${college.name}"? It will no longer be available for new student selections or uploads.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(ctx).pop();
              await MockStateService().deleteCollegeReal(college.id);
              if (mounted) {
                setState(() {});
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('College "${college.name}" deactivated successfully.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
}
