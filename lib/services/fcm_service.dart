import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mentalzen/services/firestore_helper.dart';
import 'package:flutter/material.dart';

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  GlobalKey<NavigatorState>? navigatorKey;

  final FirestoreHelper dbHelper;

  FcmService(this.dbHelper, {this.navigatorKey});

  Future<void> registerDevice(String userEmail) async {
    try {
      // Request permission to receive notifications
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        sound: true,
      );

      // If the user has not granted permission to receive notifications, return
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('User has not granted permission to receive notifications');
        return;
      }

      // Get the token for the device
      final token = await _firebaseMessaging.getToken();

      if (token == null) {
        debugPrint('Failed to get FCM token');
        return;
      }

      // Update the token in the database (using email as document ID to match existing structure)
      await dbHelper.saveFCMToken(userEmail, token);
      debugPrint('FCM token registered for user: $userEmail');

      // Listen for token refresh
      final emailForRefresh = userEmail; // Capture for closure
      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        try {
          await dbHelper.saveFCMToken(emailForRefresh, newToken);
          debugPrint('FCM token refreshed for user: $emailForRefresh');
        } catch (e) {
          debugPrint('Error updating refreshed token: $e');
        }
      });
    } catch (e) {
      debugPrint('Error registering device: $e');
    }
  }

  // Initialize message handlers
  void initializeMessageHandlers() {
    // Handle foreground messages (when app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // Handle messages when app is in background but opened via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Message opened from background: ${message.data}');
      _handleMessageTap(message);
    });

    // Check if app was opened from a terminated state
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('Message opened from terminated state: ${message.data}');
        _handleMessageTap(message);
      }
    });
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    // You can show a local notification here using firebase_local_notifications
    // or show an in-app banner/dialog
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // TODO: Show local notification or in-app banner
  }

  // Handle message tap and deep linking
  void _handleMessageTap(RemoteMessage message) {
    final deepLink = message.data['deepLink'];
    final type = message.data['type'];

    if (deepLink != null && navigatorKey != null) {
      // Navigate based on deep link
      // Example: 'mentalzen://reminder/workout'
      final uri = Uri.parse(deepLink);

      if (uri.scheme == 'mentalzen') {
        if (uri.host == 'reminder' && uri.pathSegments.isNotEmpty) {
          final reminderType = uri.pathSegments[0];
          // Navigate to appropriate screen
          navigatorKey!.currentState?.pushNamed(
            '/reminder',
            arguments: reminderType,
          );
        }
      }
    } else if (type != null && navigatorKey != null) {
      // Fallback navigation based on type
      navigatorKey!.currentState?.pushNamed('/reminder', arguments: type);
    }
  }
}
