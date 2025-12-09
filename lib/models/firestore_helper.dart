import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentalzen/models/user_entry.dart';
import 'package:mentalzen/models/chat_entry.dart';

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
}
