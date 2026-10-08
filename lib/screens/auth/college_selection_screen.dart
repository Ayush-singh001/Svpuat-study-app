import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/mock_state_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class CollegeSelectionScreen extends StatefulWidget {
  final bool isFromRegistration;

  const CollegeSelectionScreen({
    super.key,
    this.isFromRegistration = false,
  });

  @override
  State<CollegeSelectionScreen> createState() => _CollegeSelectionScreenState();
}

class _CollegeSelectionScreenState extends State<CollegeSelectionScreen> {
  @override
  void initState() {
    super.initState();
    _initSvpuatCollege();
  }

  Future<void> _initSvpuatCollege() async {
    final state = MockStateService();
    await state.fetchRealColleges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Top/Center Branding & Logo Emblem
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withAlpha(40), width: 2),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Main Heading
                const Text(
                  'SVPUAT Study App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle: University Name & Location
                const Text(
                  AppConstants.svpuatFullName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        AppConstants.svpuatLocation,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Center of Screen: Prominent Primary LOGIN Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Secondary Link: New Student? Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New student? ',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
