/// Models traveler lookup query parameters for both trains and buses.
class TransportQuery {
  final String sourceName;
  final String sourceCode;
  final String destName;
  final String destCode;
  final DateTime travelDate;
  final String transportType; // 'all', 'train', 'bus'

  const TransportQuery({
    required this.sourceName,
    required this.sourceCode,
    required this.destName,
    required this.destCode,
    required this.travelDate,
    this.transportType = 'all',
  });

  TransportQuery copyWith({
    String? sourceName,
    String? sourceCode,
    String? destName,
    String? destCode,
    DateTime? travelDate,
    String? transportType,
  }) {
    return TransportQuery(
      sourceName: sourceName ?? this.sourceName,
      sourceCode: sourceCode ?? this.sourceCode,
      destName: destName ?? this.destName,
      destCode: destCode ?? this.destCode,
      travelDate: travelDate ?? this.travelDate,
      transportType: transportType ?? this.transportType,
    );
  }

  /// Check if the query contains valid search values.
  bool get isValid => sourceCode.isNotEmpty && destCode.isNotEmpty && sourceCode != destCode;
}
