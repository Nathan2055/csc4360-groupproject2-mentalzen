import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerDevice(String userId) async {
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
// Update the token in the database
await _firestore.collection('users').doc(userId).update({
  'fcmToken': token,
  'fcmTokenLastUpdated': DateTime.now(),
}, SetOptions(merge: true));

debugPrint('FCM token registered for user: $userId');

  // Listen for token refresh
  _firebaseMessaging.ontokenrefreshed.listen((event) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': event.token,
      "fcmTokenLastUpdated": DateTime.now(),
    }, SetOptions(merge: true));
  });

}