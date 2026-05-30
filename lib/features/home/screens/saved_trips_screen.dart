import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class SavedTripsScreen extends StatelessWidget {
  const SavedTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, String>> mockSavedTrips = [
      {
        'title': 'Summer Getaway: Swiss Alps',
        'dates': 'July 12 - July 20, 2026',
        'details': '2 Train connections booked • Guide Carlos Mendez hired',
      },
      {
        'title': 'Weekend Retreat: Washington DC',
        'dates': 'August 08 - August 10, 2026',
        'details': 'Bus line tickets booked bolt express',
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Trips'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: mockSavedTrips.length,
        itemBuilder: (context, index) {
          final trip = mockSavedTrips[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trip['title']!,
                        style: AppTextStyles.title(
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark_remove_rounded, color: AppColors.secondary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  AppSpacing.vXS,
                  Row(
                    children: [
                      const Icon(Icons.date_range_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        trip['dates']!,
                        style: AppTextStyles.bodyMedium(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    trip['details']!,
                    style: AppTextStyles.body(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ).copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
