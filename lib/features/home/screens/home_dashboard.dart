import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/search_bar_widget.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('Trip Buddy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hello /Greeting Header
            Text(
              'Explore The World',
              style: AppTextStyles.h1(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ).copyWith(fontSize: 28),
            ),
            AppSpacing.vXS,
            Text(
              'Locate transits and hire vetted guides in real-time.',
              style: AppTextStyles.body(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),

            // Premium Search Bar
            SearchBarWidget(
              onFilterPressed: () {},
            ),
            const SizedBox(height: 32),

            // Transit quick actions segment
            Text(
              'Transit Services',
              style: AppTextStyles.title(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.vMD,
            Row(
              children: [
                Expanded(
                  child: _buildServiceCard(
                    context,
                    title: 'Search Routes',
                    subtitle: 'Trains & Scheduling',
                    icon: Icons.directions_railway_filled_rounded,
                    color: const Color(0xFF0284C7),
                    onTap: () => context.go('/search-trip'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildServiceCard(
                    context,
                    title: 'Explore Live',
                    subtitle: 'OSM Nearby Pins',
                    icon: Icons.map_rounded,
                    color: AppColors.secondary,
                    onTap: () => context.go('/nearby-places'),
                  ),
                ),
              ],
            ),
            AppSpacing.vLG,

            // Quick Banner Card
            Card(
              elevation: 0,
              color: AppColors.primary.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.primary, width: 0.8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Smart Planner',
                            style: AppTextStyles.title(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                          ),
                          AppSpacing.vXS,
                          Text(
                            'Craft dynamic, custom itineraries in under 30 seconds using advanced artificial intelligence.',
                            style: AppTextStyles.caption(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Traveler Active trips preview header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Journeys',
                  style: AppTextStyles.title(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.go('/saved-trips'),
                  child: const Text('View All'),
                ),
              ],
            ),
            AppSpacing.vSM,

            // Journey preview row cards
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.explore, color: AppColors.secondary),
                ),
                title: const Text('Summer Getaway: Swiss Alps'),
                subtitle: const Text('Departure: July 12, 2026 • 2 Train Connections'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/saved-trips'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
