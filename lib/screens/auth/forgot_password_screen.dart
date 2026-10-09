import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _authService = AuthService();

  // Student QA Reset Controllers
  final _studentIdentifierController = TextEditingController();
  final _studentAnswerController = TextEditingController();
  final _studentNewPassController = TextEditingController();
  final _studentConfirmPassController = TextEditingController();
  final _studentFormKey = GlobalKey<FormState>();

  bool _isFetchingQuestion = false;
  bool _isResettingPassword = false;
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;

  String? _retrievedQuestion;
  String? _studentError;

  // Admin Email Reset Controller
  final _adminEmailController = TextEditingController();
  final _adminFormKey = GlobalKey<FormState>();
  bool _isSendingAdminEmail = false;
  String? _adminError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _studentIdentifierController.dispose();
    _studentAnswerController.dispose();
    _studentNewPassController.dispose();
    _studentConfirmPassController.dispose();
    _adminEmailController.dispose();
    super.dispose();
  }

  void _handleFetchQuestion() async {
    if (_studentIdentifierController.text.trim().isEmpty) {
      setState(() {
        _studentError = 'Please enter Student ID or Email address';
      });
      return;
    }

    setState(() {
      _isFetchingQuestion = true;
      _studentError = null;
    });

    try {
      final question = await _authService.getStudentSecurityQuestion(
        _studentIdentifierController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _retrievedQuestion = question;
        _isFetchingQuestion = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetchingQuestion = false;
        _studentError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _handleResetStudentPassword() async {
    if (!_studentFormKey.currentState!.validate()) return;

    if (_studentNewPassController.text != _studentConfirmPassController.text) {
      setState(() {
        _studentError = 'New password and confirm password do not match';
      });
      return;
    }

    setState(() {
      _isResettingPassword = true;
      _studentError = null;
    });

    try {
      final message = await _authService.resetStudentPasswordWithQA(
        identifier: _studentIdentifierController.text.trim(),
        securityAnswer: _studentAnswerController.text.trim(),
        newPassword: _studentNewPassController.text,
        confirmPassword: _studentConfirmPassController.text,
      );

      if (!mounted) return;

      setState(() {
        _isResettingPassword = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isResettingPassword = false;
        _studentError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _handleSendAdminEmail() async {
    if (!_adminFormKey.currentState!.validate()) return;

    setState(() {
      _isSendingAdminEmail = true;
      _adminError = null;
    });

    try {
      final message = await _authService.requestForgotPassword(
        _adminEmailController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isSendingAdminEmail = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primary,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSendingAdminEmail = false;
        _adminError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Password Reset Help'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Student Q&A Reset'),
            Tab(text: 'Admin Email Reset'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Student Security Q&A Reset
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _studentFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.quiz_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student Password Reset',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Answer your registered security question to set a new password.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (_studentError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withAlpha(100)),
                      ),
                      child: Text(
                        _studentError!,
                        style: const TextStyle(fontSize: 13, color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // STEP 1: Enter Identifier
                  CustomTextField(
                    controller: _studentIdentifierController,
                    label: 'Student ID / Roll Number or Email',
                    hint: 'e.g. SVP2024CS012 or rahul@svpuat.ac.in',
                    prefixIcon: Icons.fingerprint_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter Student ID / Email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  if (_retrievedQuestion == null) ...[
                    CustomButton(
                      text: 'Fetch Security Question',
                      isLoading: _isFetchingQuestion,
                      icon: Icons.search_rounded,
                      onPressed: _handleFetchQuestion,
                    ),
                  ] else ...[
                    // STEP 2: Display Security Question & Password Reset Form
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withAlpha(35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Registered Security Question:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _retrievedQuestion!,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _studentAnswerController,
                      label: 'Security Answer',
                      hint: 'Enter your security answer',
                      prefixIcon: Icons.verified_user_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your security answer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: _studentNewPassController,
                      label: 'New Password (min 8 chars)',
                      hint: '••••••••',
                      prefixIcon: Icons.key_rounded,
                      isPassword: true,
                      obscureText: _obscureNewPass,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureNewPass = !_obscureNewPass;
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
                      controller: _studentConfirmPassController,
                      label: 'Confirm New Password',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_reset_rounded,
                      isPassword: true,
                      obscureText: _obscureConfirmPass,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirmPass = !_obscureConfirmPass;
                        });
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    CustomButton(
                      text: 'Reset Student Password',
                      isLoading: _isResettingPassword,
                      icon: Icons.check_circle_rounded,
                      onPressed: _handleResetStudentPassword,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // TAB 2: Admin Email Reset Link
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _adminFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.secondary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Email Password Reset',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Receive a password reset link at your registered College Admin / Super Admin email.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (_adminError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withAlpha(100)),
                      ),
                      child: Text(
                        _adminError!,
                        style: const TextStyle(fontSize: 13, color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  CustomTextField(
                    controller: _adminEmailController,
                    label: 'Admin Email Address',
                    hint: 'admin@college.edu',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || !val.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  CustomButton(
                    text: 'Send Reset Link',
                    isLoading: _isSendingAdminEmail,
                    icon: Icons.send_rounded,
                    onPressed: _handleSendAdminEmail,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
