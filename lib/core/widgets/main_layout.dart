import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/navigation_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../theme/app_text_styles.dart';

/// Collapsible navigation drawer.
class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

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
              gradient: AppColors.primaryGradient,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, size: 40, color: Colors.white),
            ),
            accountName: Text(
              'Sarah Jenkins',
              style: AppTextStyles.title(color: Colors.white),
            ),
            accountEmail: Text(
              'sarah.jenkins@example.com',
              style: AppTextStyles.caption(color: Colors.white70),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined, color: AppColors.primary),
            title: const Text('Dashboard'),
            onTap: () {
              context.pop();
              context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.search, color: AppColors.primary),
            title: const Text('Search Trips'),
            onTap: () {
              context.pop();
              context.go('/search-trip');
            },
          ),
          ListTile(
            leading: const Icon(Icons.map_outlined, color: AppColors.primary),
            title: const Text('Explore Places'),
            onTap: () {
              context.pop();
              context.go('/nearby-places');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_outline_rounded, color: AppColors.primary),
            title: const Text('Saved Routes'),
            onTap: () {
              context.pop();
              context.go('/saved-trips');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
            title: const Text('Profile Settings'),
            onTap: () {
              context.pop();
              context.go('/profile');
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

/// Traveler shell layout mapping pages to navigation parameters reactively.
class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = ref.watch(travelerNavProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Synchronize bottom bar taps with go_router configurations
    void onTabTapped(int index) {
      ref.read(travelerNavProvider.notifier).setIndex(index);
      switch (index) {
        case 0:
          context.go('/home');
          break;
        case 1:
          context.go('/search-trip');
          break;
        case 2:
          context.go('/nearby-places');
          break;
        case 3:
          context.go('/saved-trips');
          break;
        case 4:
          context.go('/profile');
          break;
      }
    }

    return Scaffold(
      drawer: const MainDrawer(),
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
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.travel_explore),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline_rounded),
              activeIcon: Icon(Icons.bookmark),
              label: 'Trips',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
