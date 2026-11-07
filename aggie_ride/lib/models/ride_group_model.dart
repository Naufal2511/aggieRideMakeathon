/// Model representing an aggregated cluster of travel intentions & drivers.
class RideGroupModel {
  final String groupId;
  final String destination;
  final String timeWindow;
  final String date;
  final String pickupZone;
  final String category;
  final int interestedCount;
  final int availableDriversCount;
  final int openSeatsCount;
  final String status; // 'CONFIRMED_DRIVERS', 'RECURRING_DRIVERS', 'DEMAND_ONLY'
  final List<String> driverNames;
  final List<String> studentAvatars;
  final String? primaryRideId;

  const RideGroupModel({
    required this.groupId,
    required this.destination,
    required this.timeWindow,
    required this.date,
    required this.pickupZone,
    required this.category,
    this.interestedCount = 0,
    this.availableDriversCount = 0,
    this.openSeatsCount = 0,
    this.status = 'DEMAND_ONLY',
    this.driverNames = const [],
    this.studentAvatars = const [],
    this.primaryRideId,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'destination': destination,
      'timeWindow': timeWindow,
      'date': date,
      'pickupZone': pickupZone,
      'category': category,
      'interestedCount': interestedCount,
      'availableDriversCount': availableDriversCount,
      'openSeatsCount': openSeatsCount,
      'status': status,
      'driverNames': driverNames,
      'studentAvatars': studentAvatars,
      'primaryRideId': primaryRideId,
    };
  }

  factory RideGroupModel.fromMap(Map<String, dynamic> map) {
    return RideGroupModel(
      groupId: map['groupId'] ?? '',
      destination: map['destination'] ?? '',
      timeWindow: map['timeWindow'] ?? '',
      date: map['date'] ?? '',
      pickupZone: map['pickupZone'] ?? '',
      category: map['category'] ?? 'Shopping',
      interestedCount: (map['interestedCount'] as num?)?.toInt() ?? 0,
      availableDriversCount: (map['availableDriversCount'] as num?)?.toInt() ?? 0,
      openSeatsCount: (map['openSeatsCount'] as num?)?.toInt() ?? 0,
      status: map['status'] ?? 'DEMAND_ONLY',
      driverNames: List<String>.from(map['driverNames'] ?? []),
      studentAvatars: List<String>.from(map['studentAvatars'] ?? []),
      primaryRideId: map['primaryRideId'],
    );
  }
}

