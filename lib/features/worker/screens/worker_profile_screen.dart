import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/theme_provider.dart';

class WorkerProfileScreen extends ConsumerWidget {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeThemeMode = ref.watch(themeProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Centered User Header Card
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(
                      Icons.handyman_rounded,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  AppSpacing.vMD,
                  Text(
                    'Carlos Mendez',
                    style: AppTextStyles.h2(
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  AppSpacing.vXS,
                  Text(
                    'carlos.driver@example.com',
                    style: AppTextStyles.bodyMedium(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  AppSpacing.vMD,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '4.9 Rating',
                        style: AppTextStyles.title(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Profile Settings Card List
            _buildOptionCard(
              context,
              title: 'Vehicle Specs: Honda Odyssey',
              icon: Icons.airport_shuttle_rounded,
              color: Colors.blue,
              onTap: () {},
            ),
            AppSpacing.vMD,
            _buildOptionCard(
              context,
              title: 'Worker Registration Certifications',
              icon: Icons.verified_user_rounded,
              color: Colors.green,
              onTap: () {},
            ),
            AppSpacing.vMD,

            // Reactive Theme Switcher Option Card
            Card(
              child: SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.palette_outlined, color: Colors.purple),
                ),
                title: const Text('Dark Theme Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                value: activeThemeMode == ThemeMode.dark,
                onChanged: (val) {
                  ref.read(themeProvider.notifier).toggleTheme(val);
                },
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Logout Action Button
            ElevatedButton.icon(
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
