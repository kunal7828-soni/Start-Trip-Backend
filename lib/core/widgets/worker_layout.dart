import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/navigation_provider.dart';
import '../constants/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Worker flow collapsible navigation drawer.
class WorkerDrawer extends StatelessWidget {
  const WorkerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFF6366F1)], // Teal to Indigo
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.handyman_rounded, size: 40, color: Colors.white),
            ),
            accountName: Text(
              'Driver Carlos',
              style: AppTextStyles.title(color: Colors.white),
            ),
            accountEmail: Text(
              'carlos.driver@example.com',
              style: AppTextStyles.caption(color: Colors.white70),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.work_outline_rounded, color: AppColors.primary),
            title: const Text('Partner Portal'),
            onTap: () {
              context.pop();
              context.go('/worker-dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_turned_in_outlined, color: AppColors.primary),
            title: const Text('Assigned Trips'),
            onTap: () {
              context.pop();
              context.go('/worker-trips');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none_outlined, color: AppColors.primary),
            title: const Text('Alerts Center'),
            onTap: () {
              context.pop();
              context.go('/worker-notifications');
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_box_outlined, color: AppColors.primary),
            title: const Text('Profile Stats'),
            onTap: () {
              context.pop();
              context.go('/worker-profile');
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: Text('Sign Out', style: TextStyle(color: AppColors.error)),
            onTap: () {
              context.pop();
              context.go('/login');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Coordinated layout shell for workforce dashboard pages.
class WorkerLayout extends ConsumerWidget {
  final Widget child;

  const WorkerLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = ref.watch(workerNavProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    void onTabTapped(int index) {
      ref.read(workerNavProvider.notifier).setIndex(index);
      switch (index) {
        case 0:
          context.go('/worker-dashboard');
          break;
        case 1:
          context.go('/worker-trips');
          break;
        case 2:
          context.go('/worker-notifications');
          break;
        case 3:
          context.go('/worker-profile');
          break;
      }
    }

    return Scaffold(
      drawer: const WorkerDrawer(),
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: activeIndex,
          onTap: onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? AppColors.bgDark : Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          selectedLabelStyle: AppTextStyles.caption(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: AppTextStyles.caption(),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline_rounded),
              activeIcon: Icon(Icons.work),
              label: 'Portal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Trips',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box_outlined),
              activeIcon: Icon(Icons.account_box),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
