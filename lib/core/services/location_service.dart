import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';

/// Universal geolocation and system permissions manager for Trip Buddy.
class LocationService {
  const LocationService();

  /// Verify and request precise location permissions from the OS.
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) return true;

    final requestStatus = await Permission.location.request();
    if (requestStatus.isGranted) {
      AppLogger.i('Precise GPS location permission granted by user.');
      return true;
    }

    AppLogger.w('GPS location permission denied by user.');
    return false;
  }

  /// Lock current hardware GPS coordinate positions as a LatLng object.
  Future<LatLng> getCurrentPosition() async {
    final bool hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      throw const LocationException('Location permission is required to capture coordinates.');
    }

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('Location services are disabled on this device. Please enable GPS.');
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      AppLogger.e('Failed to capture device coordinate position', e);
      throw LocationException('Location lock timeout or capture error: ${e.toString()}');
    }
  }

  /// Listen to real-time streams of hardware coordinates changes.
  Stream<LatLng> getLiveCoordinatesStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Fire updates every 5 meters shifted
    );
    return Geolocator.getPositionStream(locationSettings: settings)
        .map((pos) => LatLng(pos.latitude, pos.longitude));
  }
}
