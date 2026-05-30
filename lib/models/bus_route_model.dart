import 'package:flutter/foundation.dart';

/// Models bus line operators, seat counts, and pricing profiles.
@immutable
class BusRouteModel {
  final String id;
  final String busOperator;
  final String busType; // e.g. AC, Sleeper, Deluxe
  final String source;
  final String destination;
  final String departureTime;
  final String arrivalTime;
  final double fare;
  final int seatsAvailable;

  const BusRouteModel({
    required this.id,
    required this.busOperator,
    required this.busType,
    required this.source,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.fare,
    required this.seatsAvailable,
  });

  factory BusRouteModel.fromMap(Map<String, dynamic> map) {
    return BusRouteModel(
      id: map['id'] ?? '',
      busOperator: map['bus_operator'] ?? '',
      busType: map['bus_type'] ?? '',
      source: map['source'] ?? '',
      destination: map['destination'] ?? '',
      departureTime: map['departure_time'] ?? '',
      arrivalTime: map['arrival_time'] ?? '',
      fare: (map['fare'] as num?)?.toDouble() ?? 0.0,
      seatsAvailable: (map['seats_available'] as num?)?.toInt() ?? 40,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bus_operator': busOperator,
      'bus_type': busType,
      'source': source,
      'destination': destination,
      'departure_time': departureTime,
      'arrival_time': arrivalTime,
      'fare': fare,
      'seats_available': seatsAvailable,
    };
  }
}
