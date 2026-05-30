import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/maps_state_providers.dart';

/// Horizontally scrollable carousel panel allowing travelers to browse
/// nearby hotels, restaurants, transit hubs, and tourist attractions dynamically.
class NearbyPlacesCarousel extends ConsumerWidget {
  final Function(LatLng, String)? onPlaceSelected;

  const NearbyPlacesCarousel({
    super.key,
    this.onPlaceSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapsStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Categories mapping helper
    final List<Map<String, dynamic>> categories = [
      {'type': 'tourist_attraction', 'label': 'Attractions', 'icon': Icons.star_border_outlined},
      {'type': 'lodging', 'label': 'Hotels', 'icon': Icons.hotel_outlined},
      {'type': 'restaurant', 'label': 'Food & Drinks', 'icon': Icons.restaurant_outlined},
      {'type': 'bus_station', 'label': 'Bus Stops', 'icon': Icons.directions_bus_outlined},
      {'type': 'train_station', 'label': 'Railway', 'icon': Icons.directions_railway_outlined},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Horizontal Category Filter Chips row
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = state.activeNearbyType == cat['type'];
              
              return GestureDetector(
                onTap: () {
                  ref.read(mapsStateProvider.notifier).loadNearbyPlaces(cat['type']!);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary 
                        : (isDark ? AppColors.cardDark : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.transparent 
                          : (isDark ? Colors.white10 : Colors.black12),
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ] : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        cat['icon'] as IconData,
                        size: 16,
                        color: isSelected 
                            ? Colors.white 
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat['label'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? Colors.white 
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // 2. Carousel cards loader or scrollable items list
        SizedBox(
          height: 160,
          child: _buildCarouselContent(context, ref, state),
        ),
      ],
    );
  }

  Widget _buildCarouselContent(BuildContext context, WidgetRef ref, MapsState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (state.isSearchingNearby) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              'Searching nearby locations...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    if (state.nearbyPlaces.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'No locations found nearby in this area.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: state.nearbyPlaces.length,
      separatorBuilder: (context, index) => const SizedBox(width: 14),
      itemBuilder: (context, index) {
        final place = state.nearbyPlaces[index];
        final name = place['name'] ?? 'Famous Spot';
        final vicinity = place['vicinity'] ?? 'Nearby Area';
        final rating = place['rating']?.toDouble() ?? 4.5;
        final totalReviews = place['user_ratings_total'] ?? 100;
        
        final geometry = place['geometry'] ?? {};
        final location = geometry['location'] ?? {};
        final double? lat = location['lat'];
        final double? lng = location['lng'];

        return GestureDetector(
          onTap: () {
            if (lat != null && lng != null) {
              final coordinates = LatLng(lat, lng);
              ref.read(mapsStateProvider.notifier).setDestinationCoordinates(coordinates, name);
              
              if (onPlaceSelected != null) {
                onPlaceSelected!(coordinates, name);
              }
            }
          },
          child: Container(
            width: 250,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title and Rating row
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($totalReviews)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Vicinity and Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.near_me_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(height: 2),
                          Text(
                            vicinity,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
