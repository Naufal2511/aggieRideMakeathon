/// Model representing a student's expressed travel intention for demand-aware mobility.
/// "Where Aggies go, Aggies ride."
class TravelIntentionModel {
  final String intentionId;
  final String userId;
  final String destination;
  final String preferredDate;
  final String alternativeDate;
  final String earliestDeparture;
  final String latestDeparture;
  final String pickupLocation;
  final int maxWalkingDistanceMin;
  final int maxTransfers;
  final String notes;
  final String status; // 'PENDING_MATCH', 'MATCHED', 'FULFILLED', 'EXPIRED'
  final String? matchedGroupId;
  final String createdAt;

  const TravelIntentionModel({
    required this.intentionId,
    required this.userId,
    required this.destination,
    required this.preferredDate,
    this.alternativeDate = '',
    required this.earliestDeparture,
    required this.latestDeparture,
    required this.pickupLocation,
    this.maxWalkingDistanceMin = 10,
    this.maxTransfers = 1,
    this.notes = '',
    this.status = 'PENDING_MATCH',
    this.matchedGroupId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'intentionId': intentionId,
      'userId': userId,
      'destination': destination,
      'preferredDate': preferredDate,
      'alternativeDate': alternativeDate,
      'earliestDeparture': earliestDeparture,
      'latestDeparture': latestDeparture,
      'pickupLocation': pickupLocation,
      'maxWalkingDistanceMin': maxWalkingDistanceMin,
      'maxTransfers': maxTransfers,
      'notes': notes,
      'status': status,
      'matchedGroupId': matchedGroupId,
      'createdAt': createdAt,
    };
  }

  factory TravelIntentionModel.fromMap(Map<String, dynamic> map) {
    return TravelIntentionModel(
      intentionId: map['intentionId'] ?? '',
      userId: map['userId'] ?? '',
      destination: map['destination'] ?? '',
      preferredDate: map['preferredDate'] ?? '',
      alternativeDate: map['alternativeDate'] ?? '',
      earliestDeparture: map['earliestDeparture'] ?? '',
      latestDeparture: map['latestDeparture'] ?? '',
      pickupLocation: map['pickupLocation'] ?? '',
      maxWalkingDistanceMin: (map['maxWalkingDistanceMin'] as num?)?.toInt() ?? 10,
      maxTransfers: (map['maxTransfers'] as num?)?.toInt() ?? 1,
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'PENDING_MATCH',
      matchedGroupId: map['matchedGroupId'],
      createdAt: map['createdAt'] ?? '',
    );
  }
}

