/// Models detailed stop timeline inside train route connections.
class IntermediateTrainStop {
  final String stationName;
  final String stationCode;
  final String arrivalTime;
  final String departureTime;
  final int haltMinutes;
  final String platform;

  const IntermediateTrainStop({
    required this.stationName,
    required this.stationCode,
    required this.arrivalTime,
    required this.departureTime,
    required this.haltMinutes,
    required this.platform,
  });

  factory IntermediateTrainStop.fromJson(Map<String, dynamic> json) {
    return IntermediateTrainStop(
      stationName: json['station_name'] ?? '',
      stationCode: json['station_code'] ?? '',
      arrivalTime: json['arrival_time'] ?? '',
      departureTime: json['departure_time'] ?? '',
      haltMinutes: json['halt_minutes'] ?? 0,
      platform: json['platform'] ?? '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'station_name': stationName,
      'station_code': stationCode,
      'arrival_time': arrivalTime,
      'departure_time': departureTime,
      'halt_minutes': haltMinutes,
      'platform': platform,
    };
  }
}

/// Models train schedules, platform details, coach availabilities, and base fares cache.
class TrainScheduleModel {
  final String id;
  final String trainNumber;
  final String trainName;
  final String sourceStationCode;
  final String destStationCode;
  final String departureTime;
  final String arrivalTime;
  final int durationMinutes;
  final List<int> runsOnDays; // Days of week e.g. [1, 2, 3, 4, 5, 6, 7]
  final List<String> coachesAvailable; // ['1A', '2A', '3A', 'SL']
  final Map<String, double> baseFares; // {'1A': 2100.0, '3A': 950.0}
  final List<IntermediateTrainStop> intermediateStops;

  const TrainScheduleModel({
    required this.id,
    required this.trainNumber,
    required this.trainName,
    required this.sourceStationCode,
    required this.destStationCode,
    required this.departureTime,
    required this.arrivalTime,
    required this.durationMinutes,
    required this.runsOnDays,
    required this.coachesAvailable,
    required this.baseFares,
    required this.intermediateStops,
  });

  factory TrainScheduleModel.fromJson(Map<String, dynamic> json) {
    final fareMap = <String, double>{};
    final rawFares = json['base_fares'] as Map? ?? {};
    rawFares.forEach((key, val) {
      fareMap[key.toString()] = (val as num).toDouble();
    });

    final rawStops = json['intermediate_stops'] as List? ?? [];

    return TrainScheduleModel(
      id: json['id'] ?? '',
      trainNumber: json['train_number'] ?? '',
      trainName: json['train_name'] ?? '',
      sourceStationCode: json['source_station_code'] ?? '',
      destStationCode: json['dest_station_code'] ?? '',
      departureTime: json['departure_time'] ?? '',
      arrivalTime: json['arrival_time'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      runsOnDays: List<int>.from(json['runs_on_days'] ?? []),
      coachesAvailable: List<String>.from(json['coaches_available'] ?? []),
      baseFares: fareMap,
      intermediateStops: rawStops.map((s) => IntermediateTrainStop.fromJson(s)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'train_number': trainNumber,
      'train_name': trainName,
      'source_station_code': sourceStationCode,
      'dest_station_code': destStationCode,
      'departure_time': departureTime,
      'arrival_time': arrivalTime,
      'duration_minutes': durationMinutes,
      'runs_on_days': runsOnDays,
      'coaches_available': coachesAvailable,
      'base_fares': baseFares,
      'intermediate_stops': intermediateStops.map((s) => s.toJson()).toList(),
    };
  }

  /// Helper computing duration display string.
  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    return '${hours}h ${mins}m';
  }
}
