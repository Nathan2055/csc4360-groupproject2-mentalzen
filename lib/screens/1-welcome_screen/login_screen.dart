import 'package:flutter/material.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/models/firestore_helper.dart';

// Login screen
// Imported and shown on the welcome screen when the login button is pressed
class LoginScreen extends StatefulWidget {
  const LoginScreen(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form state key
  final _formKey = GlobalKey<FormState>();

  // Text field controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Track password visibility for the "show password" toggle
  bool _isPasswordVisible = false;

  void _submitForm() {
    String emailAddress = _emailController.text;
    String password = _passwordController.text;

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
          // Username field
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

          // Submit button
          ElevatedButton(
            onPressed: _submitForm,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Login')],
            ),
          ),
        ],
      ),
    );
  }
}
