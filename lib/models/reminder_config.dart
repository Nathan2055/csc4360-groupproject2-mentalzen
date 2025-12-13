import 'package:cloud_firestore/cloud_firestore.dart';

// Representation of a reminder configuration
// Stored in users/{userId}/reminders subcollection
class ReminderConfig {
  final String id;
  final String userId;
  final List<String> types; // ['workout', 'water', 'diet', 'snack']
  final String time; // HH:mm format
  final List<int> daysOfWeek; // 1-7, Monday-Sunday
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReminderConfig({
    required this.id,
    required this.userId,
    required this.types,
    required this.time,
    required this.daysOfWeek,
    this.isEnabled = true,
    required this.createdAt,
    this.updatedAt,
  });

  // Constructor from a Firestore DocumentSnapshot
  factory ReminderConfig.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return ReminderConfig(
      id: snapshot.id,
      userId: data?['userId'] ?? '',
      types: List<String>.from(data?['types'] ?? []),
      time: data?['time'] ?? '',
      daysOfWeek: List<int>.from(data?['daysOfWeek'] ?? []),
      isEnabled: data?['isEnabled'] ?? true,
      createdAt: data?['createdAt'] != null
          ? (data!['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data?['updatedAt'] != null
          ? (data!['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Constructor from a properly formatted Map<String, dynamic>
  factory ReminderConfig.fromMap(Map<String, dynamic> map) {
    return ReminderConfig(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      types: List<String>.from(map['types'] ?? []),
      time: map['time'] ?? '',
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? []),
      isEnabled: map['isEnabled'] ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Converter to a properly formatted Map<String, dynamic>
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'types': types,
      'time': time,
      'daysOfWeek': daysOfWeek,
      'isEnabled': isEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }
}
