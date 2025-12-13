import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentalzen/models/chat_entry.dart';

// FirestoreHelper handles all interaction with the Cloud Firestore databases
class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
