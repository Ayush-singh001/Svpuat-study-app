import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../services/mock_state_service.dart';
import 'auth/college_selection_screen.dart';
import 'student/student_dashboard_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'super_admin/super_admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    _splashTimer = Timer(const Duration(seconds: 2), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() async {
    if (!mounted) return;
    final state = MockStateService();

    try {
      await state.initSession().timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Session init timeout or fallback: $e');
    }

    if (!mounted) return;

    if (state.isLoggedIn) {
      final user = state.currentUser!;
      if (user.isSuperAdmin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SuperAdminDashboardScreen()),
        );
      } else if (user.isCollegeAdmin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
        );
      }
    } else {
      // First let student pick college or go to login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CollegeSelectionScreen()),
      );
    }
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withAlpha(50), width: 2),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    AppConstants.appName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Multi-College Learning Portal',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'v${AppConstants.appVersion}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withAlpha(128),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
