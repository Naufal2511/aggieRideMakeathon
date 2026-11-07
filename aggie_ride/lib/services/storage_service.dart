import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'supabase_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  FirebaseStorage? _storage;

  FirebaseStorage get storage {
    if (_storage == null) {
      if (Firebase.apps.isNotEmpty) {
        _storage = FirebaseStorage.instance;
      }
    }
    return _storage!;
  }

  bool get isStorageAvailable => Firebase.apps.isNotEmpty;

  /// Upload a user avatar to Supabase Storage or Firebase Cloud Storage
  /// Falls back to base64 data URL if running in local offline demo mode.
  Future<String> uploadProfileAvatar({
    required String userId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    // 1. Try Supabase Storage
    if (SupabaseService().isConnected) {
      final suUrl = await SupabaseService().uploadAvatar(
        userId: userId,
        bytes: imageBytes,
        fileName: fileName,
      );
      if (suUrl != null) {
        debugPrint('Avatar uploaded to Supabase Storage: $suUrl');
        return suUrl;
      }
    }

    // 2. Try Firebase Cloud Storage
    try {
      if (isStorageAvailable) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('users')
            .child(userId)
            .child('avatar')
            .child(fileName);

        final metadata = SettableMetadata(
          contentType: fileName.endsWith('.png') ? 'image/png' : 'image/jpeg',
          customMetadata: {'uploadedBy': userId, 'purpose': 'avatar'},
        );

        final uploadTask = await ref.putData(imageBytes, metadata);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        debugPrint('Avatar uploaded to Cloud Storage: $downloadUrl');
        return downloadUrl;
      }
    } catch (e) {
      debugPrint('Cloud Storage upload fallback: $e');
    }

    // 3. Local Demo Fallback: generate a base64 Data URL
    final base64String = base64Encode(imageBytes);
    final mime = fileName.endsWith('.png') ? 'image/png' : 'image/jpeg';
    return 'data:$mime;base64,$base64String';
  }

  /// Upload a driver vehicle photo to /users/{userId}/vehicles/
  Future<String> uploadVehiclePhoto({
    required String userId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      if (isStorageAvailable) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('users')
            .child(userId)
            .child('vehicles')
            .child(fileName);

        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploadedBy': userId, 'purpose': 'vehicle'},
        );

        final uploadTask = await ref.putData(imageBytes, metadata);
        return await uploadTask.ref.getDownloadURL();
      }
    } catch (e) {
      debugPrint('Vehicle photo upload fallback: $e');
    }

    final base64String = base64Encode(imageBytes);
    return 'data:image/jpeg;base64,$base64String';
  }
}

