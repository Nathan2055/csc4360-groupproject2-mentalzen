import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mentalzen/firebase_options.dart';
import 'package:mentalzen/authservice.dart';
import 'package:mentalzen/screens/1-welcome_screen/welcome_screen.dart';
import 'package:mentalzen/models/firestore_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final FirestoreHelper dbHelper = FirestoreHelper();
  final AuthService authService = AuthService(dbHelper);

  runApp(MyApp(authService, dbHelper));
}

class MyApp extends StatelessWidget {
  const MyApp(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mental Zen',
      home: WelcomeScreen(authService, dbHelper),
    );
  }
}
