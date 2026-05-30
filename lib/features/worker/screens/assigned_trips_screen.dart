import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class AssignedTripsScreen extends StatelessWidget {
  const AssignedTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, String>> mockAssignments = [
      {
        'title': 'Station Transfer: Sarah Jenkins',
        'details': 'Route: Bhopal Central Terminal to Airport',
        'schedule': 'July 12, 2026 • 09:30 AM',
        'status': 'Confirmed',
      },
      {
        'title': 'Historic Tour Guide Request',
        'details': 'Walk: Old Bhopal Heritage Sightseeing',
        'schedule': 'July 14, 2026 • 10:00 AM',
        'status': 'Pending Approval',
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Tasks'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: mockAssignments.length,
        itemBuilder: (context, index) {
          final assignment = mockAssignments[index];
          final isConfirmed = assignment['status'] == 'Confirmed';

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
                          assignment['title']!,
                          style: AppTextStyles.title(
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isConfirmed 
                              ? AppColors.success.withOpacity(0.1) 
                              : AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          assignment['status']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isConfirmed ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vXS,
                  Text(
                    assignment['details']!,
                    style: AppTextStyles.body(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        assignment['schedule']!,
                        style: AppTextStyles.caption(),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        child: const Text('Accept', style: TextStyle(fontSize: 12)),
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
