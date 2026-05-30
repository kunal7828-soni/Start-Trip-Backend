import 'package:latlong2/latlong.dart';

/// Models geographic path waypoints and OSRM routing metrics.
class RouteDetailsModel {
  final List<LatLng> polylinePoints;
  final String distanceText;
  final int distanceValueMeters;
  final String durationText;
  final int durationValueSeconds;
  final String summary;

  const RouteDetailsModel({
    required this.polylinePoints,
    required this.distanceText,
    required this.distanceValueMeters,
    required this.durationText,
    required this.durationValueSeconds,
    required this.summary,
  });

  /// Factory constructor representing default empty routing values.
  factory RouteDetailsModel.empty() {
    return const RouteDetailsModel(
      polylinePoints: [],
      distanceText: '',
      distanceValueMeters: 0,
      durationText: '',
      durationValueSeconds: 0,
      summary: 'No route mapped',
    );
  }

  /// Estimated arrival timestamp calculation helper.
  DateTime get estimatedArrivalTime {
    return DateTime.now().add(Duration(seconds: durationValueSeconds));
  }
}
