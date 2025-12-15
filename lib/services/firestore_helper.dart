import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentalzen/models/chat_entry.dart';
import 'package:mentalzen/models/reminder_config.dart';
import 'package:mentalzen/models/notification_job.dart';

// FirestoreHelper handles all interaction with the Cloud Firestore databases
class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // BEGIN chat message code for rewrite
  // Adds a new chat entry, returns a boolean for success
  Future<bool> addChatEntry(String messageBoard, ChatEntry chatMessage) async {
    try {
      final docRef = _firestore
          .collection(messageBoard)
          .withConverter(
            fromFirestore: ChatEntry.fromFirestore,
            toFirestore: (ChatEntry chatMessage, options) =>
                chatMessage.toFirestore(),
          )
          .doc();
      await docRef.set(chatMessage);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Stream<QuerySnapshot> getChatStream(String messageBoard) {
    return _firestore.collection(messageBoard).snapshots();
  }
  // END chat message code for rewrite

  // BEGIN reminder code
  // Reminder notification functions start here
  // Creates a new reminder in users/{userId}/reminders subcollection
  Future<bool> createReminder(String userId, ReminderConfig reminder) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .withConverter(
            fromFirestore: ReminderConfig.fromFirestore,
            toFirestore: (ReminderConfig config, options) =>
                config.toFirestore(),
          )
          .doc();

      // Create a new reminder with the generated ID
      final reminderWithId = ReminderConfig(
        id: docRef.id,
        userId: userId,
        types: reminder.types,
        time: reminder.time,
        daysOfWeek: reminder.daysOfWeek,
        isEnabled: reminder.isEnabled,
        createdAt: reminder.createdAt,
        updatedAt: reminder.updatedAt,
      );

      await docRef.set(reminderWithId);
      return true;
    } catch (e) {
      debugPrint('Error creating reminder: $e');
      return false;
    }
  }

  // Gets a stream of all reminders for a user
  Stream<List<ReminderConfig>> getUserReminders(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .withConverter(
          fromFirestore: ReminderConfig.fromFirestore,
          toFirestore: (ReminderConfig config, options) => config.toFirestore(),
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Updates an existing reminder
  Future<bool> updateReminder(
    String userId,
    String reminderId,
    ReminderConfig reminder,
  ) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .withConverter(
            fromFirestore: ReminderConfig.fromFirestore,
            toFirestore: (ReminderConfig config, options) =>
                config.toFirestore(),
          )
          .doc(reminderId);

      // Update with new updatedAt timestamp
      final updatedReminder = ReminderConfig(
        id: reminderId,
        userId: userId,
        types: reminder.types,
        time: reminder.time,
        daysOfWeek: reminder.daysOfWeek,
        isEnabled: reminder.isEnabled,
        createdAt: reminder.createdAt,
        updatedAt: DateTime.now(),
      );

      await docRef.set(updatedReminder);
      return true;
    } catch (e) {
      debugPrint('Error updating reminder: $e');
      return false;
    }
  }

  // Deletes a reminder
  Future<bool> deleteReminder(String userId, String reminderId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .doc(reminderId)
          .delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
      return false;
    }
  }
  // END reminder code

  // BEGIN notification job functions
  // Notification job functions start here
  // Creates a notification job in the notification_jobs collection
  Future<bool> createNotificationJob(NotificationJob job) async {
    try {
      final docRef = _firestore
          .collection('notification_jobs')
          .withConverter(
            fromFirestore: NotificationJob.fromFirestore,
            toFirestore: (NotificationJob job, options) => job.toFirestore(),
          )
          .doc();

      // Create a new job with the generated ID
      final jobWithId = NotificationJob(
        id: docRef.id,
        userId: job.userId,
        type: job.type,
        title: job.title,
        message: job.message,
        scheduledTime: job.scheduledTime,
        status: job.status,
        createdAt: job.createdAt,
        sentAt: job.sentAt,
        fcmMessageId: job.fcmMessageId,
      );

      await docRef.set(jobWithId);
      return true;
    } catch (e) {
      debugPrint('Error creating notification job: $e');
      return false;
    }
  }

  // END notification job functions

  // BEGIN FCM functions
  // FCM job functions start here
  // Creates or updates the user's stored FCM token
  Future<bool> saveFCMToken(String userId, String? token) async {
    try {
      _firestore
          .collection('users')
          .doc(userId)
          .collection('fcmToken')
          .doc('fcmToken')
          .set({
            'fcmToken': token,
            'fcmTokenLastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
      return false;
    }
  }

  // END FCM functions
}
