import 'package:flutter/foundation.dart';

/// Models custom location bookmarkings saved under user profiles.
@immutable
class SavedPlaceModel {
  final String id;
  final String userId;
  final String placeId; // Maps to Google Places API Place ID
  final String placeName;
  final String? formattedAddress;
  final double latitude;
  final double longitude;
  final String? category; // e.g. 'hotel', 'restaurant', 'attraction'

  const SavedPlaceModel({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.placeName,
    this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.category,
  });

  factory SavedPlaceModel.fromMap(Map<String, dynamic> map) {
    return SavedPlaceModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      placeId: map['place_id'] ?? '',
      placeName: map['place_name'] ?? '',
      formattedAddress: map['formatted_address'],
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'place_id': placeId,
      'place_name': placeName,
      'formatted_address': formattedAddress,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
    };
  }
}
