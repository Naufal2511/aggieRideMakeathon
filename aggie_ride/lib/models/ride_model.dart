class RideModel {
  final String rideId;
  final String driverId;
  final String origin;
  final String destination;
  final String departureDate;
  final String departureTime;
  final int availableSeats;
  final int totalSeats;
  final int contribution; // in USD (e.g. 0 = Free, 2 = $2)
  final String category; // 'Shopping', 'Campus', 'Groceries', 'Dining', 'Pharmacy'
  final bool isRecurring;
  final List<String> recurringDays;
  final String notes;
  final String pickupSpot;
  final String status; // 'ACTIVE', 'COMPLETED', 'CANCELLED'
  final String createdAt;
  final List<String> passengers; // confirmed passenger IDs
  final String? currentOtp;
  final bool otpVerified;
  final String rideProgress; // 'SCHEDULED', 'IN_PROGRESS', 'COMPLETED'
  final String pickupZone;

  const RideModel({
    required this.rideId,
    required this.driverId,
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.departureTime,
    required this.availableSeats,
    required this.totalSeats,
    required this.contribution,
    required this.category,
    this.isRecurring = false,
    this.recurringDays = const [],
    this.notes = '',
    this.pickupSpot = '',
    this.status = 'ACTIVE',
    required this.createdAt,
    this.passengers = const [],
    this.currentOtp,
    this.otpVerified = false,
    this.rideProgress = 'SCHEDULED',
    this.pickupZone = '',
  });

  bool get isFull => availableSeats <= 0;
  bool get isFree => contribution == 0;

  RideModel copyWith({
    String? rideId,
    String? driverId,
    String? origin,
    String? destination,
    String? departureDate,
    String? departureTime,
    int? availableSeats,
    int? totalSeats,
    int? contribution,
    String? category,
    bool? isRecurring,
    List<String>? recurringDays,
    String? notes,
    String? pickupSpot,
    String? status,
    String? createdAt,
    List<String>? passengers,
  }) {
    return RideModel(
      rideId: rideId ?? this.rideId,
      driverId: driverId ?? this.driverId,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      contribution: contribution ?? this.contribution,
      category: category ?? this.category,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDays: recurringDays ?? this.recurringDays,
      notes: notes ?? this.notes,
      pickupSpot: pickupSpot ?? this.pickupSpot,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      passengers: passengers ?? this.passengers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'driverId': driverId,
      'origin': origin,
      'destination': destination,
      'departureDate': departureDate,
      'departureTime': departureTime,
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'contribution': contribution,
      'category': category,
      'isRecurring': isRecurring,
      'recurringDays': recurringDays,
      'notes': notes,
      'pickupSpot': pickupSpot,
      'status': status,
      'createdAt': createdAt,
      'passengers': passengers,
      'currentOtp': currentOtp,
      'otpVerified': otpVerified,
      'rideProgress': rideProgress,
      'pickupZone': pickupZone,
    };
  }

  factory RideModel.fromMap(Map<String, dynamic> map) {
    return RideModel(
      rideId: map['rideId'] ?? '',
      driverId: map['driverId'] ?? '',
      origin: map['origin'] ?? '',
      destination: map['destination'] ?? '',
      departureDate: map['departureDate'] ?? '',
      departureTime: map['departureTime'] ?? '',
      availableSeats: (map['availableSeats'] as num?)?.toInt() ?? 1,
      totalSeats: (map['totalSeats'] as num?)?.toInt() ?? 1,
      contribution: (map['contribution'] as num?)?.toInt() ?? 0,
      category: map['category'] ?? 'Shopping',
      isRecurring: map['isRecurring'] ?? false,
      recurringDays: List<String>.from(map['recurringDays'] ?? []),
      notes: map['notes'] ?? '',
      pickupSpot: map['pickupSpot'] ?? '',
      status: map['status'] ?? 'ACTIVE',
      createdAt: map['createdAt'] ?? '',
      passengers: List<String>.from(map['passengers'] ?? []),
      currentOtp: map['currentOtp'],
      otpVerified: map['otpVerified'] ?? false,
      rideProgress: map['rideProgress'] ?? 'SCHEDULED',
      pickupZone: map['pickupZone'] ?? '',
    );
  }
}

