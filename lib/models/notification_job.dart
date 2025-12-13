import 'package:cloud_firestore/cloud_firestore.dart';

// Representation of a notification job
// Stored in notification_jobs top-level collection
class NotificationJob {
  final String id;
  final String userId;
  final String type; // 'workout', 'water', 'diet', 'snack'
  final String title;
  final String message;
  final DateTime scheduledTime;
  final String status; // 'pending', 'sent', 'failed'
  final DateTime createdAt;
  final DateTime? sentAt;
  final String? fcmMessageId;

  NotificationJob({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.scheduledTime,
    this.status = 'pending',
    required this.createdAt,
    this.sentAt,
    this.fcmMessageId,
  });

  // Constructor from a Firestore DocumentSnapshot
  factory NotificationJob.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return NotificationJob(
      id: snapshot.id,
      userId: data?['userId'] ?? '',
      type: data?['type'] ?? '',
      title: data?['title'] ?? '',
      message: data?['message'] ?? '',
      scheduledTime: data?['scheduledTime'] != null
          ? (data!['scheduledTime'] as Timestamp).toDate()
          : DateTime.now(),
      status: data?['status'] ?? 'pending',
      createdAt: data?['createdAt'] != null
          ? (data!['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      sentAt: data?['sentAt'] != null
          ? (data!['sentAt'] as Timestamp).toDate()
          : null,
      fcmMessageId: data?['fcmMessageId'],
    );
  }

  // Constructor from a properly formatted Map<String, dynamic>
  factory NotificationJob.fromMap(Map<String, dynamic> map) {
    return NotificationJob(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      scheduledTime: map['scheduledTime'] != null
          ? (map['scheduledTime'] as Timestamp).toDate()
          : DateTime.now(),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      sentAt: map['sentAt'] != null
          ? (map['sentAt'] as Timestamp).toDate()
          : null,
      fcmMessageId: map['fcmMessageId'],
    );
  }

  // Converter to a properly formatted Map<String, dynamic>
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      if (sentAt != null) 'sentAt': Timestamp.fromDate(sentAt!),
      if (fcmMessageId != null) 'fcmMessageId': fcmMessageId,
    };
  }
}
