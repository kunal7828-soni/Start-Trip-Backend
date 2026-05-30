/// Centralized API endpoint routing catalog.
class ApiEndpoints {
  ApiEndpoints._();

  // Transit & Route Search (External Integration or Cloud Functions)
  static const String searchTrains = '/trains/search';
  static const String trainSchedule = '/trains/schedule';
  static const String searchBuses = '/buses/search';
  static const String bookBusSeat = '/buses/book';

  // Workers / Travel Partners matching
  static const String nearbyWorkers = '/workers/nearby';
  static const String hireWorker = '/workers/hire';

  // Maps / Location Services
  static const String googleDirections = 'https://maps.googleapis.com/maps/api/directions/json';
  static const String googleNearbyPlaces = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  // AI Assistant (Future phase)
  static const String aiTravelPlanner = '/ai/plan';
  static const String aiChat = '/ai/chat';
}
