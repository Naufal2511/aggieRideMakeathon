import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/ride_model.dart';
import '../models/request_model.dart';
import '../supabase_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;
  bool get isConnected => _isInitialized && SupabaseConfig.isConfigured;

  SupabaseClient get client => Supabase.instance.client;

  Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint('Supabase credentials not yet configured. Running in local reactive mode.');
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _isInitialized = true;
      debugPrint('AggieRide connected to live Supabase backend: ${SupabaseConfig.supabaseUrl}');
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
    }
  }

  // ==========================================
  // USERS
  // ==========================================

  Future<List<UserModel>?> getUsers() async {
    if (!isConnected) return null;
    try {
      final List<dynamic> data = await client.from('users').select();
      return data.map((item) => _mapToUser(item)).toList();
    } catch (e) {
      debugPrint('Supabase getUsers error: $e');
      return null;
    }
  }

  Future<void> saveUser(UserModel user) async {
    if (!isConnected) return;
    try {
      await client.from('users').upsert({
        'user_id': user.userId,
        'name': user.name,
        'email': user.email,
        'class_year': user.classYear,
        'major': user.major,
        'is_tamu_verified': user.isTamuVerified,
        'avatar': user.avatar,
        'bio': user.bio,
        'car_model': user.carModel,
        'rides_offered': user.ridesOffered,
        'rides_joined': user.ridesJoined,
        'rating': user.rating,
        'reviews_count': user.reviewsCount,
        'on_time_rate': user.onTimeRate,
        'joined_date': user.joinedDate,
      });
    } catch (e) {
      debugPrint('Supabase saveUser error: $e');
    }
  }

  // ==========================================
  // RIDES
  // ==========================================

  Future<List<RideModel>?> getRides() async {
    if (!isConnected) return null;
    try {
      final List<dynamic> data = await client
          .from('rides')
          .select()
          .eq('status', 'ACTIVE')
          .order('created_at', ascending: false);
      return data.map((item) => _mapToRide(item)).toList();
    } catch (e) {
      debugPrint('Supabase getRides error: $e');
      return null;
    }
  }

  Future<void> postRide(RideModel ride) async {
    if (!isConnected) return;
    try {
      await client.from('rides').insert({
        'ride_id': ride.rideId,
        'driver_id': ride.driverId,
        'origin': ride.origin,
        'destination': ride.destination,
        'departure_date': ride.departureDate,
        'departure_time': ride.departureTime,
        'available_seats': ride.availableSeats,
        'total_seats': ride.totalSeats,
        'contribution': ride.contribution,
        'category': ride.category,
        'is_recurring': ride.isRecurring,
        'recurring_days': ride.recurringDays,
        'notes': ride.notes,
        'pickup_spot': ride.pickupSpot,
        'status': ride.status,
      });
    } catch (e) {
      debugPrint('Supabase postRide error: $e');
    }
  }

  Future<void> updateRide(RideModel ride) async {
    if (!isConnected) return;
    try {
      await client.from('rides').update({
        'available_seats': ride.availableSeats,
        'status': ride.status,
        'passengers': ride.passengers,
      }).eq('ride_id', ride.rideId);
    } catch (e) {
      debugPrint('Supabase updateRide error: $e');
    }
  }

  // ==========================================
  // REQUESTS
  // ==========================================

  Future<List<RequestModel>?> getRequests() async {
    if (!isConnected) return null;
    try {
      final List<dynamic> data = await client.from('requests').select();
      return data.map((item) => _mapToRequest(item)).toList();
    } catch (e) {
      debugPrint('Supabase getRequests error: $e');
      return null;
    }
  }

  Future<void> createRequest(RequestModel req) async {
    if (!isConnected) return;
    try {
      await client.from('requests').insert({
        'request_id': req.requestId,
        'ride_id': req.rideId,
        'passenger_id': req.passengerId,
        'driver_id': req.driverId,
        'seats_requested': req.seatsRequested,
        'status': req.status,
        'message': req.message,
      });
    } catch (e) {
      debugPrint('Supabase createRequest error: $e');
    }
  }

  Future<void> updateRequest(RequestModel req) async {
    if (!isConnected) return;
    try {
      await client.from('requests').update({
        'status': req.status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('request_id', req.requestId);
    } catch (e) {
      debugPrint('Supabase updateRequest error: $e');
    }
  }

  // ==========================================
  // STORAGE & PHOTO UPLOADS
  // ==========================================

  Future<String?> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (!isConnected) return null;
    try {
      final path = '$userId/$fileName';
      await client.storage.from('avatars').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
      return client.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      debugPrint('Supabase uploadAvatar error: $e');
      return null;
    }
  }

  // ==========================================
  // SERIALIZATION MAPPERS
  // ==========================================

  UserModel _mapToUser(Map<String, dynamic> item) {
    return UserModel(
      userId: item['user_id'] ?? '',
      name: item['name'] ?? '',
      email: item['email'] ?? '',
      classYear: item['class_year'] ?? '',
      major: item['major'] ?? '',
      isTamuVerified: item['is_tamu_verified'] ?? false,
      avatar: item['avatar'] ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      bio: item['bio'] ?? '',
      carModel: item['car_model'],
      ridesOffered: (item['rides_offered'] as num?)?.toInt() ?? 0,
      ridesJoined: (item['rides_joined'] as num?)?.toInt() ?? 0,
      rating: (item['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: (item['reviews_count'] as num?)?.toInt() ?? 0,
      onTimeRate: item['on_time_rate'] ?? '100%',
      joinedDate: item['joined_date'] ?? 'Fall 2024',
    );
  }

  RideModel _mapToRide(Map<String, dynamic> item) {
    return RideModel(
      rideId: item['ride_id'] ?? '',
      driverId: item['driver_id'] ?? '',
      origin: item['origin'] ?? '',
      destination: item['destination'] ?? '',
      departureDate: item['departure_date'] ?? '',
      departureTime: item['departure_time'] ?? '',
      availableSeats: (item['available_seats'] as num?)?.toInt() ?? 1,
      totalSeats: (item['total_seats'] as num?)?.toInt() ?? 1,
      contribution: (item['contribution'] as num?)?.toInt() ?? 0,
      category: item['category'] ?? 'Shopping',
      isRecurring: item['is_recurring'] ?? false,
      recurringDays: List<String>.from(item['recurring_days'] ?? []),
      notes: item['notes'] ?? '',
      pickupSpot: item['pickup_spot'] ?? '',
      status: item['status'] ?? 'ACTIVE',
      createdAt: item['created_at'] ?? '',
      passengers: List<String>.from(item['passengers'] ?? []),
    );
  }

  RequestModel _mapToRequest(Map<String, dynamic> item) {
    return RequestModel(
      requestId: item['request_id'] ?? '',
      rideId: item['ride_id'] ?? '',
      passengerId: item['passenger_id'] ?? '',
      driverId: item['driver_id'] ?? '',
      seatsRequested: (item['seats_requested'] as num?)?.toInt() ?? 1,
      status: item['status'] ?? 'PENDING',
      message: item['message'] ?? '',
      requestedAt: item['requested_at'] ?? '',
      updatedAt: item['updated_at'],
    );
  }
}
