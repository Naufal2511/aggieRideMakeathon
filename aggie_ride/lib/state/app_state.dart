import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/ride_model.dart';
import '../models/request_model.dart';
import '../models/notification_model.dart';
import '../models/ride_group_model.dart';
import '../models/travel_intention_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../services/seed_data_service.dart';

class AppState extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  final StorageService _storageService = StorageService();
  final SupabaseService _supabaseService = SupabaseService();
  final Uuid _uuid = const Uuid();

  List<UserModel> _users = [];
  List<RideModel> _rides = [];
  List<RequestModel> _requests = [];
  List<NotificationModel> _notifications = [];
  List<RideGroupModel> _rideGroups = [];
  List<TravelIntentionModel> _intentions = [];
  List<Map<String, dynamic>> _conversations = [];

  UserModel? _currentUser;
  // 5 Tab Navigation: 0: Home, 1: Discover, 2: My Journeys, 3: Messages, 4: Profile
  int _activeTab = 0;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  int _minSeatsFilter = 0;
  String _dateFilter = 'All';
  bool _isLoading = true;
  String? _toastMessage;

  // Getters
  List<UserModel> get users => _users;
  List<RideModel> get rides => _rides;
  List<RequestModel> get requests => _requests;
  List<NotificationModel> get notifications => _notifications;
  List<RideGroupModel> get rideGroups => _rideGroups;
  List<TravelIntentionModel> get intentions => _intentions;
  List<Map<String, dynamic>> get conversations => _conversations;
  List<Map<String, dynamic>> get pickupZones => SeedDataService.pickupZones;
  List<Map<String, dynamic>> get events => SeedDataService.initialEvents;
  List<Map<String, String>> get tamuFacts => SeedDataService.tamuFacts;
  List<String> get popularDestinations => SeedDataService.popularDestinations;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  LocationService get locationService => _locationService;
  AuthService get authService => _authService;
  int get activeTab => _activeTab;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  int get minSeatsFilter => _minSeatsFilter;
  String get dateFilter => _dateFilter;
  bool get isLoading => _isLoading;
  String? get toastMessage => _toastMessage;

  bool get isDriver => _currentUser != null && _currentUser!.isDriverVerified;

  int get pendingDriverRequestsCount {
    if (_currentUser == null) return 0;
    return _requests
        .where((r) => r.driverId == _currentUser!.userId && r.status == 'PENDING')
        .length;
  }

  int get unreadNotificationsCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  UserModel getDriver(String driverId) {
    return _users.firstWhere(
      (u) => u.userId == driverId,
      orElse: () => UserModel(
        userId: driverId,
        name: 'Aggie Driver',
        email: 'aggie@tamu.edu',
        classYear: 'TAMU',
        major: 'Texas A&M',
        isTamuVerified: true,
        avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        bio: 'Aggie Student Driver',
      ),
    );
  }

  List<RideModel> get filteredRides {
    return _rides.where((ride) {
      if (ride.status != 'ACTIVE') return false;

      if (_selectedCategory != 'All' &&
          ride.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }

      if (_minSeatsFilter > 0 && ride.availableSeats < _minSeatsFilter) {
        return false;
      }

      if (_dateFilter != 'All' &&
          !ride.departureDate.toLowerCase().contains(_dateFilter.toLowerCase())) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final driver = getDriver(ride.driverId);
        final matches = ride.destination.toLowerCase().contains(q) ||
            ride.origin.toLowerCase().contains(q) ||
            ride.notes.toLowerCase().contains(q) ||
            driver.name.toLowerCase().contains(q);
        if (!matches) return false;
      }

      return true;
    }).toList();
  }

  List<RideGroupModel> get filteredRideGroups {
    return _rideGroups.where((group) {
      if (_selectedCategory == 'Ride available' && group.status != 'Ride available') {
        return false;
      }
      if (_selectedCategory == 'Looking for a driver' && group.status != 'Looking for a driver') {
        return false;
      }
      if (_selectedCategory == 'Groceries' && !group.category.toLowerCase().contains('grocer')) {
        return false;
      }
      if (_selectedCategory == 'Campus' && !group.category.toLowerCase().contains('campus')) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!group.destination.toLowerCase().contains(q) &&
            !group.pickupZone.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<TravelIntentionModel> get myIntentions {
    if (_currentUser == null) return [];
    return _intentions.where((i) => i.userId == _currentUser!.userId).toList();
  }

  List<RideGroupModel> get myJoinedGroups {
    if (_currentUser == null) return [];
    return _rideGroups.where((g) => g.studentAvatars.contains(_currentUser!.avatar)).toList();
  }

  List<RideModel> get myOfferedRides {
    if (_currentUser == null) return [];
    return _rides.where((r) => r.driverId == _currentUser!.userId).toList();
  }

  List<RequestModel> get myJoinRequests {
    if (_currentUser == null) return [];
    return _requests.where((r) => r.passengerId == _currentUser!.userId).toList();
  }

  List<RequestModel> getRequestsForRide(String rideId) {
    return _requests.where((r) => r.rideId == rideId).toList();
  }

  // ==========================================
  // INITIALIZATION & AUTH
  // ==========================================

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _users = List.from(SeedDataService.initialUsers);
    _rides = List.from(SeedDataService.initialRides);
    _requests = List.from(SeedDataService.initialRequests);
    _notifications = List.from(SeedDataService.initialNotifications);
    _rideGroups = List.from(SeedDataService.initialRideGroups);
    _intentions = List.from(SeedDataService.initialIntentions);
    _conversations = List.from(SeedDataService.initialConversations);

    // Default to Carlos (Passenger) for Demand-First Experience
    _currentUser = _users.firstWhere((u) => u.userId == 'user-carlos', orElse: () => _users[0]);

    _isLoading = false;
    notifyListeners();
  }

  Future<UserModel> signIn({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signIn(email: email, password: password);
      _currentUser = user;
      _notifications = await _firebaseService.getNotifications(user.userId);
      showToast('Welcome back, ${user.name}!');
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String classYear,
    required String major,
    required String phone,
    String? carModel,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        classYear: classYear,
        major: major,
        phone: phone,
        carModel: carModel,
      );

      _currentUser = user;
      _users.insert(0, user);
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _notifications = [];
    showToast('Signed out of AggieRide.');
    notifyListeners();
  }

  // ==========================================
  // TOAST / FEEDBACK
  // ==========================================

  void showToast(String message) {
    _toastMessage = message;
    notifyListeners();
  }

  void clearToast() {
    _toastMessage = null;
    notifyListeners();
  }

  // ==========================================
  // NAVIGATION & FILTERS
  // ==========================================

  void setTab(int index) {
    _activeTab = index;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setMinSeatsFilter(int seats) {
    _minSeatsFilter = seats;
    notifyListeners();
  }

  void setDateFilter(String date) {
    _dateFilter = date;
    notifyListeners();
  }

  // ==========================================
  // USER SWITCHER (Persona Testing)
  // ==========================================

  Future<void> switchUser(String userId) async {
    final user = _users.firstWhere((u) => u.userId == userId, orElse: () => _currentUser!);
    _currentUser = user;
    showToast('Switched to ${user.name} (${user.isDriverVerified ? "Driver" : "Passenger"})');
    notifyListeners();
  }

  Future<void> resetDemo() async {
    await initialize();
    showToast('AggieRide demo data restored to initial state!');
  }

  // ==========================================
  // TRAVEL INTENTION ACTIONS (Core Feature)
  // ==========================================

  Future<TravelIntentionModel> postTravelIntention({
    required String destination,
    required String pickupZone,
    required String date,
    required String time,
    required String flexibility,
    int passengers = 1,
    String notes = '',
  }) async {
    if (_currentUser == null) throw Exception('User not signed in');

    // Find matching group or create new one
    RideGroupModel? matchedGroup;
    try {
      matchedGroup = _rideGroups.firstWhere(
        (g) => g.destination.toLowerCase().contains(destination.toLowerCase()) ||
               destination.toLowerCase().contains(g.destination.toLowerCase()),
      );
    } catch (_) {
      matchedGroup = null;
    }

    if (matchedGroup != null) {
      // Add avatar to group if not present
      final updatedAvatars = List<String>.from(matchedGroup.studentAvatars);
      if (!updatedAvatars.contains(_currentUser!.avatar)) {
        updatedAvatars.add(_currentUser!.avatar);
      }
      final gIdx = _rideGroups.indexWhere((g) => g.groupId == matchedGroup!.groupId);
      _rideGroups[gIdx] = RideGroupModel(
        groupId: matchedGroup.groupId,
        destination: matchedGroup.destination,
        category: matchedGroup.category,
        date: matchedGroup.date,
        timeWindow: matchedGroup.timeWindow,
        pickupZone: matchedGroup.pickupZone,
        interestedCount: matchedGroup.interestedCount + 1,
        availableDriversCount: matchedGroup.availableDriversCount,
        openSeatsCount: matchedGroup.openSeatsCount,
        status: matchedGroup.status,
        driverNames: matchedGroup.driverNames,
        studentAvatars: updatedAvatars,
        primaryRideId: matchedGroup.primaryRideId,
      );
    } else {
      // Create new community demand group
      matchedGroup = RideGroupModel(
        groupId: 'group-${_uuid.v4().substring(0, 8)}',
        destination: destination,
        category: 'Community Trip',
        date: date,
        timeWindow: '$time ($flexibility)',
        pickupZone: pickupZone,
        interestedCount: 1,
        availableDriversCount: 0,
        openSeatsCount: 0,
        status: 'Gathering interest',
        driverNames: const [],
        studentAvatars: [_currentUser!.avatar],
        primaryRideId: null,
      );
      _rideGroups.insert(0, matchedGroup);
    }

    final intention = TravelIntentionModel(
      intentionId: 'intent-${_uuid.v4().substring(0, 8)}',
      userId: _currentUser!.userId,
      destination: destination,
      preferredDate: date,
      earliestDeparture: time,
      latestDeparture: flexibility,
      pickupLocation: pickupZone,
      notes: notes,
      status: matchedGroup.availableDriversCount > 0 ? 'MATCHED' : 'PENDING_MATCH',
      matchedGroupId: matchedGroup.groupId,
      createdAt: DateTime.now().toIso8601String(),
    );

    _intentions.insert(0, intention);
    notifyListeners();
    return intention;
  }

  void withdrawIntention(String intentionId) {
    _intentions.removeWhere((i) => i.intentionId == intentionId);
    showToast('Travel intention withdrawn.');
    notifyListeners();
  }

  void joinGroup(String groupId) {
    if (_currentUser == null) return;
    final idx = _rideGroups.indexWhere((g) => g.groupId == groupId);
    if (idx < 0) return;

    final g = _rideGroups[idx];
    final avatars = List<String>.from(g.studentAvatars);
    if (!avatars.contains(_currentUser!.avatar)) {
      avatars.add(_currentUser!.avatar);
      _rideGroups[idx] = RideGroupModel(
        groupId: g.groupId,
        destination: g.destination,
        category: g.category,
        date: g.date,
        timeWindow: g.timeWindow,
        pickupZone: g.pickupZone,
        interestedCount: g.interestedCount + 1,
        availableDriversCount: g.availableDriversCount,
        openSeatsCount: g.openSeatsCount,
        status: g.status,
        driverNames: g.driverNames,
        studentAvatars: avatars,
        primaryRideId: g.primaryRideId,
      );
      showToast('Joined ${g.destination} travel group!');
      notifyListeners();
    }
  }

  void leaveGroup(String groupId) {
    if (_currentUser == null) return;
    final idx = _rideGroups.indexWhere((g) => g.groupId == groupId);
    if (idx < 0) return;

    final g = _rideGroups[idx];
    final avatars = List<String>.from(g.studentAvatars)..remove(_currentUser!.avatar);
    _rideGroups[idx] = RideGroupModel(
      groupId: g.groupId,
      destination: g.destination,
      category: g.category,
      date: g.date,
      timeWindow: g.timeWindow,
      pickupZone: g.pickupZone,
      interestedCount: (g.interestedCount > 0) ? g.interestedCount - 1 : 0,
      availableDriversCount: g.availableDriversCount,
      openSeatsCount: g.openSeatsCount,
      status: g.status,
      driverNames: g.driverNames,
      studentAvatars: avatars,
      primaryRideId: g.primaryRideId,
    );
    showToast('Left travel group.');
    notifyListeners();
  }

  // ==========================================
  // DRIVER ACTIONS (Offer, Accept, Reject)
  // ==========================================

  Future<void> registerAsDriver({
    required String carMake,
    required String carModel,
    required int seats,
  }) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      carModel: '$carMake $carModel',
    );
    _currentUser = UserModel(
      userId: updated.userId,
      name: updated.name,
      email: updated.email,
      classYear: updated.classYear,
      major: updated.major,
      isTamuVerified: updated.isTamuVerified,
      avatar: updated.avatar,
      bio: updated.bio,
      carModel: '$carMake $carModel',
      ridesOffered: updated.ridesOffered,
      ridesJoined: updated.ridesJoined,
      rating: updated.rating,
      reviewsCount: updated.reviewsCount,
      onTimeRate: updated.onTimeRate,
      joinedDate: updated.joinedDate,
      fcmToken: updated.fcmToken,
      isDriverVerified: true,
      driverStatus: 'VERIFIED_DEMO',
      preferredPickupArea: updated.preferredPickupArea,
      userType: 'both',
    );
    final idx = _users.indexWhere((u) => u.userId == _currentUser!.userId);
    if (idx >= 0) _users[idx] = _currentUser!;
    showToast('Driver registration complete! You can now offer rides.');
    notifyListeners();
  }

  Future<bool> offerRide({
    required String origin,
    required String destination,
    required String departureDate,
    required String departureTime,
    required int seats,
    required int contribution,
    required String category,
    required String pickupSpot,
    required String notes,
    required bool isRecurring,
    required List<String> recurringDays,
  }) async {
    if (_currentUser == null) return false;

    final newRide = RideModel(
      rideId: 'ride-${_uuid.v4().substring(0, 8)}',
      driverId: _currentUser!.userId,
      origin: origin,
      destination: destination,
      departureDate: departureDate,
      departureTime: departureTime,
      availableSeats: seats,
      totalSeats: seats,
      contribution: contribution,
      category: category,
      pickupSpot: pickupSpot.isNotEmpty ? pickupSpot : 'Main entrance',
      notes: notes.isNotEmpty ? notes : 'Heading that way! Friendly Aggies welcome to join.',
      isRecurring: isRecurring,
      recurringDays: recurringDays,
      createdAt: DateTime.now().toIso8601String(),
      status: 'ACTIVE',
    );

    _rides.insert(0, newRide);

    // Update group seats
    final gIdx = _rideGroups.indexWhere((g) => g.destination.toLowerCase().contains(destination.toLowerCase()));
    if (gIdx >= 0) {
      final g = _rideGroups[gIdx];
      _rideGroups[gIdx] = RideGroupModel(
        groupId: g.groupId,
        destination: g.destination,
        category: g.category,
        date: g.date,
        timeWindow: g.timeWindow,
        pickupZone: g.pickupZone,
        interestedCount: g.interestedCount,
        availableDriversCount: g.availableDriversCount + 1,
        openSeatsCount: g.openSeatsCount + seats,
        status: 'Ride available',
        driverNames: List.from(g.driverNames)..add(_currentUser!.name),
        studentAvatars: g.studentAvatars,
        primaryRideId: newRide.rideId,
      );
    }

    showToast('Your ride was published to the destination group!');
    notifyListeners();
    return true;
  }

  Future<bool> requestRide({
    required RideModel ride,
    required String message,
    String pickupZone = 'Park West Apartments',
  }) async {
    if (_currentUser == null) return false;

    if (ride.availableSeats <= 0) {
      showToast('Sorry, this ride is already full.');
      return false;
    }

    final req = RequestModel(
      requestId: 'req-${_uuid.v4().substring(0, 8)}',
      rideId: ride.rideId,
      passengerId: _currentUser!.userId,
      driverId: ride.driverId,
      seatsRequested: 1,
      status: 'PENDING',
      message: message.isNotEmpty ? message : 'Howdy! Would love to hitch a ride to ${ride.destination}.',
      requestedAt: DateTime.now().toIso8601String(),
    );

    _requests.insert(0, req);
    final driver = getDriver(ride.driverId);
    showToast('Seat request sent to ${driver.name}!');
    setTab(2); // Go to My Journeys
    notifyListeners();
    return true;
  }

  Future<void> acceptRequest(String requestId) async {
    final reqIndex = _requests.indexWhere((r) => r.requestId == requestId);
    if (reqIndex < 0) return;

    final req = _requests[reqIndex];
    final rideIndex = _rides.indexWhere((r) => r.rideId == req.rideId);
    if (rideIndex < 0) return;

    final ride = _rides[rideIndex];
    if (ride.availableSeats <= 0) {
      showToast('This ride has no more available seats.');
      return;
    }

    final updatedRide = ride.copyWith(availableSeats: ride.availableSeats - 1);
    _rides[rideIndex] = updatedRide;

    final updatedReq = req.copyWith(status: 'ACCEPTED');
    _requests[reqIndex] = updatedReq;

    final passenger = _users.firstWhere((u) => u.userId == req.passengerId, orElse: () => _currentUser!);
    showToast('Accepted ${passenger.name}! Boarding pass issued.');
    notifyListeners();
  }

  Future<void> rejectRequest(String requestId) async {
    final reqIndex = _requests.indexWhere((r) => r.requestId == requestId);
    if (reqIndex < 0) return;

    _requests[reqIndex] = _requests[reqIndex].copyWith(status: 'REJECTED');
    showToast('Passenger request declined.');
    notifyListeners();
  }

  Future<void> cancelRequest(String requestId) async {
    final reqIndex = _requests.indexWhere((r) => r.requestId == requestId);
    if (reqIndex < 0) return;

    _requests[reqIndex] = _requests[reqIndex].copyWith(status: 'CANCELLED');
    showToast('Ride request cancelled.');
    notifyListeners();
  }

  // ==========================================
  // CHAT MESSAGING
  // ==========================================

  void sendChatMessage(String conversationId, String text) {
    if (_currentUser == null || text.trim().isEmpty) return;

    final cIdx = _conversations.indexWhere((c) => c['conversationId'] == conversationId);
    if (cIdx >= 0) {
      final conv = _conversations[cIdx];
      final messages = List<Map<String, dynamic>>.from(conv['messages'] ?? []);
      messages.add({
        'senderId': _currentUser!.userId,
        'text': text.trim(),
        'time': 'Just now',
        'isMe': true,
      });
      conv['messages'] = messages;
      conv['lastMessage'] = text.trim();
      conv['timestamp'] = 'Just now';
      notifyListeners();
    }
  }

  Future<void> sendTamuVerificationEmail(String email) async {
    await _authService.sendTamuVerificationEmail(email);
  }

  Future<bool> verifyTamuCode(String email, String code) async {
    final success = await _authService.verifyTamuOtp(email, code);
    if (success && _currentUser != null) {
      final updated = _currentUser!.copyWith(isTamuVerified: true);
      _currentUser = updated;
      final idx = _users.indexWhere((u) => u.userId == updated.userId);
      if (idx >= 0) _users[idx] = updated;
      notifyListeners();
    }
    return success;
  }

  Future<void> markAllNotificationsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    _notifications = [];
    notifyListeners();
  }

  Future<bool> verifyCurrentUserTamu(String email) async {
    if (!email.toLowerCase().endsWith('@tamu.edu')) {
      showToast('Must use a valid @tamu.edu email address.');
      return false;
    }
    if (_currentUser == null) return false;

    _currentUser = _currentUser!.copyWith(isTamuVerified: true, email: email.trim());
    final idx = _users.indexWhere((u) => u.userId == _currentUser!.userId);
    if (idx >= 0) _users[idx] = _currentUser!;
    showToast('Success! Your @tamu.edu email is verified.');
    notifyListeners();
    return true;
  }
}
