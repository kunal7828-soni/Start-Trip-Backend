import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeThemeMode = ref.watch(themeProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
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
                      Icons.person_rounded,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  AppSpacing.vMD,
                  Text(
                    'Sarah Jenkins',
                    style: AppTextStyles.h2(
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  AppSpacing.vXS,
                  Text(
                    'sarah.jenkins@example.com',
                    style: AppTextStyles.bodyMedium(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  AppSpacing.vMD,
                  Chip(
                    label: const Text('Premium Traveler'),
                    backgroundColor: AppColors.secondary.withOpacity(0.1),
                    labelStyle: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                    side: BorderSide.none,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Profile Settings Card List
            _buildOptionCard(
              context,
              title: 'Saved Places & Bookmarks',
              icon: Icons.bookmark_border_rounded,
              color: Colors.amber,
              onTap: () => context.go('/saved-trips'),
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
            AppSpacing.vMD,

            _buildOptionCard(
              context,
              title: 'Location Settings',
              icon: Icons.security_rounded,
              color: Colors.green,
              onTap: () {},
            ),
            AppSpacing.vMD,
            _buildOptionCard(
              context,
              title: 'Payment Cards',
              icon: Icons.credit_card_rounded,
              color: Colors.blue,
              onTap: () {},
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
