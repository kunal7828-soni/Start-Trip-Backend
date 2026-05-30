import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class WorkerNotificationsScreen extends StatelessWidget {
  const WorkerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, String>> mockNotifications = [
      {
        'title': 'New Travel Request: Sarah Jenkins',
        'details': 'Route Bhopal to Airport scheduled for tomorrow. Fare: \$45.00',
        'time': '3 mins ago',
      },
      {
        'title': 'Rating Feedback Alert',
        'details': 'A traveler rated you 5.0 stars for your Swiss Alps city transfer!',
        'time': '2 hours ago',
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts Center'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: mockNotifications.length,
        itemBuilder: (context, index) {
          final notification = mockNotifications[index];
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
                      Expanded(
                        child: Text(
                          notification['title']!,
                          style: AppTextStyles.title(
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        notification['time']!,
                        style: AppTextStyles.caption(),
                      ),
                    ],
                  ),
                  AppSpacing.vXS,
                  Text(
                    notification['details']!,
                    style: AppTextStyles.body(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ).copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        child: const Text('View Detail', style: TextStyle(fontSize: 12)),
                        onPressed: () {},
                      ),
                    ],
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
