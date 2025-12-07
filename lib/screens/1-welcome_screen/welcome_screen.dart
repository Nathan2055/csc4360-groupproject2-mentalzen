import 'package:mentalzen/models/firestore_helper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentalzen/authservice.dart';
import 'package:mentalzen/screens/1-welcome_screen/create_account_screen.dart';
import 'package:mentalzen/screens/1-welcome_screen/login_screen.dart';
import 'package:mentalzen/screens/home_screen.dart';

// Initial welcome screen shown on app startup
// Includes login and create account options
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  AppBar authScreenAppBar = AppBar(title: const Text('Firebase Chat App'));

  // TextStyle for titles
  TextStyle titleTextStyle = const TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w400,
  );

  // Tracking variables for which interface is selected
  bool loginSelected = false;
  bool createAccountSelected = false;

  // Decide which interface to display based on selection
  Scaffold renderAuthInterface() {
    // If somehow both options get selected, reset them both
    if (loginSelected && createAccountSelected) {
      setState(() {
        loginSelected = false;
        createAccountSelected = false;
      });
    }

    return Scaffold(
      appBar: authScreenAppBar,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(64.0),
          child: Column(
            children: [
              // If the login screen is selected, render the login screen
              loginSelected
                  ? Column(
                      spacing: 24.0,
                      children: [
                        Text('Log In', style: titleTextStyle),
                        LoginScreen(widget.authService, widget.dbHelper),
                      ],
                    )
                  : Container(),

              // If the create account screen is selected, render the create account screen
              createAccountSelected
                  ? Column(
                      spacing: 24.0,
                      children: [
                        Text('Create Account', style: titleTextStyle),
                        CreateAccountScreen(
                          widget.authService,
                          widget.dbHelper,
                        ),
                      ],
                    )
                  : Container(),

              SizedBox(height: 16.0),
              backButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Starting interface to select between logging in and creating account
  Scaffold renderStartingScreen() {
    return Scaffold(
      appBar: authScreenAppBar,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(64.0),
          child: Column(
            spacing: 24.0,
            children: [
              Text('Firebase Chat App', style: titleTextStyle),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    loginSelected = true;
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Login')],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    createAccountSelected = true;
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('Create Account')],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton backButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          loginSelected = false;
          createAccountSelected = false;
        });
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('Back')],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: widget.authService.getStream(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          // Display this if an error occurs
          if (snapshot.hasError) {
            return Scaffold(
              appBar: authScreenAppBar,
              body: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(64.0),
                  child: Column(
                    children: [
                      Text('Something went wrong', style: titleTextStyle),
                    ],
                  ),
                ),
              ),
            );
          }
          // Display this while connecting to Firebase
          else if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: authScreenAppBar,
              body: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(64.0),
                  child: Column(
                    children: [Text('Loading...', style: titleTextStyle)],
                  ),
                ),
              ),
            );
          }
          // Display this if the user is not logged in yet
          else if (!snapshot.hasData) {
            if (!loginSelected && !createAccountSelected) {
              return renderStartingScreen();
            } else {
              return renderAuthInterface();
            }
          }
          // Display this once the user is logged in
          else {
            // Reset both display toggles so the welcome screen is shown again if the user logs out
            // Don't use setState() here since it will trigger a rebuild we don't need yet
            loginSelected = false;
            createAccountSelected = false;
            return HomeScreen(widget.authService, widget.dbHelper);
          }
        },
      ),
    );
  }
}
