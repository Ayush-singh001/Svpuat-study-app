import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../../services/fcm_service.dart';
import '../../services/mock_state_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../student/student_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _securityAnswerController = TextEditingController();

  String _selectedCourse = AppConstants.courses.first;
  String _selectedDepartment = AppConstants.departments.first;
  String _selectedYear = AppConstants.years[1];
  String _selectedSemester = AppConstants.semesters[2];
  String _selectedSecurityQuestion = AppConstants.securityQuestions.first;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _studentIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _securityAnswerController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Password and Confirm Password do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final state = MockStateService();
      final user = await _authService.registerStudent(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        studentId: _studentIdController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        course: _selectedCourse,
        department: _selectedDepartment,
        year: _selectedYear,
        semester: _selectedSemester,
        collegeId: state.selectedCollege?.id,
        securityQuestion: _selectedSecurityQuestion,
        securityAnswer: _securityAnswerController.text.trim(),
      );

      // Immediately set current user in state
      state.setCurrentUser(user);

      FcmService().syncTokenWithBackend();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully! Welcome ${user.fullName}'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Student Registration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SVPUAT Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withAlpha(35)),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 20,
                        child: Icon(Icons.school, color: Colors.white, size: 22),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.svpuatFullName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '${AppConstants.svpuatLocation} • Student Account Setup',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withAlpha(100)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 13, color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // SECTION 1: Personal Details
                _buildSectionTitle('1. Personal Details', Icons.person_outline_rounded),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'e.g. Rahul Sharma',
                  prefixIcon: Icons.badge_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'e.g. rahul@svpuat.ac.in',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || !val.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _mobileController,
                  label: 'Mobile Number',
                  hint: 'e.g. 9876543210',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.trim().length < 10) {
                      return 'Please enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // SECTION 2: Academic Details
                _buildSectionTitle('2. Academic Information', Icons.school_outlined),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _studentIdController,
                  label: 'Student ID / Roll Number',
                  hint: 'e.g. SVP2024CS012',
                  prefixIcon: Icons.fingerprint_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter Student ID / Roll Number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildDropdown(
                  label: 'Course',
                  value: _selectedCourse,
                  items: AppConstants.courses,
                  onChanged: (val) => setState(() => _selectedCourse = val!),
                ),
                const SizedBox(height: 14),
                _buildDropdown(
                  label: 'Department',
                  value: _selectedDepartment,
                  items: AppConstants.departments,
                  onChanged: (val) => setState(() => _selectedDepartment = val!),
                ),
                const SizedBox(height: 14),
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
                const SizedBox(height: 24),

                // SECTION 3: Security Question (for Password Recovery)
                _buildSectionTitle('3. Security Recovery Question', Icons.quiz_outlined),
                const SizedBox(height: 12),
                _buildDropdown(
                  label: 'Security Question',
                  value: _selectedSecurityQuestion,
                  items: AppConstants.securityQuestions,
                  onChanged: (val) => setState(() => _selectedSecurityQuestion = val!),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _securityAnswerController,
                  label: 'Security Answer',
                  hint: 'e.g. St. Xavier School',
                  prefixIcon: Icons.verified_user_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter security answer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // SECTION 4: Account Password
                _buildSectionTitle('4. Account Security', Icons.lock_outline_rounded),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password (min 8 chars)',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: (val) {
                    if (val == null || val.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_reset_rounded,
                  isPassword: true,
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please confirm your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Create Account Button
                CustomButton(
                  text: 'Create Student Account',
                  isLoading: _isLoading,
                  icon: Icons.person_add_rounded,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
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
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textLight),
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
