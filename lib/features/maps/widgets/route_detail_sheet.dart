import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/maps_state_providers.dart';

/// Premium sliding bottom sheet panels presenting active polyline routing details.
/// Displays calculated distance values, duration ETAs, and start navigation triggers.
class RouteDetailSheet extends ConsumerWidget {
  final VoidCallback? onStartNavigation;

  const RouteDetailSheet({
    super.key,
    this.onStartNavigation,
  });

  String _formatETA(DateTime arrivalTime) {
    final hour = arrivalTime.hour > 12 
        ? arrivalTime.hour - 12 
        : (arrivalTime.hour == 0 ? 12 : arrivalTime.hour);
    final minute = arrivalTime.minute.toString().padLeft(2, '0');
    final period = arrivalTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapsStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (state.activeRoute.polylinePoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final route = state.activeRoute;
    final etaTime = route.estimatedArrivalTime;

    return Card(
      elevation: 16,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      shadowColor: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
      color: isDark ? AppColors.cardDark.withOpacity(0.96) : Colors.white.withOpacity(0.96),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Slide indicator
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Destination Name & Path Overview
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  radius: 20,
                  child: const Icon(Icons.directions, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.destinationName ?? 'Selected Destination',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        route.summary,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.error),
                  onPressed: () {
                    ref.read(mapsStateProvider.notifier).clearActiveRoute();
                  },
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),

            // Route Metrics Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Duration ETA
                _buildMetricColumn(
                  context,
                  title: 'Duration',
                  value: route.durationText,
                  icon: Icons.timer,
                  color: AppColors.primary,
                ),
                // 2. Distance Length
                _buildMetricColumn(
                  context,
                  title: 'Distance',
                  value: route.distanceText,
                  icon: Icons.alt_route,
                  color: AppColors.secondary,
                ),
                // 3. Exact ETA Timestamp
                _buildMetricColumn(
                  context,
                  title: 'ETA',
                  value: _formatETA(etaTime),
                  icon: Icons.schedule,
                  color: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Primary CTA Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Start Journey',
                    onPressed: () {
                      if (onStartNavigation != null) {
                        onStartNavigation!();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Starting premium GPS Turn-by-Turn voice assistance...'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
