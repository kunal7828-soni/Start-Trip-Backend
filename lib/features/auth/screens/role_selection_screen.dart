import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/auth_layout.dart';
import '../../../core/widgets/primary_button.dart';

/// Selection of account privileges onboarding workflow.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _activeRole = 'user'; // 'user' (Traveler) or 'worker' (Partner)

  void _confirmRoleSelection() {
    // Redirect flow based on active select option
    if (_activeRole == 'worker') {
      context.go('/worker-dashboard');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: AuthLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.supervised_user_circle_rounded,
              size: 70,
              color: Colors.white,
            ),
            AppSpacing.vMD,
            Text(
              'Select Account Type',
              style: AppTextStyles.h1(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            Card(
              elevation: 8,
              color: isDark ? AppColors.cardDark.withOpacity(0.9) : Colors.white.withOpacity(0.92),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Choose Your Goal',
                      style: AppTextStyles.h3(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.vSM,
                    Text(
                      'Are you planning an adventure or looking to assist travelers along their journey?',
                      style: AppTextStyles.body(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Choice 1: Traveler (User)
                    _buildSelectionCard(
                      title: 'Traveler / Customer',
                      description: 'Search trains, book buses, locate transit, and plan excursions.',
                      roleValue: 'user',
                      icon: Icons.flight_takeoff_rounded,
                    ),
                    AppSpacing.vMD,

                    // Choice 2: Worker (Partner)
                    _buildSelectionCard(
                      title: 'Travel Partner / Worker',
                      description: 'Receive assigned transit tasks, accept guide bookings, and earn.',
                      roleValue: 'worker',
                      icon: Icons.local_taxi_rounded,
                    ),
                    const SizedBox(height: 40),

                    PrimaryButton(
                      text: 'Confirm and Continue',
                      onPressed: _confirmRoleSelection,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String description,
    required String roleValue,
    required IconData icon,
  }) {
    final isSelected = _activeRole == roleValue;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isSelected 
          ? AppColors.primary.withOpacity(0.08) 
          : (isDark ? AppColors.borderDark.withOpacity(0.3) : Colors.grey[100]),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2.0,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _activeRole = roleValue),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey,
                size: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.caption(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
