import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nssapp/services/firebase_service.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final FirebaseMessaging _messaging = FirebaseService.messaging;
  
  // Save FCM token
  Future<void> saveFCMToken(String userId) async {
    try {
      String? token = await _messaging.getToken();
      
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
        } catch (e) {
      // Handle error
    }
  }
  
  // Remove FCM token
  Future<void> removeFCMToken(String userId) async {
    try {
      String? token = await _messaging.getToken();
      
      await _firestore.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayRemove([token]),
      });
        } catch (e) {
      // Handle error
    }
  }
  
  // Send notification to user (using Cloud Functions - backend only)
  // Note: This method is for documentation purposes only
  // Actual implementation requires Firebase Cloud Functions
  Future<void> sendNotificationToUser(
    String userId,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    // In a real implementation, you'd call a Cloud Function to send the notification
    // For this tutorial, we'll skip this part
  }
  
  // Save notification to Firestore
  Future<void> saveNotification(
    String userId,
    String title,
    String body,
    String type,
    String? referenceId,
  ) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'referenceId': referenceId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle error
    }
  }
  
  // Get user notifications
  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      // Handle error
    }
  }
  
  // Set up background message handler
  static Future<void> setupBackgroundHandler() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  
  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle background messages
    print('Background message received: ${message.notification?.title}');
  }
  
  // Set up foreground notification handling
  void setupForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages
      print('Foreground message received: ${message.notification?.title}');
      
      // You can show a local notification here
    });
  }
}