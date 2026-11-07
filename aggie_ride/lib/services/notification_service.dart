import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final _notificationStreamController = StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get onNotificationReceived => _notificationStreamController.stream;

  bool _isInitialized = false;
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize Notifications for Mobile & Web
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Android & iOS Initialization Settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      // Create high-importance Android Notification Channel
      const androidChannel = AndroidNotificationChannel(
        'aggie_ride_channel',
        'AggieRide Notifications',
        description: 'Instant ride requests, confirmations, and campus travel alerts.',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      // 2. Setup Firebase Cloud Messaging (FCM) if available
      try {
        final fcm = FirebaseMessaging.instance;
        final settings = await fcm.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          _fcmToken = await fcm.getToken();
          debugPrint('AggieRide FCM Token: $_fcmToken');

          // Handle incoming push when app is in foreground
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            final notification = message.notification;
            if (notification != null) {
              showLocalNotification(
                title: notification.title ?? 'AggieRide Alert',
                body: notification.body ?? '',
                payload: message.data['rideId'] ?? '',
              );

              final notifModel = NotificationModel(
                notificationId: 'fcm-${DateTime.now().millisecondsSinceEpoch}',
                userId: message.data['userId'] ?? '',
                title: notification.title ?? 'AggieRide Alert',
                body: notification.body ?? '',
                type: message.data['type'] ?? 'INFO',
                rideId: message.data['rideId'],
                createdAt: DateTime.now().toIso8601String(),
              );
              _notificationStreamController.add(notifModel);
            }
          });
        }
      } catch (fcmError) {
        debugPrint('FCM not configured or in local demo mode: $fcmError');
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService init error (running in fallback mode): $e');
    }
  }

  /// Show an instant on-device notification (100% free, works offline & online)
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'aggie_ride_channel',
        'AggieRide Notifications',
        channelDescription: 'Instant ride requests, confirmations, and campus travel alerts.',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notifId = id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);
      await _localNotifications.show(
        notifId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Could not display native notification banner (e.g. running on web): $e');
    }
  }

  /// Triggered when a passenger sends a ride request
  Future<void> notifyDriverOfRequest({
    required String driverName,
    required String passengerName,
    required String destination,
  }) async {
    const title = 'New Ride Request! 🚗';
    final body = '$passengerName requested a seat on your ride to $destination.';
    await showLocalNotification(title: title, body: body);
  }

  /// Triggered when a driver accepts a passenger request
  Future<void> notifyPassengerAccepted({
    required String driverName,
    required String destination,
  }) async {
    const title = 'Seat Confirmed! 🎉';
    final body = '$driverName accepted your request to $destination. Your seat is reserved!';
    await showLocalNotification(title: title, body: body);
  }

  /// Triggered when a driver rejects a passenger request
  Future<void> notifyPassengerRejected({
    required String driverName,
    required String destination,
  }) async {
    const title = 'Ride Update';
    final body = '$driverName was unable to accept your request to $destination.';
    await showLocalNotification(title: title, body: body);
  }

  void dispose() {
    _notificationStreamController.close();
  }
}

