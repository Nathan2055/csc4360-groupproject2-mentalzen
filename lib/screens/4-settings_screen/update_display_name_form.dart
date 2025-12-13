import 'package:flutter/material.dart';
import 'package:mentalzen/services/authservice.dart';
import 'package:mentalzen/services/firestore_helper.dart';

// Update Display Name form
class UpdateDisplayNameForm extends StatefulWidget {
  const UpdateDisplayNameForm(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<UpdateDisplayNameForm> createState() => _UpdateDisplayNameFormState();
}

class _UpdateDisplayNameFormState extends State<UpdateDisplayNameForm> {
  // Form state key
  final _formKey = GlobalKey<FormState>();

  // Text field controller
  final TextEditingController _displayNameController = TextEditingController();

  // A copy of the current user's display name, populated upon initialization
  // This should only be null while the widget is loading
  String? _currentDisplayName;

  bool formReady = false;

  // Tracks status of submitted async update request
  // Either 'ready', 'pending', 'complete', or 'error'
  String _updateStatusCode = 'ready';

  @override
  void initState() {
    super.initState();

    setState(() {
      _loadUserInfo();
    });
  }

  // Get the current user's info from the database
  // Once it's available, copy the existing values into the form, then copy
  // the complete UserEntry into _userInfo
  void _loadUserInfo() {
    _currentDisplayName = widget.authService.getDisplayName();

    setState(() {
      if (_currentDisplayName != null) {
        _displayNameController.text = _currentDisplayName!;
      }
    });

    formReady = true;
  }

  void _submitForm() async {
    // Hide interface, prepare to send update
    setState(() {
      _updateStatusCode = 'pending';
    });

    // Send update and register function to update status on completion
    bool result = await widget.authService.updateDisplayName(
      _displayNameController.text,
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

    // Wait for update to commit and then update status
    while (_updateStatusCode != 'ready') {
      if (_updateStatusCode == 'complete') {
        // Reload entire interface upon completion to avoid desyncs
        setState(() {
          formReady = false;
          _currentDisplayName = null;
          //_userInfo = null;
          _updateStatusCode = 'ready';
          _loadUserInfo();
        });
      } else if (_updateStatusCode == 'error') {
        // TODO: send error up the chain
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (formReady) {
      // Show form interface once the info is ready
      return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 24.0,
          children: [
            // Display name field
            TextFormField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Submit button
            ElevatedButton(
              onPressed: _submitForm,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Update Profile')],
              ),
            ),
          ],
        ),
      );
    } else if (_updateStatusCode != 'ready') {
      // Show loading screen while the database commits
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(64.0),
          child: Column(
            children: [
              Text(
                'Loading...',
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading screen until the info is ready
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          children: [
            Text(
              'Loading...',
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
