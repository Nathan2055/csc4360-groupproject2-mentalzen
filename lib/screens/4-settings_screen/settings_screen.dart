import 'package:flutter/material.dart';
import 'package:mentalzen/models/authservice.dart';
import 'package:mentalzen/models/firestore_helper.dart';
import 'package:mentalzen/screens/4-settings_screen/update_display_name_form.dart';
import 'package:mentalzen/screens/4-settings_screen/update_password_form.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _logout() {
    widget.authService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          children: [
            const Text(
              'Update Display Name',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 20),
            UpdateDisplayNameForm(widget.authService, widget.dbHelper),
            const SizedBox(height: 40),

            const Text(
              'Update Password',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 20),
            UpdatePasswordForm(widget.authService, widget.dbHelper),
            const SizedBox(height: 40),

            const Text(
              'Log out',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Log out')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
