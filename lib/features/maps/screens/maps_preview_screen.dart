import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/maps_state_providers.dart';
import '../widgets/floating_search_bar.dart';
import '../widgets/route_detail_sheet.dart';
import '../widgets/nearby_places_carousel.dart';

/// Redesigned interactive OpenStreetMap maps preview system for Trip Buddy.
/// Fully integrates flutter_map, OSRM directions paths, custom obsidian dark layers,
/// search autocompletes, dynamic bottom sheets, and hardware geolocation pins.
class MapsPreviewScreen extends ConsumerStatefulWidget {
  const MapsPreviewScreen({super.key});

  @override
  ConsumerState<MapsPreviewScreen> createState() => _MapsPreviewScreenState();
}

class _MapsPreviewScreenState extends ConsumerState<MapsPreviewScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Initialize GPS lock and retrieve initial landmarks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapsStateProvider.notifier).initializeMap();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Shift visual map camera smoothly to targeted coordinates
  void _animateToPosition(LatLng target, {double zoom = 14.5}) {
    _mapController.move(target, zoom);
  }

  /// Fit route path waypoints cleanly inside camera boundaries
  void _fitRouteBounds(List<LatLng> points) {
    if (points.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 120.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapsStateProvider);
    final notifier = ref.read(mapsStateProvider.notifier);
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Build custom map markers
    final List<Marker> mapMarkers = [];

    // 1. Current Location Marker (Pulse Ring)
    mapMarkers.add(
      Marker(
        point: state.currentLocation,
        width: 48,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 4,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // 2. Destination Marker (If loaded)
    if (state.destinationLocation != null) {
      mapMarkers.add(
        Marker(
          point: state.destinationLocation!,
          width: 48,
          height: 48,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.secondary,
                size: 32,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.black12, width: 0.5),
                ),
                child: Text(
                  state.destinationName ?? 'Destination',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 9, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Nearby overpass pin markers
    for (int i = 0; i < state.nearbyPlaces.length; i++) {
      final place = state.nearbyPlaces[i];
      final name = place['name'] ?? 'Local Point';
      final geometry = place['geometry'] ?? {};
      final location = geometry['location'] ?? {};
      final double? lat = location['lat'];
      final double? lng = location['lng'];

      if (lat != null && lng != null) {
        mapMarkers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                notifier.setDestinationCoordinates(LatLng(lat, lng), name);
              },
              child: const Icon(
                Icons.location_on,
                color: AppColors.warning,
                size: 26,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                  )
                ],
              ),
            ),
          ),
        );
      }
    }

    // Build route polylines
    final List<Polyline> mapPolylines = [];
    if (state.activeRoute.polylinePoints.isNotEmpty) {
      mapPolylines.add(
        Polyline(
          points: state.activeRoute.polylinePoints,
          strokeWidth: 5.0,
          color: AppColors.primary,
          borderColor: AppColors.primaryLight,
          borderStrokeWidth: 1.5,
        ),
      );
    }

    // Listen to changes to route to trigger camera boundary shifts
    ref.listen<MapsState>(mapsStateProvider, (previous, next) {
      if (previous?.activeRoute.polylinePoints.isEmpty == true &&
          next.activeRoute.polylinePoints.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fitRouteBounds(next.activeRoute.polylinePoints);
        });
      } else if (previous?.destinationLocation != next.destinationLocation &&
          next.destinationLocation != null &&
          next.activeRoute.polylinePoints.isEmpty) {
        _animateToPosition(next.destinationLocation!);
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // A. OpenStreetMap FlutterMap Canvas Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: state.currentLocation,
              initialZoom: 13.0,
              minZoom: 3.0,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (tapPosition, latLng) {
                notifier.setDestinationCoordinates(
                  latLng,
                  'Pinned Point (${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)})',
                );
              },
            ),
            children: [
              // 1. TileLayer: Load OSM map tiles with dynamic dark matrix overlay
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tripbuddy.app',
                tileBuilder: (context, tileWidget, tile) {
                  if (state.isDarkTheme) {
                    return ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        -0.21, -0.72, -0.07, 0, 255, // Invert Red
                        -0.21, -0.72, -0.07, 0, 255, // Invert Green
                        -0.21, -0.72, -0.07, 0, 255, // Invert Blue
                        0,     0,     0,     1, 0,
                      ]),
                      child: tileWidget,
                    );
                  }
                  return tileWidget;
                },
              ),

              // 2. PolylineLayer: Draw route geometries connecting points
              PolylineLayer(
                polylines: mapPolylines,
              ),

              // 3. MarkerLayer: Display live location, destinations, and amenities
              MarkerLayer(
                markers: mapMarkers,
              ),
            ],
          ),

          // B. Floating Top Autocomplete Search panel
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
              child: FloatingSearchBar(
                onLocationSelected: (LatLng target) {
                  _animateToPosition(target, zoom: 15.0);
                },
              ),
            ),
          ),

          // C. Custom Floating Map HUD Controls (GPS recenter, Theme configuration, zoom triggers)
          Positioned(
            right: 16,
            top: 100, // Positioned nicely below the Search Bar card
            child: Column(
              children: [
                // 1. Recenter GPS button
                FloatingActionButton.small(
                  heroTag: 'recenter_gps',
                  backgroundColor: isDark ? AppColors.cardDark.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                  foregroundColor: AppColors.primary,
                  onPressed: () {
                    notifier.initializeMap();
                    _animateToPosition(state.currentLocation, zoom: 14.5);
                  },
                  child: state.isLocating
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      : const Icon(Icons.gps_fixed, size: 20),
                ),
                const SizedBox(height: 10),

                // 2. Maps Theme Switch config
                FloatingActionButton.small(
                  heroTag: 'toggle_maps_theme',
                  backgroundColor: isDark ? AppColors.cardDark.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                  foregroundColor: AppColors.secondary,
                  onPressed: () {
                    notifier.toggleMapTheme();
                  },
                  child: Icon(state.isDarkTheme ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined, size: 20),
                ),
                const SizedBox(height: 10),

                // 3. Zoom In Button
                FloatingActionButton.small(
                  heroTag: 'zoom_in_trigger',
                  backgroundColor: isDark ? AppColors.cardDark.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                  foregroundColor: AppColors.primary,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      (_mapController.camera.zoom + 1.0).clamp(3.0, 18.0),
                    );
                  },
                  child: const Icon(Icons.add, size: 20),
                ),
                const SizedBox(height: 10),

                // 4. Zoom Out Button
                FloatingActionButton.small(
                  heroTag: 'zoom_out_trigger',
                  backgroundColor: isDark ? AppColors.cardDark.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                  foregroundColor: AppColors.primary,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      (_mapController.camera.zoom - 1.0).clamp(3.0, 18.0),
                    );
                  },
                  child: const Icon(Icons.remove, size: 20),
                ),
                const SizedBox(height: 10),

                // 5. Clear Active route button (if active)
                if (state.destinationLocation != null)
                  FloatingActionButton.small(
                    heroTag: 'clear_active_route',
                    backgroundColor: AppColors.error.withOpacity(0.9),
                    foregroundColor: Colors.white,
                    onPressed: () {
                      notifier.clearActiveRoute();
                      _animateToPosition(state.currentLocation);
                    },
                    child: const Icon(Icons.map_outlined, size: 20),
                  ),
              ],
            ),
          ),

          // D. Dynamic Overlay bottom sheets: Displays travel routes or nearby carousels
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                    child: child,
                  );
                },
                child: state.destinationLocation != null
                    // Display travel metrics panel
                    ? const RouteDetailSheet(key: ValueKey('route_sheet'))
                    // Display nearby carousels panel
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          NearbyPlacesCarousel(
                            key: const ValueKey('nearby_carousel'),
                            onPlaceSelected: (coordinates, name) {
                              _animateToPosition(coordinates, zoom: 15.0);
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
              ),
            ),
          ),

          // E. Global Error Alert Notification Banner
          if (state.errorMessage != null)
            Positioned(
              left: 16,
              right: 16,
              top: 80,
              child: Card(
                color: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
