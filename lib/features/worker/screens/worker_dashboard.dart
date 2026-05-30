import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  bool _isOnline = false;

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
        title: const Text('Partner Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () => context.go('/worker-notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Switch Panel Card
            Card(
              color: _isOnline 
                  ? AppColors.primary.withOpacity(0.08) 
                  : (isDark ? AppColors.borderDark.withOpacity(0.3) : Colors.grey[100]),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _isOnline ? AppColors.primary : Colors.transparent,
                  width: 0.8,
                ),
              ),
              child: SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isOnline ? AppColors.success.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.circle,
                    color: _isOnline ? AppColors.success : Colors.grey,
                  ),
                ),
                title: Text(
                  _isOnline ? 'Online & Accepting Trips' : 'Offline / On Break',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _isOnline ? 'Vetted travelers can locate you on map.' : 'Go online to receive nearby service requests.',
                  style: const TextStyle(fontSize: 12),
                ),
                value: _isOnline,
                onChanged: (val) => setState(() => _isOnline = val),
              ),
            ),
            const SizedBox(height: 24),

            // Earnings quick index grid
            Text(
              'Earnings Summary',
              style: AppTextStyles.title(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.vMD,
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: '\$342.50',
                    subtitle: 'Today Earnings',
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: '14',
                    subtitle: 'Completed Trips',
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Active / Assigned trips preview header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Assigned Transit Tasks',
                  style: AppTextStyles.title(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.go('/worker-trips'),
                  child: const Text('View All'),
                ),
              ],
            ),
            AppSpacing.vSM,

            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.airport_shuttle_rounded, color: AppColors.secondary),
                ),
                title: const Text('Transfer Task: Bhopal Station to Airport'),
                subtitle: const Text('Passenger: Sarah Jenkins • Scheduled: July 12, 2026'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/worker-trips'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            AppSpacing.vXS,
            Text(
              subtitle,
              style: AppTextStyles.caption(),
            ),
          ],
        ),
      ),
    );
  }
}
