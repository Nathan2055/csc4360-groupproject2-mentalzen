import 'package:flutter/material.dart';
import 'package:mentalzen/models/authservice.dart';
import 'package:mentalzen/models/firestore_helper.dart';
import 'package:mentalzen/models/user_entry.dart';

// Update Profile form
class UpdateProfileForm extends StatefulWidget {
  const UpdateProfileForm(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<UpdateProfileForm> createState() => _UpdateProfileFormState();
}

class _UpdateProfileFormState extends State<UpdateProfileForm> {
  // Form state key
  final _formKey = GlobalKey<FormState>();

  // Text field controllers
  final TextEditingController _displayNameController = TextEditingController();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // A copy of the current user's info, populated upon initialization
  // This should only be null while the widget is loading
  UserEntry? _userInfo;

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

    /*
    // TODO: implement new setters
    widget.dbHelper.getUserEntryFromEmail(widget.authService.getEmail()!).then((
      result,
    ) {
      setState(() {
        if (result != null) {
          _usernameController.text = result.username!;
          _firstNameController.text = result.firstName!;
          _lastNameController.text = result.lastName!;
          _userInfo = result;
        }
      });
    });
    */

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

    /*
    // TODO: implement new setters
    bool result = await widget.dbHelper.updateUserProfile(
      widget.authService.getEmail()!,
      _usernameController.text,
      _firstNameController.text,
      _lastNameController.text,
    );
    */

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

            /*
            // Username field
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // First name field
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Last name field
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            */

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
