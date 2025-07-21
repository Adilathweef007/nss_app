// lib/services/firebase_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  // Firebase instances
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;
  static final FirebaseStorage storage = FirebaseStorage.instance;

  static bool _initialized = false;

  static Future<void> initializeFirebase() async {
    if (_initialized) return;

    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Enable Firestore persistence for offline support (optional)
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Request notification permissions on mobile devices
      if (!kIsWeb) {
        await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        // Get FCM token for this device
        String? token = await messaging.getToken();
        print('FCM Token: $token');

        // Handle token refresh
        messaging.onTokenRefresh.listen((newToken) {
          print('FCM Token refreshed: $newToken');
          // Here you could update the token in Firestore for the current user
        });
      }

      _initialized = true;
      print('Firebase initialized successfully');
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }

  // Reset the initialized flag (useful for testing)
  static void reset() {
    _initialized = false;
  }

  // Check if user is logged in
  static bool isUserLoggedIn() {
    return auth.currentUser != null;
  }

  // Get current user ID
  static String? getCurrentUserId() {
    return auth.currentUser?.uid;
  }

  // Get Firestore reference for current user document
  static DocumentReference? getCurrentUserDocument() {
    final userId = getCurrentUserId();
    return userId != null ? firestore.collection('users').doc(userId) : null;
  }
}
