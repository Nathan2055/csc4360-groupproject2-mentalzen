import 'package:cloud_firestore/cloud_firestore.dart';

// Representation of one chat posting
// Includes an id, a message, a userEmail, and a DateTime of posting
class ChatEntry {
  // Chat entry fields
  final String? id;
  final String? message;
  final String? userEmail;
  final DateTime? createdAt;

  // Basic constructor
  ChatEntry({this.id, this.message, this.userEmail, this.createdAt});

  // Constructor from a Firestore DocumentSnapshot
  factory ChatEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return ChatEntry(
      id: data?['id'],
      message: data?['message'],
      userEmail: data?['userEmail'],
      createdAt: data?['registeredOn'] != null
          ? DateTime.parse(data?['createdAt'])
          : null,
    );
  }

  // Constructor from a properly formatted Map<String, dynamic>
  factory ChatEntry.fromMap(Map<String, dynamic> map) {
    return ChatEntry(
      id: map['id'],
      message: map['message'],
      userEmail: map['userEmail'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }

  // Converter to a properly formatted Map<String, dynamic>
  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (message != null) "message": message,
      if (userEmail != null) "userEmail": userEmail,
      if (createdAt != null) "createdAt": createdAt.toString(),
    };
  }
}
