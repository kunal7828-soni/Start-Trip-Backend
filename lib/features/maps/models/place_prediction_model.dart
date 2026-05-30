/// Models OpenStreetMap Nominatim Search suggestions items.
class PlacePredictionModel {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String fullDescription;
  final double latitude;
  final double longitude;

  const PlacePredictionModel({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullDescription,
    required this.latitude,
    required this.longitude,
  });

  factory PlacePredictionModel.fromJson(Map<String, dynamic> json) {
    return PlacePredictionModel(
      placeId: json['place_id']?.toString() ?? json['osm_id']?.toString() ?? '',
      mainText: json['name'] ?? json['display_name']?.split(',').first ?? 'Location',
      secondaryText: json['display_name']?.split(',').skip(1).join(',').trim() ?? '',
      fullDescription: json['display_name'] ?? '',
      latitude: double.tryParse(json['lat']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json['lon']?.toString() ?? '') ?? 0.0,
    );
  }
}
