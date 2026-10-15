import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../services/subject_service.dart';
import 'custom_text_field.dart';

/// Cleans a typed subject name: trims and collapses repeated spaces.
String normalizeSubject(String input) =>
    input.replaceAll(RegExp(r'\s+'), ' ').trim();

/// Subject text field for admin forms. There is no separate "Manage Subjects"
/// list any more: the admin types a subject name (or taps an existing one shown
/// as a chip) and that name is saved with the material / question. Students then
/// see the same subject automatically.
class SubjectField extends StatefulWidget {
  final TextEditingController controller;
  final String course;
  final String department;
  final String year;
  final String semester;
  final bool required;

  const SubjectField({
    super.key,
    required this.controller,
    required this.course,
    required this.department,
    required this.year,
    required this.semester,
    this.required = true,
  });

  @override
  State<SubjectField> createState() => _SubjectFieldState();
}

class _SubjectFieldState extends State<SubjectField> {
  final SubjectService _service = SubjectService();
  List<String> _existing = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant SubjectField old) {
    super.didUpdateWidget(old);
    if (old.course != widget.course ||
        old.department != widget.department ||
        old.year != widget.year ||
        old.semester != widget.semester) {
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final items = await _service.getSubjects(
        course: widget.course,
        department: widget.department,
        year: widget.year,
        semester: widget.semester,
      );
      if (!mounted) return;
      setState(() {
        _existing = items.map((e) => e.name).where((n) => n.isNotEmpty).toList();
      });
    } catch (_) {
      // Suggestions are optional; typing a new subject always works.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: widget.controller,
          label: 'Subject Name',
          hint: 'e.g. Database Management Systems',
          prefixIcon: Icons.menu_book_rounded,
          onChanged: (_) => setState(() {}),
          validator: (val) {
            if (!widget.required) return null;
            final v = normalizeSubject(val ?? '');
            if (v.length < 2) return 'Please enter subject name';
            return null;
          },
        ),
        if (_existing.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Existing subjects for this semester (tap to use):',
            style: TextStyle(fontSize: 11, color: AppColors.textLight),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 0,
            children: _existing.map((name) {
              final selected = normalizeSubject(widget.controller.text).toLowerCase() ==
                  name.toLowerCase();
              return ChoiceChip(
                label: Text(name, style: const TextStyle(fontSize: 11)),
                selected: selected,
                visualDensity: VisualDensity.compact,
                onSelected: (_) {
                  setState(() => widget.controller.text = name);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
