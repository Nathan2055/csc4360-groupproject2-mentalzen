import 'package:flutter/material.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/models/firestore_helper.dart';

// Create Account screen
// Imported and shown on the welcome screen when the create account button is pressed
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  // Form state key
  final _formKey = GlobalKey<FormState>();

  // Text field controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // Track password visibility for the "show password" toggle
  bool _isPasswordVisible = false;

  void _submitForm() {
    String emailAddress = _emailController.text;
    String password = _passwordController.text;
    String username = _usernameController.text;
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;

    widget.authService.createAccount(
      emailAddress,
      password,
      username,
      firstName,
      lastName,
    );

    widget.authService.login(emailAddress, password);
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
          // Email address field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),

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

          // Submit button
          ElevatedButton(
            onPressed: _submitForm,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Create Account')],
            ),
          ),
        ],
      ),
    );
  }
}
