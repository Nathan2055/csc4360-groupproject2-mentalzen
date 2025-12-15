import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentalzen/models/journal_entry.dart';
import 'package:mentalzen/models/reminder_config.dart';
import 'package:mentalzen/models/notification_job.dart';

// FirestoreHelper handles all interaction with the Cloud Firestore databases
class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Journal entry methods start here
  // Creates a new journal entry in the users/{userId}/journal subcollection
  // Returns a Future that resolves to true if successful and false on failure
  Future<bool> addJournalEntry(String userId, JournalEntry journalEntry) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('journal')
          .withConverter(
            fromFirestore: JournalEntry.fromFirestore,
            toFirestore: (JournalEntry journalEntry, options) =>
                journalEntry.toFirestore(),
          )
          .doc();
      await docRef.set(journalEntry);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // Gets a Stream of all of a user's journal entries
  Stream<QuerySnapshot> getJournalEntryStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('journal')
        .snapshots();
  }

  // Updates a journal entry
  // Returns a Future that resolves to true if successful and false on failure
  Future<bool> updateJournalEntry(
    String userId,
    String journalEntryId,
    JournalEntry journalEntry,
  ) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('journal')
          .withConverter(
            fromFirestore: JournalEntry.fromFirestore,
            toFirestore: (JournalEntry journalEntry, options) =>
                journalEntry.toFirestore(),
          )
          .doc(journalEntryId);

      // Update with new updatedAt timestamp
      final updatedJournalEntry = JournalEntry(
        id: journalEntryId,
        message: journalEntry.message,
        userId: userId,
        createdAt: journalEntry.createdAt,
        updatedAt: DateTime.now(),
      );

      await docRef.set(updatedJournalEntry);
      return true;
    } catch (e) {
      debugPrint('Error updating journal entry: $e');
      return false;
    }
  }

  // Deletes a journal entry
  // Returns a Future that resolves to true if successful and false on failure
  Future<bool> deleteJournalEntry(String userId, String journalEntryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('journal')
          .doc(journalEntryId)
          .delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting journal entry: $e');
      return false;
    }
  }

  // Reminder notification methods start here
  // Creates a new reminder in users/{userId}/reminders subcollection
  // Returns a Future that resolves to true if successful and false on failure
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

  // Gets a Stream of all reminders for a user
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
  // Returns a Future that resolves to true if successful and false on failure
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
  // Returns a Future that resolves to true if successful and false on failure
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

  // Notification job functions start here
  // Creates a notification job in the notification_jobs collection
  // Returns a Future that resolves to true if successful and false on failure
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

  // FCM token functions start here
  // Creates or updates the user's stored FCM token
  // Returns a Future that resolves to true if successful and false on failure
  Future<bool> saveFCMToken(String userId, String? token) async {
    try {
      await _firestore
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
}
