class UserModel {
  final String userId;
  final String name;
  final String email;
  final String classYear;
  final String major;
  final bool isTamuVerified;
  final String avatar;
  final String bio;
  final String? carModel;
  final int ridesOffered;
  final int ridesJoined;
  final double rating;
  final int reviewsCount;
  final String onTimeRate;
  final String joinedDate;
  final String? fcmToken;
  final bool isDriverVerified;
  final String driverStatus; // 'UNVERIFIED', 'PENDING', 'VERIFIED_DEMO'
  final int rewardPoints; // Aggie Gas Points
  final String preferredPickupArea;
  final bool hasGeminiSticker;
  final String userType; // 'find', 'offer', 'both'

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.classYear,
    required this.major,
    required this.isTamuVerified,
    required this.avatar,
    required this.bio,
    this.carModel,
    this.ridesOffered = 0,
    this.ridesJoined = 0,
    this.rating = 5.0,
    this.reviewsCount = 0,
    this.onTimeRate = '100%',
    this.joinedDate = 'Fall 2024',
    this.fcmToken,
    this.isDriverVerified = false,
    this.driverStatus = 'UNVERIFIED',
    this.rewardPoints = 0,
    this.preferredPickupArea = 'College Station',
    this.hasGeminiSticker = false,
    this.userType = 'both',
  });

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? classYear,
    String? major,
    bool? isTamuVerified,
    String? avatar,
    String? bio,
    String? carModel,
    int? ridesOffered,
    int? ridesJoined,
    double? rating,
    int? reviewsCount,
    String? onTimeRate,
    String? joinedDate,
    String? fcmToken,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      classYear: classYear ?? this.classYear,
      major: major ?? this.major,
      isTamuVerified: isTamuVerified ?? this.isTamuVerified,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      carModel: carModel ?? this.carModel,
      ridesOffered: ridesOffered ?? this.ridesOffered,
      ridesJoined: ridesJoined ?? this.ridesJoined,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      onTimeRate: onTimeRate ?? this.onTimeRate,
      joinedDate: joinedDate ?? this.joinedDate,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'classYear': classYear,
      'major': major,
      'isTamuVerified': isTamuVerified,
      'avatar': avatar,
      'bio': bio,
      'carModel': carModel,
      'ridesOffered': ridesOffered,
      'ridesJoined': ridesJoined,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'onTimeRate': onTimeRate,
      'joinedDate': joinedDate,
      'fcmToken': fcmToken,
      'isDriverVerified': isDriverVerified,
      'driverStatus': driverStatus,
      'rewardPoints': rewardPoints,
      'preferredPickupArea': preferredPickupArea,
      'hasGeminiSticker': hasGeminiSticker,
      'userType': userType,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? 'Aggie Student',
      email: map['email'] ?? '',
      classYear: map['classYear'] ?? '',
      major: map['major'] ?? '',
      isTamuVerified: map['isTamuVerified'] ?? false,
      avatar: map['avatar'] ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      bio: map['bio'] ?? '',
      carModel: map['carModel'],
      ridesOffered: (map['ridesOffered'] as num?)?.toInt() ?? 0,
      ridesJoined: (map['ridesJoined'] as num?)?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: (map['reviewsCount'] as num?)?.toInt() ?? 0,
      onTimeRate: map['onTimeRate'] ?? '100%',
      joinedDate: map['joinedDate'] ?? 'Fall 2024',
      fcmToken: map['fcmToken'],
      isDriverVerified: map['isDriverVerified'] ?? false,
      driverStatus: map['driverStatus'] ?? 'UNVERIFIED',
      rewardPoints: (map['rewardPoints'] as num?)?.toInt() ?? 0,
      preferredPickupArea: map['preferredPickupArea'] ?? 'College Station',
      hasGeminiSticker: map['hasGeminiSticker'] ?? false,
      userType: map['userType'] ?? 'both',
    );
  }
}

