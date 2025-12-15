import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mentalzen/firebase_options.dart';
import 'package:mentalzen/services/authservice.dart';
import 'package:mentalzen/screens/1-welcome_screen/welcome_screen.dart';
import 'package:mentalzen/services/firestore_helper.dart';
import 'package:mentalzen/services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final FirestoreHelper dbHelper = FirestoreHelper();
  final AuthService authService = AuthService();
  // Initialize currentUser from Firebase Auth if user is already logged in
  authService.loadUserDetailsFromCurrent();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp(authService, dbHelper));
}

class MyApp extends StatefulWidget {
  const MyApp(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late FcmService fcmService;

  @override
  void initState() {
    super.initState();
    fcmService = FcmService(widget.dbHelper, navigatorKey: navigatorKey);
    fcmService.initializeMessageHandlers();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Mental Zen',
      home: WelcomeScreen(widget.authService, widget.dbHelper, fcmService),
    );
  }
}
