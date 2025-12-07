import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/authservice.dart';
import 'package:chatapp/screens/1-welcome_screen/welcome_screen.dart';
import 'package:chatapp/models/firestore_helper.dart';

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
      title: 'Firebase Chat App',
      home: WelcomeScreen(authService, dbHelper),
    );
  }
}
