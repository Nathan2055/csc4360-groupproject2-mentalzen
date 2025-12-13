import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentalzen/models/user_entry.dart';
import 'package:mentalzen/models/chat_entry.dart';
import 'package:mentalzen/models/reminder_config.dart';
import 'package:mentalzen/models/notification_job.dart';

// FirestoreHelper handles all interaction with the Cloud Firestore databases
class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adds a new user entry
  void addUserEntry(UserEntry user) {
    final docRef = _firestore
        .collection('users')
        .withConverter(
          fromFirestore: UserEntry.fromFirestore,
          toFirestore: (UserEntry userEntry, options) =>
              userEntry.toFirestore(),
        )
        .doc(user.email);
    docRef.set(user);
  }

  // Updates an existing user entry's profile details by getting
  // the existing UserEntry from Cloud Firestore, converting it to a map,
  // applying the profile updates, converting it back to a map,
  // and then saving the result back to Cloud Firestore
  Future<bool> updateUserProfile(
    String emailID,
    String newUsername,
    String newFirstName,
    String newLastName,
  ) async {
    try {
      UserEntry newProfile = await getUserEntryFromEmail(emailID).then((
        result,
      ) {
        if (result != null) {
          Map<String, dynamic> resultMap = result.toFirestore();
          resultMap['username'] = newUsername;
          resultMap['firstName'] = newFirstName;
          resultMap['lastName'] = newLastName;
          return UserEntry.fromMap(resultMap);
        } else {
          throw Exception;
        }
      });

      final docRef = _firestore
          .collection('users')
          .withConverter(
            fromFirestore: UserEntry.fromFirestore,
            toFirestore: (UserEntry userEntry, options) =>
                userEntry.toFirestore(),
          )
          .doc(emailID);
      await docRef.set(newProfile);

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // Gets a user entry from Cloud Firestore based on an email
  Future<UserEntry?> getUserEntryFromEmail(String email) async {
    final docRef = _firestore
        .collection('users')
        .doc(email)
        .withConverter(
          fromFirestore: UserEntry.fromFirestore,
          toFirestore: (UserEntry userEntry, _) => userEntry.toFirestore(),
        );
    final docSnap = await docRef.get();
    final user = docSnap.data();
    return user;
  }

  /*
  Stream<List<UserEntry>> getUserEntryStream() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserEntry.fromSnapshot(doc)).toList(),
        );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRawUserEntryStream() {
    return _firestore.collection('users').snapshots();
  }

  void updateUserEntry(UserEntry userEntry) {
    try {
      _firestore
          .collection('users')
          .doc(userEntry.id)
          .update(userEntry.toMap());
      debugPrint('UserEntry updated');
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  void updateUserEntryByID(String id, String name, double price) {
    try {
      _firestore.collection('users').doc(id).update({
        "name": name,
        "price": price,
      });
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  void deleteUserEntry(String id) {
    try {
      _firestore.collection('users').doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }
  */

  // Chat functions start here
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
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
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

  /*
  void addChatEntry(String collection, ChatEntry chatEntry) {
    try {
      _firestore.collection(collection).add(chatEntry.toMap());
    } catch (e) {
      debugPrint('Error creating item: $e');
    }
  }

  Stream<List<ChatEntry>> getChatEntryStream(String collection) {
    return _firestore
        .collection(collection)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChatEntry.fromSnapshot(doc)).toList(),
        );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRawChatEntryStream(
    String collection,
  ) {
    return _firestore.collection(collection).snapshots();
  }

  void updateChatEntry(String collection, ChatEntry chatEntry) {
    try {
      _firestore
          .collection(collection)
          .doc(chatEntry.id)
          .update(chatEntry.toMap());
      debugPrint('ChatEntry updated');
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  void updateChatEntryByID(
    String collection,
    String id,
    String name,
    double price,
  ) {
    try {
      _firestore.collection(collection).doc(id).update({
        "name": name,
        "price": price,
      });
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  void deleteChatEntry(String collection, String id) {
    try {
      _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }

  // Firestore query for search
  Stream<QuerySnapshot<Object?>>? searchProducts(
    String collection,
    String query,
  ) {
    try {
      var result = _firestore
          .collection(collection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .snapshots();
      return result;
    } catch (e) {
      debugPrint('Error searching items: $e');
      return null;
    }
  }

  // Firestore query for price filter
  Stream<QuerySnapshot<Object?>>? filterProductsByPrice(
    String collection,
    double minPrice,
    double maxPrice,
  ) {
    try {
      var result = _firestore
          .collection(collection)
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice)
          .snapshots();
      return result;
    } catch (e) {
      debugPrint('Error filtering items: $e');
      return null;
    }
  }
  */
}
