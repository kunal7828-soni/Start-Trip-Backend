import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/spacing.dart';

/// Reusable center container signaling empty search results or trip ledgers.
class EmptyView extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Widget? actionButton;

  const EmptyView({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glowing visual graphic container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.vLG,
            Text(
              title,
              style: AppTextStyles.h3(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSM,
            Text(
              description,
              style: AppTextStyles.body(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionButton != null) ...[
              AppSpacing.vXL,
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}
