import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/route_names.dart';
import '../../../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Buddy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.pushNamed(RouteNames.profile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent Premium Header Greeting
            Text(
              'Where to next?',
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore transport, trips, and hire local guides.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Premium Floating Search Box Card
            Card(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.08),
              color: isDark ? AppColors.cardDark : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search destinations, trains, buses...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Quick Actions Segment
            Text(
              'Transit Services',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildServiceCard(
                    context,
                    icon: Icons.directions_railway_filled_rounded,
                    title: 'Train Routes',
                    subtitle: 'Schedules & rates',
                    color: const Color(0xFF0284C7),
                    onTap: () => context.pushNamed(RouteNames.railway),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildServiceCard(
                    context,
                    icon: Icons.directions_bus_filled_rounded,
                    title: 'Bus Booking',
                    subtitle: 'Reserve travel seats',
                    color: const Color(0xFF0D9488),
                    onTap: () => context.pushNamed(RouteNames.bus),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildServiceCard(
                    context,
                    icon: Icons.map_rounded,
                    title: 'Interactive Map',
                    subtitle: 'Nearby services',
                    color: AppColors.secondary,
                    onTap: () => context.pushNamed(RouteNames.maps),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildServiceCard(
                    context,
                    icon: Icons.assistant_navigation,
                    title: 'AI Companion',
                    subtitle: 'Instant travel plan',
                    color: const Color(0xFF8B5CF6),
                    onTap: () => context.pushNamed(RouteNames.aiAssistant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Nearby Workers Panel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Local Travel Partners',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.pushNamed(RouteNames.worker),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.handyman_rounded, color: AppColors.primary),
                ),
                title: const Text('Hire Local Guides & Assistance'),
                subtitle: const Text('Connect with vetted experts for custom transport needs.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(RouteNames.worker),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
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
                  color: color.withOpacity(0.15),
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
