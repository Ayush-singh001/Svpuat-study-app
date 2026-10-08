import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safely initialize FCM without blocking startup
  FcmService().init().catchError((e) {
    debugPrint('FCM Init Non-blocking Error: $e');
  });

  runApp(const CollegeStudyApp());
}

class CollegeStudyApp extends StatelessWidget {
  const CollegeStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
