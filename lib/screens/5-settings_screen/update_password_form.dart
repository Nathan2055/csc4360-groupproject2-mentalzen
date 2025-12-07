import 'package:flutter/material.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/models/firestore_helper.dart';

// Update Password form
class UpdatePasswordForm extends StatefulWidget {
  const UpdatePasswordForm(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<UpdatePasswordForm> createState() => _UpdatePasswordFormState();
}

class _UpdatePasswordFormState extends State<UpdatePasswordForm> {
  // Form state key
  final _formKey = GlobalKey<FormState>();

  // Text field controllers
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  // Track password visibility for the "show password" toggle
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;

  // Tracks status of submitted async update request
  // Either 'ready', 'pending', 'complete', or 'error'
  String _updateStatusCode = 'ready';

  void _submitForm() async {
    // Lock form, prepare to send update
    setState(() {
      _updateStatusCode = 'pending';
    });

    // Send request to update password
    bool result = await widget.authService.updatePassword(
      _oldPasswordController.text,
      _newPasswordController.text,
    );

    if (result) {
      setState(() {
        _updateStatusCode = 'complete';
      });
    } else {
      setState(() {
        _updateStatusCode = 'error';
      });
    }

    // Wait for update to commit and then clear and unlock form
    while (_updateStatusCode != 'ready') {
      if (_updateStatusCode == 'complete') {
        // Clear field and unlock form
        setState(() {
          _oldPasswordController.text = '';
          _newPasswordController.text = '';
          _updateStatusCode = 'ready';
        });
      } else if (_updateStatusCode == 'error') {
        // TODO: send error up the chain
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 24.0,
        children: [
          // Old Password field
          TextFormField(
            enabled: (_updateStatusCode == 'ready'),
            controller: _oldPasswordController,
            obscureText: !_isOldPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Old Password',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isOldPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isOldPasswordVisible = !_isOldPasswordVisible;
                  });
                },
              ),
            ),
          ),

          // New Password field
          TextFormField(
            enabled: (_updateStatusCode == 'ready'),
            controller: _newPasswordController,
            obscureText: !_isNewPasswordVisible,
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isNewPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isNewPasswordVisible = !_isNewPasswordVisible;
                  });
                },
              ),
            ),
          ),

          // Submit button
          ElevatedButton(
            onPressed: (_updateStatusCode != 'ready') ? null : _submitForm,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Update Password')],
            ),
          ),
        ],
      ),
    );
  }
}
