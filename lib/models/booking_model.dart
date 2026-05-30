import 'package:flutter/foundation.dart';

enum BookingType {
  train,
  bus;

  static BookingType fromString(String type) {
    return BookingType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => BookingType.train,
    );
  }
}

enum BookingStatus {
  pending,
  confirmed,
  cancelled;

  static BookingStatus fromString(String status) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => BookingStatus.pending,
    );
  }
}

/// Consolidated booking model representing purchases for rail and bus trips.
@immutable
class BookingModel {
  final String id;
  final String userId;
  final BookingType bookingType;
  final String routeId; // Maps to train_routes(id) or bus_routes(id)
  final DateTime bookingDate;
  final DateTime travelDate;
  final double farePaid;
  final BookingStatus status;
  final String? seatDetails;
  final String? paymentIntentId;
  final Map<String, dynamic>? metadata;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.bookingType,
    required this.routeId,
    required this.bookingDate,
    required this.travelDate,
    required this.farePaid,
    required this.status,
    this.seatDetails,
    this.paymentIntentId,
    this.metadata,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      bookingType: BookingType.fromString(map['booking_type'] ?? 'train'),
      routeId: map['route_id'] ?? '',
      bookingDate: DateTime.tryParse(map['booking_date'].toString()) ?? DateTime.now(),
      travelDate: DateTime.tryParse(map['travel_date'].toString()) ?? DateTime.now(),
      farePaid: (map['fare_paid'] as num?)?.toDouble() ?? 0.0,
      status: BookingStatus.fromString(map['status'] ?? 'pending'),
      seatDetails: map['seat_details'],
      paymentIntentId: map['payment_intent_id'],
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'booking_type': bookingType.name,
      'route_id': routeId,
      'booking_date': bookingDate.toIso8601String(),
      'travel_date': travelDate.toIso8601String(),
      'fare_paid': farePaid,
      'status': status.name,
      'seat_details': seatDetails,
      'payment_intent_id': paymentIntentId,
      'metadata': metadata,
    };
  }
}
