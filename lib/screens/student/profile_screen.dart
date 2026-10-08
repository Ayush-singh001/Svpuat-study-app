import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../services/mock_state_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/ui_helpers.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final stateService = MockStateService();
    if (stateService.currentUser == null) {
      setState(() {
        _isLoading = true;
      });
      await stateService.initSession();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (stateService.currentUser == null) {
        // Unauthenticated access attempt -> redirect to initial Login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateService = MockStateService();
    final user = stateService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Student Profile'),
      ),
      body: _isLoading
          ? const LoadingStateView(message: 'Loading student profile...')
          : user == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: _buildLoggedInUserView(context, user),
                ),
    );
  }

  Widget _buildLoggedInUserView(BuildContext context, AppUser user) {
    final stateService = MockStateService();

    return Column(
      children: [
        // Profile Avatar Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Roll No: ${user.studentId.isNotEmpty ? user.studentId : 'SVP2024CS012'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // University Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.account_balance_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.collegeName.isNotEmpty ? user.collegeName : AppConstants.svpuatFullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      AppConstants.svpuatLocation,
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Academic Info Card
        Card(
          child: Column(
            children: [
              _buildInfoTile(
                icon: Icons.email_outlined,
                title: 'Email Address',
                value: user.email,
              ),
              const Divider(height: 1),
              _buildInfoTile(
                icon: Icons.phone_outlined,
                title: 'Mobile Number',
                value: user.mobile.isNotEmpty ? user.mobile : '+91 9876543210',
              ),
              const Divider(height: 1),
              _buildInfoTile(
                icon: Icons.school_outlined,
                title: 'Course',
                value: user.course ?? 'B.Tech',
              ),
              const Divider(height: 1),
              _buildInfoTile(
                icon: Icons.business_outlined,
                title: 'Department',
                value: user.department ?? 'Computer Science & Engineering',
              ),
              const Divider(height: 1),
              _buildInfoTile(
                icon: Icons.calendar_today_outlined,
                title: 'Year & Semester',
                value: '${user.year ?? '2nd Year'} • ${user.semester ?? '3rd Semester'}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Sign Out Button
        CustomButton(
          text: 'Sign Out of SVPUAT Portal',
          isOutlined: true,
          icon: Icons.logout_rounded,
          onPressed: () {
            stateService.logout();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Logged out successfully.')),
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
