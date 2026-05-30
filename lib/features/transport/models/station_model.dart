/// Models a railway station or bus terminal.
class StationModel {
  final String id;
  final String name;
  final String code;
  final String city;
  final double? latitude;
  final double? longitude;
  final bool isTrainStation; // True for Train Station, False for Bus Stop

  const StationModel({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
    this.latitude,
    this.longitude,
    this.isTrainStation = true,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      city: json['city'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isTrainStation: json['is_train_station'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'is_train_station': isTrainStation,
    };
  }
}
