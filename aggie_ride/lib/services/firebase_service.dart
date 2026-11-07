import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/ride_model.dart';
import '../models/request_model.dart';
import '../models/notification_model.dart';
import 'seed_data_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isFirebaseAvailable = false;
  bool get isFirebaseAvailable => _isFirebaseAvailable;

  FirebaseFirestore? _firestore;

  static const String _keyUsers = 'aggieride_users_cache';
  static const String _keyRides = 'aggieride_rides_cache';
  static const String _keyRequests = 'aggieride_requests_cache';
  static const String _keyNotifs = 'aggieride_notifs_cache';

  /// Initialize Firebase connection or fallback to local persistence
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _isFirebaseAvailable = true;
        debugPrint('AggieRide connected to live Firebase Firestore.');
      } else {
        // Attempt default init
        await Firebase.initializeApp();
        _firestore = FirebaseFirestore.instance;
        _isFirebaseAvailable = true;
        debugPrint('AggieRide successfully initialized Firebase.');
      }
    } catch (e) {
      _isFirebaseAvailable = false;
      debugPrint('Firebase not configured or offline. Running in zero-config local mode: $e');
    }
  }

  // ==========================================
  // USERS
  // ==========================================

  Future<List<UserModel>> getUsers() async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final snapshot = await _firestore!.collection('users').get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
        }
      } catch (e) {
        debugPrint('Error fetching users from Firestore: $e');
      }
    }

    // Local fallback
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyUsers);
    if (jsonStr != null) {
      final List decoded = jsonDecode(jsonStr);
      return decoded.map((m) => UserModel.fromMap(m)).toList();
    }

    final initial = SeedDataService.initialUsers;
    await saveUsersLocal(initial);
    return initial;
  }

  Future<void> saveUser(UserModel user) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('users').doc(user.userId).set(
          user.toMap(),
          SetOptions(merge: true),
        );
      } catch (e) {
        debugPrint('Firestore saveUser error: $e');
      }
    }

    // Also update local cache
    final users = await getUsers();
    final index = users.indexWhere((u) => u.userId == user.userId);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    await saveUsersLocal(users);
  }

  Future<void> saveUsersLocal(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(users.map((u) => u.toMap()).toList());
    await prefs.setString(_keyUsers, encoded);
  }

  // ==========================================
  // RIDES
  // ==========================================

  Future<List<RideModel>> getRides() async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final snapshot = await _firestore!
            .collection('rides')
            .where('status', isEqualTo: 'ACTIVE')
            .get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) => RideModel.fromMap(doc.data())).toList();
        }
      } catch (e) {
        debugPrint('Error fetching rides from Firestore: $e');
      }
    }

    // Local fallback
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyRides);
    if (jsonStr != null) {
      final List decoded = jsonDecode(jsonStr);
      return decoded.map((m) => RideModel.fromMap(m)).toList();
    }

    final initial = SeedDataService.initialRides;
    await saveRidesLocal(initial);
    return initial;
  }

  Future<void> postRide(RideModel ride) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('rides').doc(ride.rideId).set(ride.toMap());
      } catch (e) {
        debugPrint('Firestore postRide error: $e');
      }
    }

    final rides = await getRides();
    rides.insert(0, ride);
    await saveRidesLocal(rides);
  }

  Future<void> updateRide(RideModel ride) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('rides').doc(ride.rideId).update(ride.toMap());
      } catch (e) {
        debugPrint('Firestore updateRide error: $e');
      }
    }

    final rides = await getRides();
    final index = rides.indexWhere((r) => r.rideId == ride.rideId);
    if (index >= 0) {
      rides[index] = ride;
      await saveRidesLocal(rides);
    }
  }

  Future<void> saveRidesLocal(List<RideModel> rides) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(rides.map((r) => r.toMap()).toList());
    await prefs.setString(_keyRides, encoded);
  }

  // ==========================================
  // REQUESTS
  // ==========================================

  Future<List<RequestModel>> getRequests() async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final snapshot = await _firestore!.collection('requests').get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) => RequestModel.fromMap(doc.data())).toList();
        }
      } catch (e) {
        debugPrint('Error fetching requests from Firestore: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyRequests);
    if (jsonStr != null) {
      final List decoded = jsonDecode(jsonStr);
      return decoded.map((m) => RequestModel.fromMap(m)).toList();
    }

    final initial = SeedDataService.initialRequests;
    await saveRequestsLocal(initial);
    return initial;
  }

  Future<void> createRequest(RequestModel request) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('requests').doc(request.requestId).set(request.toMap());
      } catch (e) {
        debugPrint('Firestore createRequest error: $e');
      }
    }

    final requests = await getRequests();
    requests.insert(0, request);
    await saveRequestsLocal(requests);
  }

  Future<void> updateRequest(RequestModel request) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('requests').doc(request.requestId).update(request.toMap());
      } catch (e) {
        debugPrint('Firestore updateRequest error: $e');
      }
    }

    final requests = await getRequests();
    final index = requests.indexWhere((r) => r.requestId == request.requestId);
    if (index >= 0) {
      requests[index] = request;
      await saveRequestsLocal(requests);
    }
  }

  Future<void> saveRequestsLocal(List<RequestModel> requests) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(requests.map((r) => r.toMap()).toList());
    await prefs.setString(_keyRequests, encoded);
  }

  // ==========================================
  // NOTIFICATIONS
  // ==========================================

  Future<List<NotificationModel>> getNotifications(String userId) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final snapshot = await _firestore!
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data())).toList();
        }
      } catch (e) {
        debugPrint('Error fetching notifications from Firestore: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyNotifs);
    if (jsonStr != null) {
      final List decoded = jsonDecode(jsonStr);
      final all = decoded.map((m) => NotificationModel.fromMap(m)).toList();
      return all.where((n) => n.userId == userId).toList();
    }

    final initial = SeedDataService.initialNotifications;
    await saveNotificationsLocal(initial);
    return initial.where((n) => n.userId == userId).toList();
  }

  Future<void> addNotification(NotificationModel notif) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('notifications').doc(notif.notificationId).set(notif.toMap());
      } catch (e) {
        debugPrint('Firestore addNotification error: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    List<NotificationModel> all = [];
    final jsonStr = prefs.getString(_keyNotifs);
    if (jsonStr != null) {
      final List decoded = jsonDecode(jsonStr);
      all = decoded.map((m) => NotificationModel.fromMap(m)).toList();
    }
    all.insert(0, notif);
    await saveNotificationsLocal(all);
  }

  Future<void> markNotificationRead(String notifId) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('notifications').doc(notifId).update({'isRead': true});
      } catch (e) {
        debugPrint('Firestore markNotificationRead error: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyNotifs);
    if (jsonStr != null) {
      final List decoded = jsonDecode(jsonStr);
      final all = decoded.map((m) => NotificationModel.fromMap(m)).toList();
      final idx = all.indexWhere((n) => n.notificationId == notifId);
      if (idx >= 0) {
        all[idx] = all[idx].copyWith(isRead: true);
        await saveNotificationsLocal(all);
      }
    }
  }

  Future<void> saveNotificationsLocal(List<NotificationModel> notifs) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(notifs.map((n) => n.toMap()).toList());
    await prefs.setString(_keyNotifs, encoded);
  }

  // ==========================================
  // RESET DEMO / SEED FIREBASE
  // ==========================================

  Future<void> resetToInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsers);
    await prefs.remove(_keyRides);
    await prefs.remove(_keyRequests);
    await prefs.remove(_keyNotifs);

    await saveUsersLocal(SeedDataService.initialUsers);
    await saveRidesLocal(SeedDataService.initialRides);
    await saveRequestsLocal(SeedDataService.initialRequests);
    await saveNotificationsLocal(SeedDataService.initialNotifications);
  }

  /// 1-Click Sync to Firebase (Populates Spark Plan Free Database)
  Future<void> seedFirebase() async {
    if (!_isFirebaseAvailable || _firestore == null) {
      throw Exception('Firebase is not connected. Add google-services.json to connect.');
    }

    final batch = _firestore!.batch();

    // 1. Users
    for (final user in SeedDataService.initialUsers) {
      final doc = _firestore!.collection('users').doc(user.userId);
      batch.set(doc, user.toMap());
    }

    // 2. Rides
    for (final ride in SeedDataService.initialRides) {
      final doc = _firestore!.collection('rides').doc(ride.rideId);
      batch.set(doc, ride.toMap());
    }

    // 3. Requests
    for (final req in SeedDataService.initialRequests) {
      final doc = _firestore!.collection('requests').doc(req.requestId);
      batch.set(doc, req.toMap());
    }

    // 4. Notifications
    for (final n in SeedDataService.initialNotifications) {
      final doc = _firestore!.collection('notifications').doc(n.notificationId);
      batch.set(doc, n.toMap());
    }

    await batch.commit();
    debugPrint('Firebase Firestore successfully populated with Texas A&M Makeathon seed data!');
  }
}

