import 'package:cloud_firestore/cloud_firestore.dart';

// Representation of one registered user
// Includes an id, a username, a first name, a last name, a user role,
// and a DateTime of registration
class UserEntry {
  // User profile fields
  final String? id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? role;
  final DateTime? registeredOn;

  // Basic constructor
  UserEntry({
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.role,
    this.registeredOn,
  });

  // Constructor from a Firestore DocumentSnapshot
  factory UserEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserEntry(
      id: data?['id'],
      username: data?['username'],
      email: data?['email'],
      firstName: data?['firstName'],
      lastName: data?['lastName'],
      role: data?['role'],
      registeredOn: data?['registeredOn'] != null
          ? DateTime.parse(data?['registeredOn'])
          : null,
    );
  }

  // Constructor from a properly formatted Map<String, dynamic>
  factory UserEntry.fromMap(Map<String, dynamic> map) {
    return UserEntry(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      role: map['role'],
      registeredOn: map['registeredOn'] != null
          ? DateTime.parse(map['registeredOn'])
          : null,
    );
  }

  // Converter to a properly formatted Map<String, dynamic>
  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (username != null) "username": username,
      if (email != null) "email": email,
      if (firstName != null) "firstName": firstName,
      if (lastName != null) "lastName": lastName,
      if (role != null) "role": role,
      if (registeredOn != null) "registeredOn": registeredOn.toString(),
    };
  }
}
