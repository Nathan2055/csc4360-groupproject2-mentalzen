import 'package:flutter/material.dart';
import 'package:mentalzen/services/authservice.dart';
import 'package:mentalzen/services/firestore_helper.dart';
import 'package:mentalzen/screens/4-profile_screen/update_profile_form.dart';

// Profile Screen
// Displays the Update Profile form
class ProfileScreen extends StatefulWidget {
  const ProfileScreen(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: UpdateProfileForm(widget.authService, widget.dbHelper),
    );
  }
}
