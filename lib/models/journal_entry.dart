import 'package:cloud_firestore/cloud_firestore.dart';

// Representation of one journal entry
// Includes an id, a message, a userId, a DateTime of posting,
// and a DateTime of update
class JournalEntry {
  // Chat entry fields
  final String? id;
  final String? message;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Basic constructor
  JournalEntry({
    this.id,
    this.message,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  // Constructor from a Firestore DocumentSnapshot
  factory JournalEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return JournalEntry(
      id: data?['id'],
      message: data?['message'],
      userId: data?['userId'],
      createdAt: data?['createdAt'] != null
          ? DateTime.parse(data?['createdAt'])
          : null,
      updatedAt: data?['updatedAt'] != null
          ? DateTime.parse(data?['updatedAt'])
          : null,
    );
  }

  // Constructor from a properly formatted Map<String, dynamic>
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      message: map['message'],
      userId: map['userId'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  // Converter to a properly formatted Map<String, dynamic>
  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (message != null) "message": message,
      if (userId != null) "userId": userId,
      if (createdAt != null) "createdAt": createdAt.toString(),
      if (updatedAt != null) "updatedAt": updatedAt.toString(),
    };
  }
}
