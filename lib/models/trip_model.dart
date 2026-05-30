import 'package:flutter/foundation.dart';

enum TripStatus {
  planning,
  upcoming,
  ongoing,
  completed,
  cancelled;

  static TripStatus fromString(String status) {
    return TripStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => TripStatus.planning,
    );
  }
}

/// Comprehensive model mapping the Supabase trips schema.
@immutable
class TripModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final TripStatus status;

  const TripModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.budget = 0.0,
    required this.status,
  });

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      startDate: DateTime.tryParse(map['start_date'].toString()) ?? DateTime.now(),
      endDate: DateTime.tryParse(map['end_date'].toString()) ?? DateTime.now(),
      budget: (map['budget'] as num?)?.toDouble() ?? 0.0,
      status: TripStatus.fromString(map['status'] ?? 'planning'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'budget': budget,
      'status': status.name,
    };
  }
}
