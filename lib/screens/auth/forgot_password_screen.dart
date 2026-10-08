import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Reset Help'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.support_agent_rounded,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Need Password Assistance?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'To ensure account security, student and faculty password resets are managed directly by the SVPUAT Academic Administration.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withAlpha(35)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Academic Cell:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Office: Registrar / Examination Cell'),
                  SizedBox(height: 4),
                  Text('• Email: registrar@svpuat.ac.in'),
                  SizedBox(height: 4),
                  Text('• University: ${AppConstants.svpuatFullName}'),
                  SizedBox(height: 4),
                  Text('• Location: ${AppConstants.svpuatLocation}'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Return to Login',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
