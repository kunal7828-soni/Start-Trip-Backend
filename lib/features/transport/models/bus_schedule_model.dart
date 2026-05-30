/// Models pickup or drop points along a bus route.
class BusBoardingPoint {
  final String location;
  final String time;
  final double? latitude;
  final double? longitude;

  const BusBoardingPoint({
    required this.location,
    required this.time,
    this.latitude,
    this.longitude,
  });

  factory BusBoardingPoint.fromJson(Map<String, dynamic> json) {
    return BusBoardingPoint(
      location: json['location'] ?? '',
      time: json['time'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'time': time,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Models interactive seat parameters.
class BusSeat {
  final String label;
  final int row;
  final int col;
  final bool isBooked;
  final bool isSleeper; // true if sleeper berth, false if normal seater

  const BusSeat({
    required this.label,
    required this.row,
    required this.col,
    this.isBooked = false,
    this.isSleeper = false,
  });

  factory BusSeat.fromJson(Map<String, dynamic> json) {
    return BusSeat(
      label: json['label'] ?? '',
      row: json['row'] ?? 0,
      col: json['col'] ?? 0,
      isBooked: json['is_booked'] ?? false,
      isSleeper: json['is_sleeper'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'row': row,
      'col': col,
      'is_booked': isBooked,
      'is_sleeper': isSleeper,
    };
  }
}

/// Models bus operators schedules, pickup drop boards, and grid configurations.
class BusScheduleModel {
  final String id;
  final String operatorName;
  final String busType;
  final String sourceStopCode;
  final String destStopCode;
  final String departureTime;
  final String arrivalTime;
  final int durationMinutes;
  final double fareAmount;
  final List<BusBoardingPoint> pickupPoints;
  final List<BusBoardingPoint> dropPoints;
  final List<BusSeat> seats;

  const BusScheduleModel({
    required this.id,
    required this.operatorName,
    required this.busType,
    required this.sourceStopCode,
    required this.destStopCode,
    required this.departureTime,
    required this.arrivalTime,
    required this.durationMinutes,
    required this.fareAmount,
    required this.pickupPoints,
    required this.dropPoints,
    required this.seats,
  });

  factory BusScheduleModel.fromJson(Map<String, dynamic> json) {
    final rawPickups = json['pickup_points'] as List? ?? [];
    final rawDrops = json['drop_points'] as List? ?? [];
    final rawSeats = json['seats'] as List? ?? [];

    return BusScheduleModel(
      id: json['id'] ?? '',
      operatorName: json['operator_name'] ?? '',
      busType: json['bus_type'] ?? '',
      sourceStopCode: json['source_stop_code'] ?? '',
      destStopCode: json['dest_stop_code'] ?? '',
      departureTime: json['departure_time'] ?? '',
      arrivalTime: json['arrival_time'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      fareAmount: (json['fare_amount'] as num?)?.toDouble() ?? 0.0,
      pickupPoints: rawPickups.map((p) => BusBoardingPoint.fromJson(p)).toList(),
      dropPoints: rawDrops.map((d) => BusBoardingPoint.fromJson(d)).toList(),
      seats: rawSeats.map((s) => BusSeat.fromJson(s)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operator_name': operatorName,
      'bus_type': busType,
      'source_stop_code': sourceStopCode,
      'dest_stop_code': destStopCode,
      'departure_time': departureTime,
      'arrival_time': arrivalTime,
      'duration_minutes': durationMinutes,
      'fare_amount': fareAmount,
      'pickup_points': pickupPoints.map((p) => p.toJson()).toList(),
      'drop_points': dropPoints.map((d) => d.toJson()).toList(),
      'seats': seats.map((s) => s.toJson()).toList(),
    };
  }

  /// Helper computing duration display string.
  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    return '${hours}h ${mins}m';
  }
}
