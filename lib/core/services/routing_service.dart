import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import '../../features/maps/models/route_details_model.dart';
import '../network/dio_client.dart';
import '../utils/logger.dart';

/// Clean Architecture service wrapper for OSRM (Open Source Routing Machine).
/// Handles coordinate driving directions path requests, distance meters, and travel duration seconds.
class RoutingService {
  final DioClient _dioClient;

  RoutingService(this._dioClient);

  /// Fetch path lines data via OSRM Web API connecting source and destination.
  Future<RouteDetailsModel> getDirectionsRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final String urlString = 'https://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson';

    try {
      AppLogger.i('OSRM routing engine request url: $urlString');
      
      final response = await _dioClient.instance.get(
        urlString,
        options: Options(
          headers: {
            'User-Agent': 'com.tripbuddy.app', // Required by OSRM open guidelines
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data is String 
            ? json.decode(response.data) 
            : response.data;
            
        final List<dynamic> routes = data['routes'] ?? [];
        if (routes.isNotEmpty) {
          final route = routes.first;
          
          final double distanceMeters = double.tryParse(route['distance']?.toString() ?? '') ?? 0.0;
          final double durationSeconds = double.tryParse(route['duration']?.toString() ?? '') ?? 0.0;
          final String summary = route['name'] ?? 'Via Local Highway';

          final geometry = route['geometry'] ?? {};
          final List<dynamic> coords = geometry['coordinates'] ?? [];
          
          final List<LatLng> waypoints = [];
          for (final coord in coords) {
            if (coord is List && coord.length >= 2) {
              final double lon = double.parse(coord[0].toString());
              final double lat = double.parse(coord[1].toString());
              waypoints.add(LatLng(lat, lon));
            }
          }

          if (waypoints.isEmpty) {
            waypoints.addAll([origin, destination]);
          }

          // Format readable strings
          final double distanceKm = distanceMeters / 1000.0;
          final int minutes = (durationSeconds / 60.0).round();
          
          final String distanceText = '${distanceKm.toStringAsFixed(1)} km';
          final String durationText = minutes > 60 
              ? '${(minutes / 60).floor()} hr ${minutes % 60} min' 
              : '$minutes mins';

          return RouteDetailsModel(
            polylinePoints: waypoints,
            distanceText: distanceText,
            distanceValueMeters: distanceMeters.toInt(),
            durationText: durationText,
            durationValueSeconds: durationSeconds.toInt(),
            summary: summary,
          );
        }
      }
      
      throw Exception('OSRM API returned empty routing options');
    } catch (e) {
      AppLogger.e('OSRM routing query failed: $e. Using local curved path fallback.', e);
      return _generateMockRoute(origin, destination);
    }
  }

  /// Synthesize a premium route interpolation for offline / rate-limited testing
  RouteDetailsModel _generateMockRoute(LatLng origin, LatLng destination) {
    final List<LatLng> points = [];
    
    // Create detailed curved intermediate grid waypoints
    final int stepCount = 8;
    for (int i = 0; i <= stepCount; i++) {
      final double fraction = i / stepCount;
      double lat = origin.latitude + (destination.latitude - origin.latitude) * fraction;
      double lng = origin.longitude + (destination.longitude - origin.longitude) * fraction;
      
      // Introduce curving offsets
      if (i > 0 && i < stepCount) {
        final double curveOffset = 0.003 * (i % 2 == 0 ? 1 : -1);
        lat += curveOffset * (1.0 - fraction) * fraction;
        lng += curveOffset * (1.0 - fraction) * fraction;
      }
      points.add(LatLng(lat, lng));
    }

    // Estimate realistic traveling metrics
    final double latDiff = (origin.latitude - destination.latitude).abs();
    final double lngDiff = (origin.longitude - destination.longitude).abs();
    final double approxDistanceDegree = latDiff + lngDiff;
    
    final double distanceKm = approxDistanceDegree * 111.0;
    final int distanceMeters = (distanceKm * 1000).toInt();
    
    final double travelHours = distanceKm / 45.0; // Assume 45 km/h driving speed
    final int durationSeconds = (travelHours * 3600).toInt();
    
    final int minutes = (durationSeconds / 60).round();
    final String durationText = minutes > 60 
        ? '${(minutes / 60).floor()} hr ${minutes % 60} min' 
        : '$minutes mins';

    return RouteDetailsModel(
      polylinePoints: points,
      distanceText: '${distanceKm.toStringAsFixed(1)} km',
      distanceValueMeters: distanceMeters,
      durationText: durationText,
      durationValueSeconds: durationSeconds,
      summary: 'Via Grid Connector (Offline Route)',
    );
  }
}
