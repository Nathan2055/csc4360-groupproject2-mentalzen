import 'package:flutter/material.dart';
import 'package:mentalzen/services/authservice.dart';
import 'package:mentalzen/services/firestore_helper.dart';
import 'package:mentalzen/screens/2-message_boards_listing/message_boards_listing.dart';
import 'package:mentalzen/screens/4-settings_screen/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _visibleScreen = 'home';
  Key _messageBoardKey = UniqueKey();

  @override
  void initState() {
    super.initState();
  }

  void _resetMessageBoard() {
    setState(() {
      _messageBoardKey = UniqueKey();
    });
  }

  Widget _getCurrentScreen() {
    switch (_visibleScreen) {
      case 'home':
        return MessageBoardsListing(
          widget.authService,
          widget.dbHelper,
          key: _messageBoardKey,
        );
      case 'settings':
        return SettingsScreen(widget.authService, widget.dbHelper);
      default:
        return MessageBoardsListing(
          widget.authService,
          widget.dbHelper,
          key: _messageBoardKey,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Zen'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Home',
            onPressed: () {
              setState(() {
                _visibleScreen = 'home';
                _resetMessageBoard();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              setState(() {
                _visibleScreen = 'settings';
              });
            },
          ),
        ],
      ),
      body: _getCurrentScreen(),
    );
  }
}
