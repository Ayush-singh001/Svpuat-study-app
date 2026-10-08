import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/college_model.dart';
import '../../services/mock_state_service.dart';
import '../../widgets/custom_text_field.dart';

class ManageCollegesScreen extends StatefulWidget {
  const ManageCollegesScreen({super.key});

  @override
  State<ManageCollegesScreen> createState() => _ManageCollegesScreenState();
}

class _ManageCollegesScreenState extends State<ManageCollegesScreen> {
  @override
  Widget build(BuildContext context) {
    final stateService = MockStateService();
    final colleges = stateService.colleges;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Colleges'),
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
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => _confirmDeleteCollege(context, college),
                        tooltip: 'Delete',
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
                  if (college.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      college.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
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
                  hint: 'e.g. Stanford University',
                  prefixIcon: Icons.account_balance_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: codeController,
                  label: 'College Code / Abbreviation',
                  hint: 'e.g. STAN',
                  prefixIcon: Icons.code_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: locationController,
                  label: 'Location / City',
                  hint: 'e.g. California, USA',
                  prefixIcon: Icons.location_on_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: descController,
                  label: 'Description',
                  hint: 'Brief description of university...',
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
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final state = MockStateService();

              if (college == null) {
                final newCol = College(
                  id: 'col_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text.trim(),
                  code: codeController.text.trim().toUpperCase(),
                  location: locationController.text.trim(),
                  description: descController.text.trim(),
                );
                state.addCollege(newCol);
              } else {
                final updatedCol = college.copyWith(
                  name: nameController.text.trim(),
                  code: codeController.text.trim().toUpperCase(),
                  location: locationController.text.trim(),
                  description: descController.text.trim(),
                );
                state.editCollege(updatedCol);
              }

              Navigator.of(ctx).pop();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
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
        title: const Text('Delete College'),
        content: Text('Are you sure you want to delete "${college.name}"? All associated notes and papers will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              MockStateService().deleteCollege(college.id);
              Navigator.of(ctx).pop();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('College deleted successfully'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
