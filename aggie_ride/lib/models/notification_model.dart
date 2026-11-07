class NotificationModel {
  final String notificationId;
  final String userId;
  final String title;
  final String body;
  final String type; // 'REQUEST_RECEIVED', 'REQUEST_ACCEPTED', 'REQUEST_REJECTED', 'RIDE_POSTED', 'REMINDER'
  final String? rideId;
  final bool isRead;
  final String createdAt;

  const NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.rideId,
    this.isRead = false,
    required this.createdAt,
  });

  NotificationModel copyWith({
    String? notificationId,
    String? userId,
    String? title,
    String? body,
    String? type,
    String? rideId,
    bool? isRead,
    String? createdAt,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      rideId: rideId ?? this.rideId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'rideId': rideId,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationId: map['notificationId'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'INFO',
      rideId: map['rideId'],
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] ?? '',
    );
  }
}

