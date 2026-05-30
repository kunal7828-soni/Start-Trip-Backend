import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class NearbyPlacesScreen extends StatelessWidget {
  const NearbyPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, String>> mockPlaces = [
      {
        'name': 'Bhopal Central Rail Terminal',
        'distance': '1.2 km away',
        'type': 'Transit Terminal',
      },
      {
        'name': 'Ismail Bus Terminal Block-A',
        'distance': '2.5 km away',
        'type': 'Bus Station',
      },
      {
        'name': ' Carlos Mendez (Vetted Guide)',
        'distance': '0.8 km away',
        'type': 'Vetted Guide',
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Nearby'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Centered CTA to render Live maps routing
            Card(
              color: AppColors.primary.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.primary, width: 0.8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.map_rounded, size: 48, color: AppColors.primary),
                    AppSpacing.vMD,
                    Text(
                      'Live Interactive OpenStreetMap',
                      style: AppTextStyles.title(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.vXS,
                    Text(
                      'Load real-time tile maps, locate your precise GPS coordinate limits, and trace routes.',
                      style: AppTextStyles.body(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ).copyWith(fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      child: const Text('Launch Map Preview'),
                      onPressed: () => context.go('/maps-preview'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Local Services & Terminals',
              style: AppTextStyles.title(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.vMD,

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mockPlaces.length,
              itemBuilder: (context, index) {
                final place = mockPlaces[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                    ),
                    title: Text(
                      place['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${place['type']} • ${place['distance']}'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
