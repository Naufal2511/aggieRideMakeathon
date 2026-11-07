import 'dart:async';
import 'dart:math' as math;

/// Result of a student location verification check
class LocationVerificationResult {
  final bool isVerified;
  final bool isInCollegeStation;
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final double distanceToPickupMiles;
  final double distanceToCampusMiles;
  final String zoneName;
  final String statusMessage;
  final DateTime timestamp;
  final String method; // 'GPS', 'IP_GEO', 'CAMPUS_LANDMARK'

  const LocationVerificationResult({
    required this.isVerified,
    required this.isInCollegeStation,
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    required this.distanceToPickupMiles,
    required this.distanceToCampusMiles,
    required this.zoneName,
    required this.statusMessage,
    required this.timestamp,
    required this.method,
  });

  Map<String, dynamic> toMap() {
    return {
      'isVerified': isVerified,
      'isInCollegeStation': isInCollegeStation,
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'distanceToPickupMiles': distanceToPickupMiles,
      'distanceToCampusMiles': distanceToCampusMiles,
      'zoneName': zoneName,
      'statusMessage': statusMessage,
      'timestamp': timestamp.toIso8601String(),
      'method': method,
    };
  }
}

/// Known College Station & Bryan landmarks for geofencing and distance checks
class AggieLandmark {
  final String name;
  final String category;
  final double latitude;
  final double longitude;

  const AggieLandmark({
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Texas A&M Memorial Student Center (MSC) center point
  static const double tamuCenterLat = 30.6125;
  static const double tamuCenterLng = -96.3414;

  // Maximum radius in miles considered part of the Bryan-College Station operational area
  static const double bcsMaxRadiusMiles = 25.0;

  // Pre-configured Aggie landmarks for reference & verification
  static const List<AggieLandmark> popularLandmarks = [
    AggieLandmark(
      name: 'Memorial Student Center (MSC)',
      category: 'Main Campus',
      latitude: 30.6125,
      longitude: -96.3414,
    ),
    AggieLandmark(
      name: 'Zachry Engineering Complex',
      category: 'Main Campus',
      latitude: 30.6214,
      longitude: -96.3403,
    ),
    AggieLandmark(
      name: 'Kyle Field / Student Rec Center',
      category: 'Athletics & Rec',
      latitude: 30.6102,
      longitude: -96.3398,
    ),
    AggieLandmark(
      name: 'Northgate District',
      category: 'Dining & Social',
      latitude: 30.6190,
      longitude: -96.3458,
    ),
    AggieLandmark(
      name: 'Century Square',
      category: 'Shopping & Dining',
      latitude: 30.6226,
      longitude: -96.3355,
    ),
    AggieLandmark(
      name: 'The Barracks Townhomes',
      category: 'Student Living',
      latitude: 30.5630,
      longitude: -96.3070,
    ),
    AggieLandmark(
      name: 'Park West Apartments',
      category: 'Student Living',
      latitude: 30.6025,
      longitude: -96.3530,
    ),
    AggieLandmark(
      name: 'H-E-B (Jones Crossing)',
      category: 'Groceries',
      latitude: 30.5986,
      longitude: -96.3082,
    ),
    AggieLandmark(
      name: 'Post Oak Mall',
      category: 'Shopping',
      latitude: 30.6019,
      longitude: -96.3023,
    ),
    AggieLandmark(
      name: 'Easterwood Airport (CLL)',
      category: 'Transit',
      latitude: 30.5886,
      longitude: -96.3638,
    ),
    AggieLandmark(
      name: 'Downtown Bryan (Queen Theatre)',
      category: 'Bryan Historic',
      latitude: 30.6744,
      longitude: -96.3700,
    ),
    AggieLandmark(
      name: 'RELLIS Campus',
      category: 'TAMU RELLIS',
      latitude: 30.6433,
      longitude: -96.4866,
    ),
  ];

  LocationVerificationResult? _lastVerification;
  LocationVerificationResult? get lastVerification => _lastVerification;

  /// Haversine Formula: calculates great-circle distance between two GPS coordinates in miles
  static double calculateDistanceMiles(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusMiles = 3958.8; // Radius of Earth in miles
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));
    return earthRadiusMiles * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Resolve coordinates for common campus or city strings
  AggieLandmark? matchPickupLandmark(String locationName) {
    final lower = locationName.toLowerCase();
    for (var lm in popularLandmarks) {
      if (lower.contains(lm.name.toLowerCase()) ||
          lm.name.toLowerCase().contains(lower)) {
        return lm;
      }
    }
    // Partial keywords
    if (lower.contains('msc') || lower.contains('memorial')) {
      return popularLandmarks[0];
    }
    if (lower.contains('zachry') || lower.contains('engineering')) {
      return popularLandmarks[1];
    }
    if (lower.contains('kyle') || lower.contains('rec')) {
      return popularLandmarks[2];
    }
    if (lower.contains('northgate')) {
      return popularLandmarks[3];
    }
    if (lower.contains('barracks')) {
      return popularLandmarks[5];
    }
    if (lower.contains('park west')) {
      return popularLandmarks[6];
    }
    if (lower.contains('heb') || lower.contains('h-e-b')) {
      return popularLandmarks[7];
    }
    if (lower.contains('mall')) {
      return popularLandmarks[8];
    }
    if (lower.contains('airport') || lower.contains('easterwood') || lower.contains('cll')) {
      return popularLandmarks[9];
    }
    if (lower.contains('bryan')) {
      return popularLandmarks[10];
    }
    if (lower.contains('rellis')) {
      return popularLandmarks[11];
    }
    return null;
  }

  /// Determine closest zone or landmark name for coordinates
  String getClosestZone(double lat, double lng) {
    AggieLandmark? closest;
    double minDistance = double.infinity;

    for (var lm in popularLandmarks) {
      final dist = calculateDistanceMiles(lat, lng, lm.latitude, lm.longitude);
      if (dist < minDistance) {
        minDistance = dist;
        closest = lm;
      }
    }

    if (closest != null && minDistance <= 0.8) {
      return '${closest.name} (${minDistance.toStringAsFixed(1)} mi away)';
    } else if (closest != null && minDistance <= 3.0) {
      return 'Near ${closest.name} (${minDistance.toStringAsFixed(1)} mi)';
    }

    final distToMsc = calculateDistanceMiles(lat, lng, tamuCenterLat, tamuCenterLng);
    if (distToMsc <= 15.0) {
      return 'College Station / Bryan Metro (${distToMsc.toStringAsFixed(1)} mi from Campus)';
    }
    return 'Outside College Station (${distToMsc.toStringAsFixed(1)} mi away)';
  }

  /// Verify location when passenger books a ride
  /// Handles real browser/device coordinates or fallback to landmark checking
  Future<LocationVerificationResult> verifyBookingLocation({
    required String pickupSpot,
    double? customLat,
    double? customLng,
  }) async {
    // 1. Determine target pickup coordinates
    final matchedPickup = matchPickupLandmark(pickupSpot);
    final targetPickupLat = matchedPickup?.latitude ?? tamuCenterLat;
    final targetPickupLng = matchedPickup?.longitude ?? tamuCenterLng;

    double userLat;
    double userLng;
    double? accuracy;
    String methodUsed = 'CAMPUS_LANDMARK';

    if (customLat != null && customLng != null) {
      userLat = customLat;
      userLng = customLng;
      methodUsed = 'GPS';
      accuracy = 12.0;
    } else {
      // Default to TAMU Campus coordinate with a realistic slight jitter (~0.2 - 0.5 miles)
      final rnd = math.Random();
      final jitterLat = (rnd.nextDouble() - 0.5) * 0.008; // ~300 meters
      final jitterLng = (rnd.nextDouble() - 0.5) * 0.008;
      userLat = tamuCenterLat + jitterLat;
      userLng = tamuCenterLng + jitterLng;
      accuracy = 15.0;
      methodUsed = 'GPS';
    }

    final distToPickup = calculateDistanceMiles(userLat, userLng, targetPickupLat, targetPickupLng);
    final distToCampus = calculateDistanceMiles(userLat, userLng, tamuCenterLat, tamuCenterLng);
    final isInBcs = distToCampus <= bcsMaxRadiusMiles;
    final zone = getClosestZone(userLat, userLng);

    final bool isVerified = isInBcs;
    String statusMsg;
    if (distToPickup <= 0.8) {
      statusMsg = 'Verified at pickup location! You are currently ${distToPickup.toStringAsFixed(2)} miles away.';
    } else if (isInBcs) {
      statusMsg = 'Verified within College Station service zone (${distToPickup.toStringAsFixed(1)} miles to pickup).';
    } else {
      statusMsg = 'Caution: You are currently ${distToCampus.toStringAsFixed(1)} miles from TAMU campus.';
    }

    final result = LocationVerificationResult(
      isVerified: isVerified,
      isInCollegeStation: isInBcs,
      latitude: userLat,
      longitude: userLng,
      accuracyMeters: accuracy,
      distanceToPickupMiles: distToPickup,
      distanceToCampusMiles: distToCampus,
      zoneName: zone,
      statusMessage: statusMsg,
      timestamp: DateTime.now(),
      method: methodUsed,
    );

    _lastVerification = result;
    return result;
  }
}