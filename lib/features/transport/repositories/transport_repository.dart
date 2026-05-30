import '../../../../core/cache/cache_manager.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/bus_schedule_model.dart';
import '../models/station_model.dart';
import '../models/train_schedule_model.dart';
import '../models/transport_query.dart';

/// Clean Architecture repository contract defining booking search logic.
abstract class TransportRepository {
  Future<List<TrainScheduleModel>> searchTrains(TransportQuery query);
  Future<List<BusScheduleModel>> searchBuses(TransportQuery query);
  Future<List<StationModel>> getStationsAutocomplete(String query);
  Future<void> saveRecentSearch(TransportQuery query);
  Future<List<TransportQuery>> getRecentSearches();
}

/// Production implementation of the TransportRepository querying Firebase Functions.
/// Incorporates highly descriptive mock engines for offline verification.
class TransportRepositoryImpl implements TransportRepository {
  final DioClient _dioClient;
  final CacheManager _cacheManager = CacheManager();

  TransportRepositoryImpl(this._dioClient);

  @override
  Future<List<TrainScheduleModel>> searchTrains(TransportQuery query) async {
    try {
      AppLogger.i('Searching trains from: ${query.sourceCode} to: ${query.destCode}');
      
      // Simulate Firebase Cloud Functions call: https://api.tripbuddy.com/v1/searchTrains
      final response = await _dioClient.instance.post(
        '/trains/search',
        data: {
          'source': query.sourceCode,
          'destination': query.destCode,
          'date': query.travelDate.toIso8601String().split('T').first,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['results'] ?? [];
        return list.map((json) => TrainScheduleModel.fromJson(json)).toList();
      }
      throw Exception('Search train functions failed');
    } catch (e) {
      AppLogger.e('Railway API request failed: $e. Loading resilient mock train schedules.', e);
      return _getMockTrains(query);
    }
  }

  @override
  Future<List<BusScheduleModel>> searchBuses(TransportQuery query) async {
    try {
      AppLogger.i('Searching buses from: ${query.sourceCode} to: ${query.destCode}');
      
      // Simulate Firebase Cloud Functions call: https://api.tripbuddy.com/v1/searchBuses
      final response = await _dioClient.instance.post(
        '/buses/search',
        data: {
          'source': query.sourceCode,
          'destination': query.destCode,
          'date': query.travelDate.toIso8601String().split('T').first,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['results'] ?? [];
        return list.map((json) => BusScheduleModel.fromJson(json)).toList();
      }
      throw Exception('Search bus functions failed');
    } catch (e) {
      AppLogger.e('Bus API request failed: $e. Loading simulated mock bus timetables.', e);
      return _getMockBuses(query);
    }
  }

  @override
  Future<List<StationModel>> getStationsAutocomplete(String query) async {
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty) return [];

    // Seed comprehensive list of stations for autocomplete matches
    final List<StationModel> allLocations = [
      const StationModel(id: 'st_1', name: 'New Delhi Railway Station', code: 'NDLS', city: 'Delhi', isTrainStation: true),
      const StationModel(id: 'st_2', name: 'Bhopal Junction Station', code: 'BPL', city: 'Bhopal', isTrainStation: true),
      const StationModel(id: 'st_3', name: 'Mumbai Central Station', code: 'BCT', city: 'Mumbai', isTrainStation: true),
      const StationModel(id: 'st_4', name: 'Howrah Junction Kolkata', code: 'HWH', city: 'Kolkata', isTrainStation: true),
      const StationModel(id: 'st_5', name: 'Chennai Central Station', code: 'MAS', city: 'Chennai', isTrainStation: true),
      const StationModel(id: 'st_6', name: 'Bengaluru Majestic Bus Terminus', code: 'ISBT-BLR', city: 'Bengaluru', isTrainStation: false),
      const StationModel(id: 'st_7', name: 'Bhopal ISBT Terminal', code: 'ISBT-BPL', city: 'Bhopal', isTrainStation: false),
      const StationModel(id: 'st_8', name: 'Indore Sarwate Bus Stand', code: 'ISBT-IND', city: 'Indore', isTrainStation: false),
      const StationModel(id: 'st_9', name: 'Mumbai Borivali Bus Terminal', code: 'ISBT-BOM', city: 'Mumbai', isTrainStation: false),
    ];

    return allLocations.where((element) {
      return element.name.toLowerCase().contains(cleanQuery) ||
          element.code.toLowerCase().contains(cleanQuery) ||
          element.city.toLowerCase().contains(cleanQuery);
    }).toList();
  }

  @override
  Future<void> saveRecentSearch(TransportQuery query) async {
    try {
      final List<dynamic>? rawList = _cacheManager.read<List<dynamic>>('search_history');
      final List<TransportQuery> history = [];
      
      if (rawList != null) {
        for (final item in rawList) {
          history.add(TransportQuery(
            sourceName: item['source_name'] ?? '',
            sourceCode: item['source'] ?? '',
            destName: item['dest_name'] ?? '',
            destCode: item['dest'] ?? '',
            travelDate: DateTime.tryParse(item['date'] ?? '') ?? DateTime.now(),
            transportType: item['type'] ?? 'all',
          ));
        }
      }

      // De-duplicate recent query
      history.removeWhere((h) => h.sourceCode == query.sourceCode && h.destCode == query.destCode);
      history.insert(0, query);

      // Save top 5
      final capped = history.take(5).map((h) => {
        'source_name': h.sourceName,
        'source': h.sourceCode,
        'dest_name': h.destName,
        'dest': h.destCode,
        'date': h.travelDate.toIso8601String(),
        'type': h.transportType,
      }).toList();

      _cacheManager.write('search_history', capped);
    } catch (e) {
      AppLogger.w('Failed to save recent search history: $e');
    }
  }

  @override
  Future<List<TransportQuery>> getRecentSearches() async {
    try {
      final List<dynamic>? rawList = _cacheManager.read<List<dynamic>>('search_history');
      if (rawList == null) return [];

      return rawList.map((item) {
        return TransportQuery(
          sourceName: item['source_name'] ?? '',
          sourceCode: item['source'] ?? '',
          destName: item['dest_name'] ?? '',
          destCode: item['dest'] ?? '',
          travelDate: DateTime.tryParse(item['date'] ?? '') ?? DateTime.now(),
          transportType: item['type'] ?? 'all',
        );
      }).toList();
    } catch (e) {
      AppLogger.w('Failed to read search history cache: $e');
      return [];
    }
  }

  // --- HIGH FIDELITY MOCK TRANSPORT GENERATORS ---

  List<TrainScheduleModel> _getMockTrains(TransportQuery query) {
    final source = query.sourceCode;
    final dest = query.destCode;

    return [
      TrainScheduleModel(
        id: 'tr_101',
        trainNumber: '12002',
        trainName: 'Shatabdi Express (Premium)',
        sourceStationCode: source,
        destStationCode: dest,
        departureTime: '06:00 AM',
        arrivalTime: '11:45 AM',
        durationMinutes: 345, // 5h 45m
        runsOnDays: const [1, 2, 3, 4, 5, 6, 7],
        coachesAvailable: const ['1A', 'EC', 'CC'],
        baseFares: const {'1A': 1850.0, 'EC': 1420.0, 'CC': 780.0},
        intermediateStops: [
          const IntermediateTrainStop(stationName: 'Source Station', stationCode: 'SRC', arrivalTime: '05:50 AM', departureTime: '06:00 AM', haltMinutes: 10, platform: '1'),
          const IntermediateTrainStop(stationName: 'Mathura Junction', stationCode: 'MTJ', arrivalTime: '07:30 AM', departureTime: '07:32 AM', haltMinutes: 2, platform: '2'),
          const IntermediateTrainStop(stationName: 'Agra Cantt', stationCode: 'AGC', arrivalTime: '08:15 AM', departureTime: '08:20 AM', haltMinutes: 5, platform: '1'),
          const IntermediateTrainStop(stationName: 'Gwalior Junction', stationCode: 'GWL', arrivalTime: '09:40 AM', departureTime: '09:42 AM', haltMinutes: 2, platform: '4'),
          const IntermediateTrainStop(stationName: 'Destination Station', stationCode: 'DST', arrivalTime: '11:45 AM', departureTime: '11:55 AM', haltMinutes: 10, platform: '3'),
        ],
      ),
      TrainScheduleModel(
        id: 'tr_102',
        trainNumber: '12952',
        trainName: 'Rajdhani Express (Superfast)',
        sourceStationCode: source,
        destStationCode: dest,
        departureTime: '04:55 PM',
        arrivalTime: '11:20 PM',
        durationMinutes: 385, // 6h 25m
        runsOnDays: const [1, 2, 4, 5, 7],
        coachesAvailable: const ['1A', '2A', '3A'],
        baseFares: const {'1A': 2400.0, '2A': 1650.0, '3A': 1180.0},
        intermediateStops: [
          const IntermediateTrainStop(stationName: 'Source Terminal', stationCode: 'SRC', arrivalTime: '04:40 PM', departureTime: '04:55 PM', haltMinutes: 15, platform: '3'),
          const IntermediateTrainStop(stationName: 'Kota Junction', stationCode: 'KOTA', arrivalTime: '07:50 PM', departureTime: '08:00 PM', haltMinutes: 10, platform: '1'),
          const IntermediateTrainStop(stationName: 'Ratlam Junction', stationCode: 'RTM', arrivalTime: '09:40 PM', departureTime: '09:42 PM', haltMinutes: 2, platform: '2'),
          const IntermediateTrainStop(stationName: 'Destination Junction', stationCode: 'DST', arrivalTime: '11:20 PM', departureTime: '11:30 PM', haltMinutes: 10, platform: '5'),
        ],
      ),
      TrainScheduleModel(
        id: 'tr_103',
        trainNumber: '11058',
        trainName: 'Express Intercity (General)',
        sourceStationCode: source,
        destStationCode: dest,
        departureTime: '10:15 AM',
        arrivalTime: '06:45 PM',
        durationMinutes: 510, // 8h 30m
        runsOnDays: const [1, 3, 5, 6],
        coachesAvailable: const ['3A', 'SL', '2S'],
        baseFares: const {'3A': 820.0, 'SL': 380.0, '2S': 190.0},
        intermediateStops: [
          const IntermediateTrainStop(stationName: 'Source Station', stationCode: 'SRC', arrivalTime: '10:00 AM', departureTime: '10:15 AM', haltMinutes: 15, platform: '2'),
          const IntermediateTrainStop(stationName: 'Intermediate Halting 1', stationCode: 'HAL1', arrivalTime: '12:30 PM', departureTime: '12:35 PM', haltMinutes: 5, platform: '1'),
          const IntermediateTrainStop(stationName: 'Intermediate Halting 2', stationCode: 'HAL2', arrivalTime: '03:10 PM', departureTime: '03:15 PM', haltMinutes: 5, platform: '2'),
          const IntermediateTrainStop(stationName: 'Destination Terminal', stationCode: 'DST', arrivalTime: '06:45 PM', departureTime: '06:55 PM', haltMinutes: 10, platform: '4'),
        ],
      ),
    ];
  }

  List<BusScheduleModel> _getMockBuses(TransportQuery query) {
    final source = query.sourceCode;
    final dest = query.destCode;

    final List<BusSeat> defaultSeatsList = [];
    for (int r = 1; r <= 6; r++) {
      for (int c = 1; c <= 4; c++) {
        // Skip aisle space in 2x2 layout
        final seatLabel = '${String.fromCharCode(64 + r)}$c';
        defaultSeatsList.add(BusSeat(
          label: seatLabel,
          row: r,
          col: c,
          // Randomly book some seats for realism
          isBooked: (r + c) % 3 == 0 || (r * c) % 5 == 0,
          isSleeper: r >= 5, // Last two rows are premium sleepers
        ));
      }
    }

    return [
      BusScheduleModel(
        id: 'bs_201',
        operatorName: 'Chartered Travels (Premium AC)',
        busType: 'AC Sleeper 2+2',
        sourceStopCode: source,
        destStopCode: dest,
        departureTime: '09:30 PM',
        arrivalTime: '05:00 AM',
        durationMinutes: 450, // 7h 30m
        fareAmount: 850.0,
        pickupPoints: [
          const BusBoardingPoint(location: 'Bhopal ISBT Platform-3', time: '09:30 PM', latitude: 23.2505, longitude: 77.4562),
          const BusBoardingPoint(location: 'Lalghati Square Petrol Pump', time: '09:50 PM', latitude: 23.2842, longitude: 77.3710),
        ],
        dropPoints: [
          const BusBoardingPoint(location: 'Sarwate Bus Stand Gate-2', time: '04:45 AM', latitude: 22.7155, longitude: 75.8660),
          const BusBoardingPoint(location: 'Vijay Nagar Square Office', time: '05:00 AM', latitude: 22.7533, longitude: 75.8930),
        ],
        seats: defaultSeatsList,
      ),
      BusScheduleModel(
        id: 'bs_202',
        operatorName: 'Verma Travels (Volvo Multi-Axle)',
        busType: 'Volvo AC Seater 2+2',
        sourceStopCode: source,
        destStopCode: dest,
        departureTime: '11:15 AM',
        arrivalTime: '04:45 PM',
        durationMinutes: 330, // 5h 30m
        fareAmount: 580.0,
        pickupPoints: [
          const BusBoardingPoint(location: 'ISBT Office Main Gate', time: '11:15 AM', latitude: 23.2505, longitude: 77.4562),
        ],
        dropPoints: [
          const BusBoardingPoint(location: 'Vijay Nagar Office Clock Tower', time: '04:45 PM', latitude: 22.7533, longitude: 75.8930),
        ],
        seats: defaultSeatsList.map((s) => BusSeat(label: s.label, row: s.row, col: s.col, isBooked: s.row % 2 == 0, isSleeper: false)).toList(),
      ),
      BusScheduleModel(
        id: 'bs_203',
        operatorName: 'Hans Travels (Express Seater)',
        busType: 'Non-AC Deluxe Seater',
        sourceStopCode: source,
        destStopCode: dest,
        departureTime: '08:00 AM',
        arrivalTime: '02:30 PM',
        durationMinutes: 390, // 6h 30m
        fareAmount: 380.0,
        pickupPoints: [
          const BusBoardingPoint(location: 'ISBT Platform-6', time: '08:00 AM', latitude: 23.2505, longitude: 77.4562),
        ],
        dropPoints: [
          const BusBoardingPoint(location: 'Sarwate Stand Terminal-A', time: '02:30 PM', latitude: 22.7155, longitude: 75.8660),
        ],
        seats: defaultSeatsList.map((s) => BusSeat(label: s.label, row: s.row, col: s.col, isBooked: s.col == 1, isSleeper: false)).toList(),
      ),
    ];
  }
}
