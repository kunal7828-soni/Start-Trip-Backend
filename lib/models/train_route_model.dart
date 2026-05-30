import 'package:flutter/foundation.dart';

/// Models railway route static scheduling parameters and active stoppages.
@immutable
class TrainRouteModel {
  final String id;
  final String trainNumber;
  final String trainName;
  final String sourceStation;
  final String destinationStation;
  final String departureTime;
  final String arrivalTime;
  final List<Map<String, dynamic>> stops; // Station timelines array
  final String runsOn; // e.g. '1,2,3,4,5'
  final List<String> classes;

  const TrainRouteModel({
    required this.id,
    required this.trainNumber,
    required this.trainName,
    required this.sourceStation,
    required this.destinationStation,
    required this.departureTime,
    required this.arrivalTime,
    required this.stops,
    required this.runsOn,
    required this.classes,
  });

  factory TrainRouteModel.fromMap(Map<String, dynamic> map) {
    return TrainRouteModel(
      id: map['id'] ?? '',
      trainNumber: map['train_number'] ?? '',
      trainName: map['train_name'] ?? '',
      sourceStation: map['source_station'] ?? '',
      destinationStation: map['destination_station'] ?? '',
      departureTime: map['departure_time'] ?? '',
      arrivalTime: map['arrival_time'] ?? '',
      stops: List<Map<String, dynamic>>.from(map['stops'] ?? []),
      runsOn: map['runs_on'] ?? '1,2,3,4,5,6,7',
      classes: List<String>.from(map['classes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'train_number': trainNumber,
      'train_name': trainName,
      'source_station': sourceStation,
      'destination_station': destinationStation,
      'departure_time': departureTime,
      'arrival_time': arrivalTime,
      'stops': stops,
      'runs_on': runsOn,
      'classes': classes,
    };
  }
}
