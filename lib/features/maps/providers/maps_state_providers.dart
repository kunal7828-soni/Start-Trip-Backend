import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/places_service.dart';
import '../../../core/services/routing_service.dart';
import '../../../core/services/geocoding_service.dart';
import '../../../core/utils/logger.dart';
import '../../../providers/global_providers.dart';
import '../models/place_prediction_model.dart';
import '../models/route_details_model.dart';

// OpenStreetMap Clean Architecture Core Services Providers Injection
final placesServiceProvider = Provider<PlacesService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PlacesService(dioClient);
});

final routingServiceProvider = Provider<RoutingService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return RoutingService(dioClient);
});

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return GeocodingService(dioClient);
});

/// Immutable state class modeling the OpenStreetMap active UI parameters
class MapsState {
  final LatLng currentLocation;
  final LatLng? destinationLocation;
  final String? destinationName;
  final List<PlacePredictionModel> searchPredictions;
  final RouteDetailsModel activeRoute;
  final List<Map<String, dynamic>> nearbyPlaces;
  final String activeNearbyType; // lodging, restaurant, bus_station, train_station, tourist_attraction
  final bool isLocating;
  final bool isSearching;
  final bool isRouting;
  final bool isSearchingNearby;
  final String? errorMessage;
  final bool isDarkTheme;

  const MapsState({
    required this.currentLocation,
    this.destinationLocation,
    this.destinationName,
    this.searchPredictions = const [],
    required this.activeRoute,
    this.nearbyPlaces = const [],
    this.activeNearbyType = 'tourist_attraction',
    this.isLocating = false,
    this.isSearching = false,
    this.isRouting = false,
    this.isSearchingNearby = false,
    this.errorMessage,
    this.isDarkTheme = true,
  });

  MapsState copyWith({
    LatLng? currentLocation,
    LatLng? destinationLocation,
    String? destinationName,
    List<PlacePredictionModel>? searchPredictions,
    RouteDetailsModel? activeRoute,
    List<Map<String, dynamic>>? nearbyPlaces,
    String? activeNearbyType,
    bool? isLocating,
    bool? isSearching,
    bool? isRouting,
    bool? isSearchingNearby,
    String? errorMessage,
    bool? isDarkTheme,
  }) {
    return MapsState(
      currentLocation: currentLocation ?? this.currentLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      destinationName: destinationName ?? this.destinationName,
      searchPredictions: searchPredictions ?? this.searchPredictions,
      activeRoute: activeRoute ?? this.activeRoute,
      nearbyPlaces: nearbyPlaces ?? this.nearbyPlaces,
      activeNearbyType: activeNearbyType ?? this.activeNearbyType,
      isLocating: isLocating ?? this.isLocating,
      isSearching: isSearching ?? this.isSearching,
      isRouting: isRouting ?? this.isRouting,
      isSearchingNearby: isSearchingNearby ?? this.isSearchingNearby,
      errorMessage: errorMessage, // We allow setting to null
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
    );
  }
}

/// Unified Riverpod state manager for the OpenStreetMap interactive Maps Preview Screen.
class MapsStateNotifier extends StateNotifier<MapsState> {
  final LocationService _locationService;
  final PlacesService _placesService;
  final RoutingService _routingService;
  final GeocodingService _geocodingService;

  MapsStateNotifier({
    required LocationService locationService,
    required PlacesService placesService,
    required RoutingService routingService,
    required GeocodingService geocodingService,
  })  : _locationService = locationService,
        _placesService = placesService,
        _routingService = routingService,
        _geocodingService = geocodingService,
        super(MapsState(
          currentLocation: const LatLng(23.2599, 77.4126), // Default Bhopal center coordinates
          activeRoute: RouteDetailsModel.empty(),
        ));

  /// Initialize user position and fetch initial nearby attractions
  Future<void> initializeMap() async {
    state = state.copyWith(isLocating: true, errorMessage: null);
    try {
      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        state = state.copyWith(
          isLocating: false,
          errorMessage: 'Location permissions denied. Please enable them to view the map.',
        );
        return;
      }

      final position = await _locationService.getCurrentPosition();
      state = state.copyWith(
        currentLocation: position,
        isLocating: false,
      );

      // Pre-load nearby tourist attractions around locked location
      await loadNearbyPlaces('tourist_attraction');
    } catch (e) {
      state = state.copyWith(
        isLocating: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Trigger autocomplete location queries based on search inputs
  Future<void> searchAutocomplete(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchPredictions: []);
      return;
    }

    state = state.copyWith(isSearching: true);
    try {
      final predictions = await _geocodingService.getSearchSuggestions(query);
      state = state.copyWith(
        searchPredictions: predictions,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        errorMessage: 'Failed to search places: ${e.toString()}',
      );
    }
  }

  /// Clear autocomplete suggestions list
  void clearAutocomplete() {
    state = state.copyWith(searchPredictions: []);
  }

  /// Select a destination place prediction from autocomplete suggestions dropdown
  Future<void> selectDestination(PlacePredictionModel prediction) async {
    final destinationCoords = LatLng(prediction.latitude, prediction.longitude);
    state = state.copyWith(
      isSearching: false,
      searchPredictions: [],
      destinationName: prediction.mainText,
      destinationLocation: destinationCoords,
      isRouting: true,
      errorMessage: null,
    );

    try {
      await calculateRoute();
    } catch (e) {
      state = state.copyWith(
        isRouting: false,
        errorMessage: 'Failed to select destination: ${e.toString()}',
      );
    }
  }

  /// Set destination coordinates directly (e.g. from user tapping map canvas)
  Future<void> setDestinationCoordinates(LatLng coordinates, String name) async {
    state = state.copyWith(
      destinationLocation: coordinates,
      destinationName: name,
      isRouting: true,
      errorMessage: null,
    );

    // Run reverse geocoding asynchronously to fetch clean address without blocking
    try {
      calculateRoute();
      final resolvedName = await _geocodingService.reverseGeocode(coordinates);
      state = state.copyWith(destinationName: resolvedName.split(',').first);
    } catch (e) {
      AppLogger.w('Failed to reverse geocode coordinate point: $e');
    }
  }

  /// Build driving routing polylines connecting source and destination
  Future<void> calculateRoute() async {
    if (state.destinationLocation == null) return;
    
    state = state.copyWith(isRouting: true, errorMessage: null);
    try {
      final routeDetails = await _routingService.getDirectionsRoute(
        origin: state.currentLocation,
        destination: state.destinationLocation!,
      );

      state = state.copyWith(
        activeRoute: routeDetails,
        isRouting: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRouting: false,
        errorMessage: 'Failed to draw route: ${e.toString()}',
      );
    }
  }

  /// Discovers hotels, restaurants, bus stops, and stations around current user coordinate center
  Future<void> loadNearbyPlaces(String type) async {
    state = state.copyWith(
      isSearchingNearby: true,
      activeNearbyType: type,
      nearbyPlaces: [],
      errorMessage: null,
    );

    try {
      final places = await _placesService.getNearbyPlaces(
        center: state.currentLocation,
        type: type,
      );
      state = state.copyWith(
        nearbyPlaces: places,
        isSearchingNearby: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSearchingNearby: false,
        errorMessage: 'Failed to load nearby locations: ${e.toString()}',
      );
    }
  }

  /// Remove route details and reset destination pins
  void clearActiveRoute() {
    state = state.copyWith(
      destinationLocation: null,
      destinationName: null,
      activeRoute: RouteDetailsModel.empty(),
    );
  }

  /// Toggle visual map canvas tile configurations
  void toggleMapTheme() {
    state = state.copyWith(isDarkTheme: !state.isDarkTheme);
  }
}

/// Global provider exposing the maps screen interactive states
final mapsStateProvider = StateNotifierProvider<MapsStateNotifier, MapsState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final placesService = ref.watch(placesServiceProvider);
  final routingService = ref.watch(routingServiceProvider);
  final geocodingService = ref.watch(geocodingServiceProvider);

  return MapsStateNotifier(
    locationService: locationService,
    placesService: placesService,
    routingService: routingService,
    geocodingService: geocodingService,
  );
});
