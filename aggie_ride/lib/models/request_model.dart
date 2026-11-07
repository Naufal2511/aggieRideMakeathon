class RequestModel {
  final String requestId;
  final String rideId;
  final String passengerId;
  final String driverId;
  final int seatsRequested;
  final String status; // 'PENDING', 'ACCEPTED', 'REJECTED', 'CANCELLED'
  final String message;
  final String requestedAt;
  final String? updatedAt;
  final bool isLocationVerified;
  final String? passengerLocationZone;
  final double? distanceToPickupMiles;
  final double? latitude;
  final double? longitude;
  final String? otp;

  const RequestModel({
    required this.requestId,
    required this.rideId,
    required this.passengerId,
    required this.driverId,
    this.seatsRequested = 1,
    this.status = 'PENDING',
    this.message = '',
    required this.requestedAt,
    this.updatedAt,
    this.isLocationVerified = false,
    this.passengerLocationZone,
    this.distanceToPickupMiles,
    this.latitude,
    this.longitude,
    this.otp,
  });

  RequestModel copyWith({
    String? requestId,
    String? rideId,
    String? passengerId,
    String? driverId,
    int? seatsRequested,
    String? status,
    String? message,
    String? requestedAt,
    String? updatedAt,
    bool? isLocationVerified,
    String? passengerLocationZone,
    double? distanceToPickupMiles,
    double? latitude,
    double? longitude,
  }) {
    return RequestModel(
      requestId: requestId ?? this.requestId,
      rideId: rideId ?? this.rideId,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      seatsRequested: seatsRequested ?? this.seatsRequested,
      status: status ?? this.status,
      message: message ?? this.message,
      requestedAt: requestedAt ?? this.requestedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLocationVerified: isLocationVerified ?? this.isLocationVerified,
      passengerLocationZone: passengerLocationZone ?? this.passengerLocationZone,
      distanceToPickupMiles: distanceToPickupMiles ?? this.distanceToPickupMiles,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'rideId': rideId,
      'passengerId': passengerId,
      'driverId': driverId,
      'seatsRequested': seatsRequested,
      'status': status,
      'message': message,
      'requestedAt': requestedAt,
      'updatedAt': updatedAt,
      'isLocationVerified': isLocationVerified,
      'passengerLocationZone': passengerLocationZone,
      'distanceToPickupMiles': distanceToPickupMiles,
      'latitude': latitude,
      'longitude': longitude,
      'otp': otp,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      requestId: map['requestId'] ?? '',
      rideId: map['rideId'] ?? '',
      passengerId: map['passengerId'] ?? '',
      driverId: map['driverId'] ?? '',
      seatsRequested: (map['seatsRequested'] as num?)?.toInt() ?? 1,
      status: map['status'] ?? 'PENDING',
      message: map['message'] ?? '',
      requestedAt: map['requestedAt'] ?? '',
      updatedAt: map['updatedAt'],
      isLocationVerified: map['isLocationVerified'] ?? false,
      passengerLocationZone: map['passengerLocationZone'],
      distanceToPickupMiles: (map['distanceToPickupMiles'] as num?)?.toDouble(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      otp: map['otp'],
    );
  }
}
